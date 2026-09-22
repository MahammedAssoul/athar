import '../mock/mock_notifications.dart';
import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

/// In-memory notification repository backed by mock data.
class MockNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications = List.of(MockNotifications.all);

  @override
  Future<List<AppNotification>> getNotifications() async =>
      List.of(_notifications);

  @override
  Future<AppNotification> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    final updated = _notifications[index].copyWith(isRead: true);
    _notifications[index] = updated;
    return updated;
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}
