import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/security.dart';
import '../repositories/security_repository.dart';

/// Real security repository backed by the Athar backend.
///
/// SECURITY: audit logs never contain credentials. The backend enforces
/// admin-only access to audit logs and user-only access to sessions.
class ApiSecurityRepository implements SecurityRepository {
  ApiSecurityRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<AuditLogEntry>> getAuditLogs({int limit = 50}) async {
    final data = await _client.get(
      ApiEndpoints.auditLogs,
      query: {'limit': '$limit'},
    );
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> recordAuditLog(AuditLogEntry entry) async {
    await _client.post(ApiEndpoints.auditLogs, body: entry.toJson());
  }

  @override
  Future<List<DeviceSession>> getActiveSessions() async {
    final data = await _client.get(ApiEndpoints.sessions);
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => DeviceSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    await _client.delete(ApiEndpoints.session(sessionId));
  }
}
