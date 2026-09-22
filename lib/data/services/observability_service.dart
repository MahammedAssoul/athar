/// Log severity levels.
enum LogLevel { debug, info, warning, error }

/// A single structured log entry.
class LogEntry {
  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.category,
    this.details = const {},
  });

  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? category;
  final Map<String, dynamic> details;

  Map<String, dynamic> toJson() => {
    'level': level.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'category': category,
    'details': details,
  };
}

/// Observability service: structured logging, crash reporting and
/// analytics events.
///
/// SECURITY: implementations must NEVER log passwords, OTPs, card
/// numbers, CVV or authentication tokens. The [redact] helper strips
/// known sensitive keys before anything is persisted or sent.
abstract class ObservabilityService {
  /// Logs a structured entry.
  Future<void> log(LogEntry entry);

  /// Reports a crash/error to the crash-reporting backend.
  Future<void> reportCrash(Object error, {String? context});

  /// Records an analytics event (e.g. `donation_started`).
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties});
}

/// Redacts sensitive values from maps before logging.
///
/// Never log: passwords, OTP, card numbers, CVV, tokens.
class SensitiveDataRedactor {
  SensitiveDataRedactor._();

  static const Set<String> _sensitiveKeys = {
    'password',
    'pass',
    'otp',
    'code',
    'card',
    'cardNumber',
    'cvv',
    'cvc',
    'pin',
    'token',
    'accessToken',
    'refreshToken',
    'authorization',
  };

  /// Returns a copy of [map] with sensitive values replaced by `***`.
  static Map<String, dynamic> redact(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final key = entry.key.toLowerCase();
      if (_sensitiveKeys.any((k) => key.contains(k))) {
        result[entry.key] = '***';
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = redact(entry.value as Map<String, dynamic>);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

/// Mock observability used when `isMock == true`.
///
/// Keeps entries in memory (bounded) so tests can inspect them.
/// In production the real implementation forwards to the backend.
class MockObservabilityService implements ObservabilityService {
  const MockObservabilityService();

  static final List<LogEntry> _entries = [];
  static final List<String> _events = [];
  static final List<String> _crashes = [];

  /// Recorded log entries (for tests/inspection).
  static List<LogEntry> get entries => List.of(_entries);

  /// Recorded analytics event names (for tests/inspection).
  static List<String> get events => List.of(_events);

  /// Recorded crash reports (for tests/inspection).
  static List<String> get crashes => List.of(_crashes);

  @override
  Future<void> log(LogEntry entry) async {
    _entries.add(entry);
    if (_entries.length > 500) _entries.removeAt(0);
  }

  @override
  Future<void> reportCrash(Object error, {String? context}) async {
    _crashes.add('${error.runtimeType}${context == null ? '' : ' @ $context'}');
  }

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? properties,
  }) async {
    _events.add(name);
  }

  /// Clears all recorded entries (used by tests).
  static void reset() {
    _entries.clear();
    _events.clear();
    _crashes.clear();
  }
}

/// Real observability used when `isMock == false`.
///
/// Phase 5: forwards to the backend `/observability` endpoints. The
/// backend is responsible for forwarding to the actual crash-reporting
/// and analytics providers. This class never logs sensitive data.
class ApiObservabilityService implements ObservabilityService {
  const ApiObservabilityService();

  @override
  Future<void> log(LogEntry entry) async {
    // Phase 5: POST /observability/logs with redacted entry.
    // Not implemented — the backend endpoint is not available yet.
  }

  @override
  Future<void> reportCrash(Object error, {String? context}) async {
    // Phase 5: POST /observability/crashes.
  }

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? properties,
  }) async {
    // Phase 5: POST /observability/events.
  }
}
