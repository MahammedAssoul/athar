/// Case categories a beneficiary can belong to.
enum CaseCategory {
  medical,
  food,
  housing,
  education,
  debtRelief,
  orphans,
  emergency,
}

extension CaseCategoryX on CaseCategory {
  String get key => name;
}

/// Verification status of a beneficiary.
///
/// Sensitive beneficiary information must never be exposed publicly
/// without proper authorization — the API layer enforces this by only
/// returning [Beneficiary] objects to authenticated, authorized roles.
enum BeneficiaryVerificationStatus { pending, underReview, verified, rejected }

extension BeneficiaryVerificationStatusX on BeneficiaryVerificationStatus {
  bool get isVerified => this == BeneficiaryVerificationStatus.verified;
}

/// A person or family supported by a campaign.
///
/// SECURITY: this model contains sensitive personal data. It must only
/// be serialized/transmitted to authorized parties (the owning charity,
/// platform admins, or the beneficiary themselves). Public campaign
/// pages expose only aggregated counts — never individual records.
class Beneficiary {
  const Beneficiary({
    required this.id,
    required this.campaignId,
    required this.charityId,
    required this.fullName,
    required this.category,
    required this.verificationStatus,
    this.age,
    this.gender,
    this.city,
    this.descriptionAr,
    this.descriptionEn,
    this.isMinor = false,
    this.supportAmount = 0,
    this.supportCount = 0,
    this.createdAt,
  });

  final String id;
  final String campaignId;
  final String charityId;

  /// Full name — sensitive, requires authorization to expose.
  final String fullName;
  final CaseCategory category;
  final BeneficiaryVerificationStatus verificationStatus;
  final int? age;
  final String? gender;
  final String? city;
  final String? descriptionAr;
  final String? descriptionEn;

  /// Whether the beneficiary is a minor (extra privacy protection).
  final bool isMinor;
  final double supportAmount;
  final int supportCount;
  final DateTime? createdAt;

  bool get isVerified => verificationStatus.isVerified;

  /// Serializes the beneficiary for authorized API requests.
  Map<String, dynamic> toJson() => {
    'id': id,
    'campaignId': campaignId,
    'charityId': charityId,
    'fullName': fullName,
    'category': category.key,
    'verificationStatus': verificationStatus.name,
    'age': age,
    'gender': gender,
    'city': city,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
    'isMinor': isMinor,
    'supportAmount': supportAmount,
    'supportCount': supportCount,
    'createdAt': createdAt?.toIso8601String(),
  };

  /// Deserializes a beneficiary from an authorized API response.
  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String? ?? '',
      charityId: json['charityId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      category: _categoryFrom(json['category']),
      verificationStatus: _statusFrom(json['verificationStatus']),
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      isMinor: json['isMinor'] as bool? ?? false,
      supportAmount: (json['supportAmount'] as num?)?.toDouble() ?? 0,
      supportCount: json['supportCount'] as int? ?? 0,
      createdAt: _dateFrom(json['createdAt']),
    );
  }

  static CaseCategory _categoryFrom(dynamic value) {
    if (value is String) {
      for (final cat in CaseCategory.values) {
        if (cat.key == value || cat.name == value) return cat;
      }
    }
    return CaseCategory.emergency;
  }

  static BeneficiaryVerificationStatus _statusFrom(dynamic value) {
    if (value is String) {
      for (final status in BeneficiaryVerificationStatus.values) {
        if (status.name == value) return status;
      }
    }
    return BeneficiaryVerificationStatus.pending;
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// A specific need of a beneficiary (e.g. surgery, school fees).
class Need {
  const Need({
    required this.id,
    required this.beneficiaryId,
    required this.titleAr,
    required this.titleEn,
    required this.amount,
    this.descriptionAr,
    this.descriptionEn,
    this.isFulfilled = false,
  });

  final String id;
  final String beneficiaryId;
  final String titleAr;
  final String titleEn;
  final double amount;
  final String? descriptionAr;
  final String? descriptionEn;
  final bool isFulfilled;

  Map<String, dynamic> toJson() => {
    'id': id,
    'beneficiaryId': beneficiaryId,
    'titleAr': titleAr,
    'titleEn': titleEn,
    'amount': amount,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
    'isFulfilled': isFulfilled,
  };

  factory Need.fromJson(Map<String, dynamic> json) {
    return Need(
      id: json['id'] as String,
      beneficiaryId: json['beneficiaryId'] as String? ?? '',
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      isFulfilled: json['isFulfilled'] as bool? ?? false,
    );
  }
}

/// A document attached to a beneficiary case (ID, medical report, ...).
///
/// SECURITY: document contents are sensitive. The API must only serve
/// them to authorized parties and must never include them in public
/// campaign payloads.
class BeneficiaryDocument {
  const BeneficiaryDocument({
    required this.id,
    required this.beneficiaryId,
    required this.type,
    required this.url,
    this.uploadedAt,
  });

  final String id;
  final String beneficiaryId;
  final String type;
  final String url;
  final DateTime? uploadedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'beneficiaryId': beneficiaryId,
    'type': type,
    'url': url,
    'uploadedAt': uploadedAt?.toIso8601String(),
  };

  factory BeneficiaryDocument.fromJson(Map<String, dynamic> json) {
    return BeneficiaryDocument(
      id: json['id'] as String,
      beneficiaryId: json['beneficiaryId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      url: json['url'] as String? ?? '',
      uploadedAt: _dateFrom(json['uploadedAt']),
    );
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// A record of support given to a beneficiary.
class SupportRecord {
  const SupportRecord({
    required this.id,
    required this.beneficiaryId,
    required this.campaignId,
    required this.amount,
    required this.date,
    this.description,
  });

  final String id;
  final String beneficiaryId;
  final String campaignId;
  final double amount;
  final DateTime date;
  final String? description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'beneficiaryId': beneficiaryId,
    'campaignId': campaignId,
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory SupportRecord.fromJson(Map<String, dynamic> json) {
    return SupportRecord(
      id: json['id'] as String,
      beneficiaryId: json['beneficiaryId'] as String? ?? '',
      campaignId: json['campaignId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: _dateFrom(json['date']),
      description: json['description'] as String?,
    );
  }

  static DateTime _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
