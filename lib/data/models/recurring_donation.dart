/// Frequency of a recurring donation.
enum RecurringFrequency { daily, weekly, monthly }

/// Lifecycle status of a recurring donation.
enum RecurringStatus { active, paused, cancelled }

extension RecurringFrequencyX on RecurringFrequency {
  String get key => name;
}

extension RecurringStatusX on RecurringStatus {
  bool get isActive => this == RecurringStatus.active;
  bool get isPaused => this == RecurringStatus.paused;
  bool get isCancelled => this == RecurringStatus.cancelled;
}

/// A recurring (sadaqah jariyah) donation plan.
class RecurringDonation {
  const RecurringDonation({
    required this.id,
    required this.campaignId,
    required this.campaignTitleAr,
    required this.campaignTitleEn,
    required this.charityNameAr,
    required this.charityNameEn,
    required this.amount,
    required this.frequency,
    required this.startDate,
    required this.status,
    required this.paymentMethod,
  });

  final String id;
  final String campaignId;
  final String campaignTitleAr;
  final String campaignTitleEn;
  final String charityNameAr;
  final String charityNameEn;
  final double amount;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final RecurringStatus status;
  final String paymentMethod;

  RecurringDonation copyWith({RecurringStatus? status}) {
    return RecurringDonation(
      id: id,
      campaignId: campaignId,
      campaignTitleAr: campaignTitleAr,
      campaignTitleEn: campaignTitleEn,
      charityNameAr: charityNameAr,
      charityNameEn: charityNameEn,
      amount: amount,
      frequency: frequency,
      startDate: startDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
    );
  }

  /// Serializes the recurring donation for API requests.
  Map<String, dynamic> toJson() => {
    'id': id,
    'campaignId': campaignId,
    'campaignTitleAr': campaignTitleAr,
    'campaignTitleEn': campaignTitleEn,
    'charityNameAr': charityNameAr,
    'charityNameEn': charityNameEn,
    'amount': amount,
    'frequency': frequency.key,
    'startDate': startDate.toIso8601String(),
    'status': status.name,
    'paymentMethod': paymentMethod,
  };

  /// Deserializes a recurring donation from an API response.
  factory RecurringDonation.fromJson(Map<String, dynamic> json) {
    return RecurringDonation(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String? ?? '',
      campaignTitleAr: json['campaignTitleAr'] as String? ?? '',
      campaignTitleEn: json['campaignTitleEn'] as String? ?? '',
      charityNameAr: json['charityNameAr'] as String? ?? '',
      charityNameEn: json['charityNameEn'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      frequency: _frequencyFrom(json['frequency']),
      startDate: _dateFrom(json['startDate']),
      status: _statusFrom(json['status']),
      paymentMethod: json['paymentMethod'] as String? ?? '',
    );
  }

  static RecurringFrequency _frequencyFrom(dynamic value) {
    if (value is String) {
      for (final frequency in RecurringFrequency.values) {
        if (frequency.key == value || frequency.name == value) {
          return frequency;
        }
      }
    }
    return RecurringFrequency.monthly;
  }

  static RecurringStatus _statusFrom(dynamic value) {
    if (value is String) {
      for (final status in RecurringStatus.values) {
        if (status.name == value) return status;
      }
    }
    return RecurringStatus.active;
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
