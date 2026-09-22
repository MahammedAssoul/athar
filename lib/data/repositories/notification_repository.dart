import '../models/app_notification.dart';

/// Contract for notification data sources (mock or remote).
abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<AppNotification> markAsRead(String id);
  Future<void> markAllAsRead();
}
