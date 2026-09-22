/// Aggregated public platform statistics.
///
/// These are safe to show publicly (home screen, landing pages).
/// They never contain donor identities or beneficiary personal data.
class PlatformStats {
  const PlatformStats({
    required this.totalDonations,
    required this.monthlyDonations,
    required this.donorCount,
    required this.campaignCount,
    required this.charityCount,
    required this.beneficiaryCount,
    required this.successfulCampaigns,
    this.updatedAt,
  });

  final double totalDonations;
  final double monthlyDonations;
  final int donorCount;
  final int campaignCount;
  final int charityCount;
  final int beneficiaryCount;
  final int successfulCampaigns;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'totalDonations': totalDonations,
    'monthlyDonations': monthlyDonations,
    'donorCount': donorCount,
    'campaignCount': campaignCount,
    'charityCount': charityCount,
    'beneficiaryCount': beneficiaryCount,
    'successfulCampaigns': successfulCampaigns,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalDonations: (json['totalDonations'] as num?)?.toDouble() ?? 0,
      monthlyDonations: (json['monthlyDonations'] as num?)?.toDouble() ?? 0,
      donorCount: json['donorCount'] as int? ?? 0,
      campaignCount: json['campaignCount'] as int? ?? 0,
      charityCount: json['charityCount'] as int? ?? 0,
      beneficiaryCount: json['beneficiaryCount'] as int? ?? 0,
      successfulCampaigns: json['successfulCampaigns'] as int? ?? 0,
      updatedAt: _dateFrom(json['updatedAt']),
    );
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// A single point in a campaign's progress history.
///
/// Used for transparency: donors can see how a campaign grew over time.
class CampaignProgressPoint {
  const CampaignProgressPoint({
    required this.campaignId,
    required this.date,
    required this.collectedAmount,
    this.donorCount = 0,
  });

  final String campaignId;
  final DateTime date;
  final double collectedAmount;
  final int donorCount;

  Map<String, dynamic> toJson() => {
    'campaignId': campaignId,
    'date': date.toIso8601String(),
    'collectedAmount': collectedAmount,
    'donorCount': donorCount,
  };

  factory CampaignProgressPoint.fromJson(Map<String, dynamic> json) {
    return CampaignProgressPoint(
      campaignId: json['campaignId'] as String? ?? '',
      date: _dateFrom(json['date']),
      collectedAmount: (json['collectedAmount'] as num?)?.toDouble() ?? 0,
      donorCount: json['donorCount'] as int? ?? 0,
    );
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

/// Transparency snapshot for a single campaign.
class CampaignTransparency {
  const CampaignTransparency({
    required this.campaignId,
    required this.targetAmount,
    required this.collectedAmount,
    required this.donorCount,
    required this.beneficiaryCount,
    required this.status,
    this.history = const [],
  });

  final String campaignId;
  final double targetAmount;
  final double collectedAmount;
  final int donorCount;
  final int beneficiaryCount;
  final String status;
  final List<CampaignProgressPoint> history;

  double get remainingAmount =>
      (targetAmount - collectedAmount).clamp(0, targetAmount);
  double get progress =>
      targetAmount <= 0 ? 0 : (collectedAmount / targetAmount).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'campaignId': campaignId,
    'targetAmount': targetAmount,
    'collectedAmount': collectedAmount,
    'remainingAmount': remainingAmount,
    'donorCount': donorCount,
    'beneficiaryCount': beneficiaryCount,
    'status': status,
    'history': history.map((p) => p.toJson()).toList(),
  };

  factory CampaignTransparency.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'] as List<dynamic>? ?? const [];
    return CampaignTransparency(
      campaignId: json['campaignId'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      collectedAmount: (json['collectedAmount'] as num?)?.toDouble() ?? 0,
      donorCount: json['donorCount'] as int? ?? 0,
      beneficiaryCount: json['beneficiaryCount'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      history: rawHistory
          .map((e) => CampaignProgressPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
