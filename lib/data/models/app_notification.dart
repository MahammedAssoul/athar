/// Notification type values.
enum NotificationType { donation, campaign, recurring, impact, system, general }

/// An in-app notification.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.date,
    required this.type,
    required this.isRead,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final DateTime date;
  final NotificationType type;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      titleAr: titleAr,
      titleEn: titleEn,
      bodyAr: bodyAr,
      bodyEn: bodyEn,
      date: date,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Serializes the notification for API requests.
  Map<String, dynamic> toJson() => {
    'id': id,
    'titleAr': titleAr,
    'titleEn': titleEn,
    'bodyAr': bodyAr,
    'bodyEn': bodyEn,
    'date': date.toIso8601String(),
    'type': type.name,
    'isRead': isRead,
  };

  /// Deserializes a notification from an API response.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      bodyAr: json['bodyAr'] as String? ?? '',
      bodyEn: json['bodyEn'] as String? ?? '',
      date: _dateFrom(json['date']),
      type: _typeFrom(json['type']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static NotificationType _typeFrom(dynamic value) {
    if (value is String) {
      for (final type in NotificationType.values) {
        if (type.name == value) return type;
      }
    }
    return NotificationType.general;
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
