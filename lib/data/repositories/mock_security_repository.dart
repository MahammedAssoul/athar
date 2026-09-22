import '../models/security.dart';
import '../repositories/security_repository.dart';

/// In-memory security repository.
///
/// SECURITY: mock audit entries never contain credentials. In API mode
/// the backend enforces admin-only access to audit logs.
class MockSecurityRepository implements SecurityRepository {
  final List<AuditLogEntry> _logs = List.of(_demoLogs);

  @override
  Future<List<AuditLogEntry>> getAuditLogs({int limit = 50}) async =>
      _logs.take(limit).toList();

  @override
  Future<void> recordAuditLog(AuditLogEntry entry) async {
    _logs.insert(0, entry);
  }

  @override
  Future<List<DeviceSession>> getActiveSessions() async => [
    DeviceSession(
      id: 'sess1',
      deviceName: 'iPhone 15 — هذا الجهاز',
      lastActiveAt: DateTime(2026, 9, 18, 9, 0),
      isCurrent: true,
      location: 'طرابلس',
    ),
    DeviceSession(
      id: 'sess2',
      deviceName: 'MacBook Pro — Chrome',
      lastActiveAt: DateTime(2026, 9, 16, 22, 30),
      isCurrent: false,
      location: 'طرابلس',
    ),
  ];

  @override
  Future<void> revokeSession(String sessionId) async {
    // Mock: no-op.
  }

  static final List<AuditLogEntry> _demoLogs = [
    AuditLogEntry(
      id: 'a1',
      actorId: 'u1',
      action: 'donation.created',
      resource: 'donation/d1',
      severity: AuditSeverity.info,
      timestamp: DateTime(2026, 9, 15, 10, 30),
      details: {'amount': 50, 'campaignId': 'c1'},
    ),
    AuditLogEntry(
      id: 'a2',
      actorId: 'u1',
      action: 'auth.login',
      resource: 'session',
      severity: AuditSeverity.info,
      timestamp: DateTime(2026, 9, 15, 10, 0),
      details: {'method': 'otp'},
    ),
    AuditLogEntry(
      id: 'a3',
      actorId: 'u1',
      action: 'auth.login.new_device',
      resource: 'session',
      severity: AuditSeverity.warning,
      timestamp: DateTime(2026, 9, 12, 8, 15),
      details: {'device': 'MacBook Pro'},
    ),
  ];
}
