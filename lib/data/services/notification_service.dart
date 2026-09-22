import '../models/push_notification.dart';

/// Push notification service abstraction.
///
/// The UI never hardcodes a notification provider (Firebase Cloud
/// Messaging, OneSignal, etc.). It only depends on this interface; the
/// backend owns provider selection and delivery.
abstract class NotificationService {
  /// Registers this device for push delivery.
  Future<void> registerDevice(String deviceToken);

  /// Unregisters this device (logout / opt-out).
  Future<void> unregisterDevice(String deviceToken);

  /// Fetches push notifications for the current user.
  Future<List<PushNotification>> getNotifications();

  /// Marks a notification as read.
  Future<PushNotification> markAsRead(String id);
}

/// Mock notification service used when `isMock == true`.
///
/// Simulates device registration and returns demo notifications.
class MockNotificationService implements NotificationService {
  MockNotificationService();

  final List<PushNotification> _notifications = List.of(_demo);

  @override
  Future<void> registerDevice(String deviceToken) async {
    // Mock: no-op. A real implementation would POST the device token.
  }

  @override
  Future<void> unregisterDevice(String deviceToken) async {
    // Mock: no-op.
  }

  @override
  Future<List<PushNotification>> getNotifications() async =>
      List.of(_notifications);

  @override
  Future<PushNotification> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    final updated = _notifications[index].copyWith(isRead: true);
    _notifications[index] = updated;
    return updated;
  }

  static final List<PushNotification> _demo = [
    PushNotification(
      id: 'p1',
      type: PushNotificationType.donationConfirmation,
      titleAr: 'تم استلام تبرعك',
      titleEn: 'Donation received',
      bodyAr: 'شكراً لك! تم استلام تبرعك بنجاح.',
      bodyEn: 'Thank you! Your donation was received successfully.',
      createdAt: DateTime(2026, 9, 15, 10, 30),
      deepLink: '/donations',
    ),
    PushNotification(
      id: 'p2',
      type: PushNotificationType.campaignCompletion,
      titleAr: 'اكتملت حملة سلة رمضان',
      titleEn: 'Ramadan baskets campaign completed',
      bodyAr: 'تم جمع الهدف الكامل وتوزيع السلال على 500 أسرة.',
      bodyEn: 'The full target was reached and baskets were distributed.',
      createdAt: DateTime(2026, 9, 14, 18, 0),
      deepLink: '/campaign/c2',
    ),
    PushNotification(
      id: 'p3',
      type: PushNotificationType.securityAlert,
      titleAr: 'تنبيه أمني',
      titleEn: 'Security alert',
      bodyAr:
          'تم تسجيل الدخول من جهاز جديد. إذا لم يكن هذا أنت، يرجى تغيير كلمة المرور.',
      bodyEn:
          'A new device logged in. If this was not you, please change your password.',
      createdAt: DateTime(2026, 9, 12, 8, 15),
    ),
  ];
}

/// Real notification service used when `isMock == false`.
///
/// Phase 5: delegates to the backend `/notifications/push` endpoints.
/// The backend talks to the actual push provider.
class ApiNotificationService implements NotificationService {
  const ApiNotificationService();

  @override
  Future<void> registerDevice(String deviceToken) async {
    // Phase 5: POST /notifications/push/devices.
  }

  @override
  Future<void> unregisterDevice(String deviceToken) async {
    // Phase 5: DELETE /notifications/push/devices/{token}.
  }

  @override
  Future<List<PushNotification>> getNotifications() async {
    // Phase 5: GET /notifications/push.
    return [];
  }

  @override
  Future<PushNotification> markAsRead(String id) async {
    // Phase 5: POST /notifications/push/{id}/read.
    throw UnimplementedError(
      'ApiNotificationService requires a backend. Set isMock = true.',
    );
  }
}
