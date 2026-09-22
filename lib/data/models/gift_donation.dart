/// A donation made as a gift to another person.
class GiftDonation {
  const GiftDonation({
    required this.id,
    required this.campaignId,
    required this.campaignTitleAr,
    required this.campaignTitleEn,
    required this.charityNameAr,
    required this.charityNameEn,
    required this.amount,
    required this.recipientName,
    required this.recipientContact,
    this.message,
    required this.date,
    required this.reference,
  });

  final String id;
  final String campaignId;
  final String campaignTitleAr;
  final String campaignTitleEn;
  final String charityNameAr;
  final String charityNameEn;
  final double amount;
  final String recipientName;

  /// Phone number or email of the recipient.
  final String recipientContact;
  final String? message;
  final DateTime date;

  /// Mock transaction reference.
  final String reference;

  /// Serializes the gift donation for API requests.
  Map<String, dynamic> toJson() => {
    'id': id,
    'campaignId': campaignId,
    'campaignTitleAr': campaignTitleAr,
    'campaignTitleEn': campaignTitleEn,
    'charityNameAr': charityNameAr,
    'charityNameEn': charityNameEn,
    'amount': amount,
    'recipientName': recipientName,
    'recipientContact': recipientContact,
    'message': message,
    'date': date.toIso8601String(),
    'reference': reference,
  };

  /// Deserializes a gift donation from an API response.
  factory GiftDonation.fromJson(Map<String, dynamic> json) {
    return GiftDonation(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String? ?? '',
      campaignTitleAr: json['campaignTitleAr'] as String? ?? '',
      campaignTitleEn: json['campaignTitleEn'] as String? ?? '',
      charityNameAr: json['charityNameAr'] as String? ?? '',
      charityNameEn: json['charityNameEn'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      recipientName: json['recipientName'] as String? ?? '',
      recipientContact: json['recipientContact'] as String? ?? '',
      message: json['message'] as String?,
      date: _dateFrom(json['date']),
      reference: json['reference'] as String? ?? '',
    );
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
