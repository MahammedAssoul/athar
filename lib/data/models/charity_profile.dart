/// Verification status of a charity.
enum CharityVerificationStatus {
  unverified,
  pending,
  underReview,
  verified,
  rejected,
}

extension CharityVerificationStatusX on CharityVerificationStatus {
  bool get isVerified => this == CharityVerificationStatus.verified;
}

/// A charity's public profile (extended).
///
/// Charities manage their profile via the charity dashboard (separate
/// app/web). The donor app only reads public profile data.
class CharityProfile {
  const CharityProfile({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    this.logoUrl,
    this.location,
    this.website,
    this.phone,
    this.email,
    this.registrationNumber,
    this.verificationStatus = CharityVerificationStatus.unverified,
    this.campaignCount = 0,
    this.totalRaised = 0,
    this.beneficiaryCount = 0,
    this.rating,
    this.createdAt,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String description;
  final String? logoUrl;
  final String? location;
  final String? website;
  final String? phone;
  final String? email;

  /// Official registration number (sensitive — admin/charity only).
  final String? registrationNumber;
  final CharityVerificationStatus verificationStatus;
  final int campaignCount;
  final double totalRaised;
  final int beneficiaryCount;
  final double? rating;
  final DateTime? createdAt;

  bool get isVerified => verificationStatus.isVerified;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'description': description,
    'logoUrl': logoUrl,
    'location': location,
    'website': website,
    'phone': phone,
    'email': email,
    'registrationNumber': registrationNumber,
    'verificationStatus': verificationStatus.name,
    'campaignCount': campaignCount,
    'totalRaised': totalRaised,
    'beneficiaryCount': beneficiaryCount,
    'rating': rating,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory CharityProfile.fromJson(Map<String, dynamic> json) {
    return CharityProfile(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      description: json['description'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      verificationStatus: _statusFrom(json['verificationStatus']),
      campaignCount: json['campaignCount'] as int? ?? 0,
      totalRaised: (json['totalRaised'] as num?)?.toDouble() ?? 0,
      beneficiaryCount: json['beneficiaryCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: _dateFrom(json['createdAt']),
    );
  }

  static CharityVerificationStatus _statusFrom(dynamic value) {
    if (value is String) {
      for (final status in CharityVerificationStatus.values) {
        if (status.name == value) return status;
      }
    }
    return CharityVerificationStatus.unverified;
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// Donation statistics for a charity (dashboard).
class CharityDonationStats {
  const CharityDonationStats({
    required this.charityId,
    required this.totalDonations,
    required this.monthlyDonations,
    required this.donorCount,
    required this.campaignCount,
    required this.successfulCampaigns,
    required this.beneficiaryCount,
    this.updatedAt,
  });

  final String charityId;
  final double totalDonations;
  final double monthlyDonations;
  final int donorCount;
  final int campaignCount;
  final int successfulCampaigns;
  final int beneficiaryCount;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'charityId': charityId,
    'totalDonations': totalDonations,
    'monthlyDonations': monthlyDonations,
    'donorCount': donorCount,
    'campaignCount': campaignCount,
    'successfulCampaigns': successfulCampaigns,
    'beneficiaryCount': beneficiaryCount,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory CharityDonationStats.fromJson(Map<String, dynamic> json) {
    return CharityDonationStats(
      charityId: json['charityId'] as String? ?? '',
      totalDonations: (json['totalDonations'] as num?)?.toDouble() ?? 0,
      monthlyDonations: (json['monthlyDonations'] as num?)?.toDouble() ?? 0,
      donorCount: json['donorCount'] as int? ?? 0,
      campaignCount: json['campaignCount'] as int? ?? 0,
      successfulCampaigns: json['successfulCampaigns'] as int? ?? 0,
      beneficiaryCount: json['beneficiaryCount'] as int? ?? 0,
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
