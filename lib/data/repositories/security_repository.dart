import '../models/security.dart';

/// Contract for security/audit data sources (mock or remote).
///
/// SECURITY: audit logs never contain passwords, OTPs, card numbers,
/// CVV or tokens. The backend is the authority for fraud detection;
/// this repository exposes read access for admins and the current
/// user's own security events.
abstract class SecurityRepository {
  /// Returns recent audit log entries (admin role only).
  Future<List<AuditLogEntry>> getAuditLogs({int limit = 50});

  /// Records an audit log entry.
  Future<void> recordAuditLog(AuditLogEntry entry);

  /// Returns the current user's active sessions (devices).
  Future<List<DeviceSession>> getActiveSessions();

  /// Revokes a session (logout from a device).
  Future<void> revokeSession(String sessionId);
}

/// A device session of the current user.
class DeviceSession {
  const DeviceSession({
    required this.id,
    required this.deviceName,
    required this.lastActiveAt,
    required this.isCurrent,
    this.location,
  });

  final String id;
  final String deviceName;
  final DateTime lastActiveAt;
  final bool isCurrent;
  final String? location;

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'lastActiveAt': lastActiveAt.toIso8601String(),
    'isCurrent': isCurrent,
    'location': location,
  };

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String? ?? '',
      lastActiveAt: _dateFrom(json['lastActiveAt']),
      isCurrent: json['isCurrent'] as bool? ?? false,
      location: json['location'] as String?,
    );
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
