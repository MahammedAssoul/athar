import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

/// Real notification repository backed by the Athar backend.
class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final data = await _client.get(ApiEndpoints.notifications);
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AppNotification> markAsRead(String id) async {
    final data = await _client.post(ApiEndpoints.notificationRead(id));
    return AppNotification.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> markAllAsRead() async {
    await _client.post(ApiEndpoints.notificationsReadAll);
  }
}
