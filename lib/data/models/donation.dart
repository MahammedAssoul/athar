/// Donation payment status values.
enum DonationStatus { success, pending, failed }

/// Donation type values.
enum DonationType { oneTime, recurring }

/// A user donation.
class Donation {
  const Donation({
    required this.id,
    required this.campaignId,
    required this.campaignTitleAr,
    required this.campaignTitleEn,
    required this.charityNameAr,
    required this.charityNameEn,
    required this.amount,
    required this.date,
    required this.status,
    required this.type,
    required this.paymentMethod,
    this.reference = '',
  });

  final String id;
  final String campaignId;
  final String campaignTitleAr;
  final String campaignTitleEn;
  final String charityNameAr;
  final String charityNameEn;
  final double amount;
  final DateTime date;
  final DonationStatus status;
  final DonationType type;
  final String paymentMethod;

  /// Unique transaction reference issued by the backend.
  final String reference;

  bool get isSuccessful => status == DonationStatus.success;

  /// Serializes the donation for API requests.
  Map<String, dynamic> toJson() => {
    'id': id,
    'campaignId': campaignId,
    'campaignTitleAr': campaignTitleAr,
    'campaignTitleEn': campaignTitleEn,
    'charityNameAr': charityNameAr,
    'charityNameEn': charityNameEn,
    'amount': amount,
    'date': date.toIso8601String(),
    'status': status.name,
    'type': type.name,
    'paymentMethod': paymentMethod,
    'reference': reference,
  };

  /// Deserializes a donation from an API response.
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String? ?? '',
      campaignTitleAr: json['campaignTitleAr'] as String? ?? '',
      campaignTitleEn: json['campaignTitleEn'] as String? ?? '',
      charityNameAr: json['charityNameAr'] as String? ?? '',
      charityNameEn: json['charityNameEn'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: _dateFrom(json['date']),
      status: _statusFrom(json['status']),
      type: _typeFrom(json['type']),
      paymentMethod: json['paymentMethod'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }

  static DonationStatus _statusFrom(dynamic value) {
    if (value is String) {
      for (final status in DonationStatus.values) {
        if (status.name == value) return status;
      }
    }
    return DonationStatus.pending;
  }

  static DonationType _typeFrom(dynamic value) {
    if (value is String) {
      for (final type in DonationType.values) {
        if (type.name == value) return type;
      }
    }
    return DonationType.oneTime;
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
