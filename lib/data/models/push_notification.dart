/// Push notification categories.
///
/// The app never hardcodes a notification provider (Firebase, OneSignal,
/// etc.) into the UI. The backend owns delivery; the app only models
/// the notification *types* and renders them.
enum PushNotificationType {
  donationConfirmation,
  campaignUpdate,
  campaignCompletion,
  recurringDonation,
  securityAlert,
  systemAnnouncement,
}

extension PushNotificationTypeX on PushNotificationType {
  String get key => name;
}

/// A push notification payload (as delivered by the backend).
class PushNotification {
  const PushNotification({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.createdAt,
    this.deepLink,
    this.isRead = false,
  });

  final String id;
  final PushNotificationType type;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final DateTime createdAt;

  /// Optional in-app route (e.g. `/campaign/c1`).
  final String? deepLink;
  final bool isRead;

  PushNotification copyWith({bool? isRead}) {
    return PushNotification(
      id: id,
      type: type,
      titleAr: titleAr,
      titleEn: titleEn,
      bodyAr: bodyAr,
      bodyEn: bodyEn,
      createdAt: createdAt,
      deepLink: deepLink,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.key,
    'titleAr': titleAr,
    'titleEn': titleEn,
    'bodyAr': bodyAr,
    'bodyEn': bodyEn,
    'createdAt': createdAt.toIso8601String(),
    'deepLink': deepLink,
    'isRead': isRead,
  };

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      id: json['id'] as String,
      type: _typeFrom(json['type']),
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      bodyAr: json['bodyAr'] as String? ?? '',
      bodyEn: json['bodyEn'] as String? ?? '',
      createdAt: _dateFrom(json['createdAt']),
      deepLink: json['deepLink'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static PushNotificationType _typeFrom(dynamic value) {
    if (value is String) {
      for (final type in PushNotificationType.values) {
        if (type.key == value || type.name == value) return type;
      }
    }
    return PushNotificationType.systemAnnouncement;
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

/// Notification delivery configuration.
///
/// Provider-agnostic: the backend maps these settings to the actual
/// push provider. The app never talks to a provider directly.
class NotificationDeliveryConfig {
  const NotificationDeliveryConfig({
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  /// Optional quiet hours (24h format, e.g. 22 = 10pm).
  final int? quietHoursStart;
  final int? quietHoursEnd;

  Map<String, dynamic> toJson() => {
    'pushEnabled': pushEnabled,
    'emailEnabled': emailEnabled,
    'smsEnabled': smsEnabled,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
  };

  factory NotificationDeliveryConfig.fromJson(Map<String, dynamic> json) {
    return NotificationDeliveryConfig(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      emailEnabled: json['emailEnabled'] as bool? ?? false,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as int?,
      quietHoursEnd: json['quietHoursEnd'] as int?,
    );
  }
}
