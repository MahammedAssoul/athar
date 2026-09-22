/// Notification preference categories.
enum NotificationPreferenceKey {
  donationSuccess,
  campaignCompleted,
  campaignUpdates,
  recurringDonation,
  impactUpdates,
  systemMessages,
}

/// User notification preferences. All default to enabled.
class NotificationPreferences {
  const NotificationPreferences({
    this.donationSuccess = true,
    this.campaignCompleted = true,
    this.campaignUpdates = true,
    this.recurringDonation = true,
    this.impactUpdates = true,
    this.systemMessages = true,
  });

  final bool donationSuccess;
  final bool campaignCompleted;
  final bool campaignUpdates;
  final bool recurringDonation;
  final bool impactUpdates;
  final bool systemMessages;

  bool isEnabled(NotificationPreferenceKey key) {
    return switch (key) {
      NotificationPreferenceKey.donationSuccess => donationSuccess,
      NotificationPreferenceKey.campaignCompleted => campaignCompleted,
      NotificationPreferenceKey.campaignUpdates => campaignUpdates,
      NotificationPreferenceKey.recurringDonation => recurringDonation,
      NotificationPreferenceKey.impactUpdates => impactUpdates,
      NotificationPreferenceKey.systemMessages => systemMessages,
    };
  }

  NotificationPreferences copyWith({
    bool? donationSuccess,
    bool? campaignCompleted,
    bool? campaignUpdates,
    bool? recurringDonation,
    bool? impactUpdates,
    bool? systemMessages,
  }) {
    return NotificationPreferences(
      donationSuccess: donationSuccess ?? this.donationSuccess,
      campaignCompleted: campaignCompleted ?? this.campaignCompleted,
      campaignUpdates: campaignUpdates ?? this.campaignUpdates,
      recurringDonation: recurringDonation ?? this.recurringDonation,
      impactUpdates: impactUpdates ?? this.impactUpdates,
      systemMessages: systemMessages ?? this.systemMessages,
    );
  }

  Map<String, dynamic> toJson() => {
    'donationSuccess': donationSuccess,
    'campaignCompleted': campaignCompleted,
    'campaignUpdates': campaignUpdates,
    'recurringDonation': recurringDonation,
    'impactUpdates': impactUpdates,
    'systemMessages': systemMessages,
  };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      donationSuccess: json['donationSuccess'] as bool? ?? true,
      campaignCompleted: json['campaignCompleted'] as bool? ?? true,
      campaignUpdates: json['campaignUpdates'] as bool? ?? true,
      recurringDonation: json['recurringDonation'] as bool? ?? true,
      impactUpdates: json['impactUpdates'] as bool? ?? true,
      systemMessages: json['systemMessages'] as bool? ?? true,
    );
  }
}
