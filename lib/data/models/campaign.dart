import 'campaign_enums.dart';

/// A donation campaign (bilingual content, Arabic default).
class Campaign {
  const Campaign({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrl,
    required this.charityId,
    required this.charityName,
    required this.category,
    required this.targetAmount,
    required this.collectedAmount,
    required this.beneficiaryCount,
    required this.location,
    required this.isUrgent,
    required this.createdAt,
    required this.endDate,
    required this.status,
    this.isFeatured = false,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String imageUrl;
  final String charityId;
  final String charityName;
  final CampaignCategory category;
  final double targetAmount;
  final double collectedAmount;
  final int beneficiaryCount;
  final String location;
  final bool isUrgent;
  final DateTime createdAt;
  final DateTime endDate;
  final CampaignStatus status;
  final bool isFeatured;

  double get remainingAmount =>
      (targetAmount - collectedAmount).clamp(0, targetAmount);
  double get progress =>
      targetAmount <= 0 ? 0 : (collectedAmount / targetAmount).clamp(0.0, 1.0);
  bool get isCompleted => collectedAmount >= targetAmount;
  bool get isActive => status.isActive;

  Campaign copyWith({double? collectedAmount, CampaignStatus? status}) {
    return Campaign(
      id: id,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      imageUrl: imageUrl,
      charityId: charityId,
      charityName: charityName,
      category: category,
      targetAmount: targetAmount,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      beneficiaryCount: beneficiaryCount,
      location: location,
      isUrgent: isUrgent,
      createdAt: createdAt,
      endDate: endDate,
      status: status ?? this.status,
      isFeatured: isFeatured,
    );
  }

  /// Serializes the campaign for API requests.
  Map<String, dynamic> toJson() => {
    'id': id,
    'titleAr': titleAr,
    'titleEn': titleEn,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
    'imageUrl': imageUrl,
    'charityId': charityId,
    'charityName': charityName,
    'category': category.key,
    'targetAmount': targetAmount,
    'collectedAmount': collectedAmount,
    'beneficiaryCount': beneficiaryCount,
    'location': location,
    'isUrgent': isUrgent,
    'createdAt': createdAt.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'status': status.name,
    'isFeatured': isFeatured,
  };

  /// Deserializes a campaign from an API response.
  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      charityId: json['charityId'] as String? ?? '',
      charityName: json['charityName'] as String? ?? '',
      category: _categoryFrom(json['category']),
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      collectedAmount: (json['collectedAmount'] as num?)?.toDouble() ?? 0,
      beneficiaryCount: json['beneficiaryCount'] as int? ?? 0,
      location: json['location'] as String? ?? '',
      isUrgent: json['isUrgent'] as bool? ?? false,
      createdAt: _dateFrom(json['createdAt']),
      endDate: _dateFrom(json['endDate']),
      status: _statusFrom(json['status']),
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  static CampaignCategory _categoryFrom(dynamic value) {
    if (value is String) {
      for (final cat in CampaignCategory.values) {
        if (cat.key == value || cat.name == value) return cat;
      }
    }
    return CampaignCategory.general;
  }

  static CampaignStatus _statusFrom(dynamic value) {
    if (value is String) {
      // Legacy values from earlier phases map onto the new lifecycle.
      if (value == 'active') return CampaignStatus.published;
      if (value == 'closed') return CampaignStatus.completed;
      for (final status in CampaignStatus.values) {
        if (status.name == value) return status;
      }
    }
    return CampaignStatus.draft;
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
