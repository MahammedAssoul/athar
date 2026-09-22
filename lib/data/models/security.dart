import 'donation.dart';

/// Severity of an audit log entry.
enum AuditSeverity { info, warning, critical }

/// An immutable audit log entry.
///
/// SECURITY: audit logs must never contain passwords, OTPs, card
/// numbers, CVV or authentication tokens. They record *what happened*
/// (actor, action, resource) — never credentials.
class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.actorId,
    required this.action,
    required this.resource,
    required this.severity,
    required this.timestamp,
    this.details = const {},
    this.ipHash,
  });

  final String id;
  final String actorId;
  final String action;
  final String resource;
  final AuditSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  /// Hashed IP (never the raw IP) for privacy.
  final String? ipHash;

  Map<String, dynamic> toJson() => {
    'id': id,
    'actorId': actorId,
    'action': action,
    'resource': resource,
    'severity': severity.name,
    'timestamp': timestamp.toIso8601String(),
    'details': details,
    'ipHash': ipHash,
  };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String,
      actorId: json['actorId'] as String? ?? '',
      action: json['action'] as String? ?? '',
      resource: json['resource'] as String? ?? '',
      severity: _severityFrom(json['severity']),
      timestamp: _dateFrom(json['timestamp']),
      details: json['details'] as Map<String, dynamic>? ?? const {},
      ipHash: json['ipHash'] as String?,
    );
  }

  static AuditSeverity _severityFrom(dynamic value) {
    if (value is String) {
      for (final severity in AuditSeverity.values) {
        if (severity.name == value) return severity;
      }
    }
    return AuditSeverity.info;
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

/// Result of a rate-limit check.
class RateLimitResult {
  const RateLimitResult({
    required this.allowed,
    required this.remaining,
    required this.retryAfterSeconds,
  });

  final bool allowed;
  final int remaining;
  final int retryAfterSeconds;

  static const RateLimitResult allowedResult = RateLimitResult(
    allowed: true,
    remaining: 0,
    retryAfterSeconds: 0,
  );
}

/// A single rate-limit bucket (sliding window).
class RateLimitBucket {
  RateLimitBucket({
    required this.key,
    required this.maxRequests,
    required this.windowSeconds,
  });

  final String key;
  final int maxRequests;
  final int windowSeconds;

  final List<DateTime> _hits = [];

  /// Records a hit and returns whether the request is allowed.
  RateLimitResult check() {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(seconds: windowSeconds));
    _hits.removeWhere((t) => t.isBefore(cutoff));
    if (_hits.length >= maxRequests) {
      final oldest = _hits.first;
      final retryAfter = oldest.difference(now).inSeconds + 1;
      return RateLimitResult(
        allowed: false,
        remaining: 0,
        retryAfterSeconds: retryAfter < 0 ? 0 : retryAfter,
      );
    }
    _hits.add(now);
    return RateLimitResult(
      allowed: true,
      remaining: maxRequests - _hits.length,
      retryAfterSeconds: 0,
    );
  }
}

/// In-memory rate limiter.
///
/// Production: the backend enforces rate limits server-side. This
/// client-side limiter protects the app from accidental request storms
/// (e.g. OTP resend spam) and is a placeholder for the server policy.
class RateLimiter {
  RateLimiter._();

  static final Map<String, RateLimitBucket> _buckets = {};

  /// Checks [key] against its bucket, creating one on first use.
  static RateLimitResult check(
    String key, {
    int maxRequests = 5,
    int windowSeconds = 60,
  }) {
    var bucket = _buckets[key];
    if (bucket == null) {
      bucket = RateLimitBucket(
        key: key,
        maxRequests: maxRequests,
        windowSeconds: windowSeconds,
      );
      _buckets[key] = bucket;
    }
    return bucket.check();
  }

  /// Clears all buckets (used by tests).
  static void reset() {
    _buckets.clear();
  }
}

/// Suspicious transaction flags.
enum FraudFlag {
  duplicateDonation,
  unusualAmount,
  rapidTransactions,
  mismatchedIdentity,
  chargebackRisk,
}

/// Result of a fraud check on a donation attempt.
class FraudCheckResult {
  const FraudCheckResult({
    required this.allowed,
    this.flags = const [],
    this.score = 0,
    this.reason,
  });

  final bool allowed;
  final List<FraudFlag> flags;

  /// 0..1 risk score (higher = riskier).
  final double score;
  final String? reason;

  static const FraudCheckResult clean = FraudCheckResult(allowed: true);

  Map<String, dynamic> toJson() => {
    'allowed': allowed,
    'flags': flags.map((f) => f.name).toList(),
    'score': score,
    'reason': reason,
  };
}

/// Client-side fraud heuristics.
///
/// SECURITY: this is a *first line* of defense only. The backend is the
/// authority for fraud detection (server-side rules, device
/// fingerprinting, payment-provider signals). The app never blocks a
/// payment on its own — it flags suspicious attempts for the backend.
class FraudDetector {
  FraudDetector._();

  /// Detects duplicate donations: same campaign + same amount within
  /// [windowSeconds] of the last donation.
  static Future<FraudCheckResult> checkDuplicateDonation({
    required String campaignId,
    required double amount,
    required List<Donation> recentDonations,
    int windowSeconds = 300,
  }) async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(seconds: windowSeconds));
    for (final d in recentDonations) {
      if (d.campaignId == campaignId &&
          d.amount == amount &&
          d.date.isAfter(cutoff)) {
        return const FraudCheckResult(
          allowed: false,
          flags: [FraudFlag.duplicateDonation],
          score: 0.9,
          reason: 'duplicate donation detected',
        );
      }
    }
    return FraudCheckResult.clean;
  }

  /// Flags unusually large donations (above [threshold]).
  static Future<FraudCheckResult> checkUnusualAmount({
    required double amount,
    double threshold = 5000,
  }) async {
    if (amount > threshold) {
      return const FraudCheckResult(
        allowed: false,
        flags: [FraudFlag.unusualAmount],
        score: 0.6,
        reason: 'amount above threshold',
      );
    }
    return FraudCheckResult.clean;
  }
}
