/// A charity organization.
class Charity {
  const Charity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    required this.logoUrl,
    required this.location,
    required this.isVerified,
    required this.campaignCount,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String description;
  final String logoUrl;
  final String location;
  final bool isVerified;
  final int campaignCount;

  Charity copyWith({int? campaignCount}) {
    return Charity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      description: description,
      logoUrl: logoUrl,
      location: location,
      isVerified: isVerified,
      campaignCount: campaignCount ?? this.campaignCount,
    );
  }

  /// Serializes the charity for API requests.
  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'description': description,
    'logoUrl': logoUrl,
    'location': location,
    'isVerified': isVerified,
    'campaignCount': campaignCount,
  };

  /// Deserializes a charity from an API response.
  factory Charity.fromJson(Map<String, dynamic> json) {
    return Charity(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      description: json['description'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      campaignCount: json['campaignCount'] as int? ?? 0,
    );
  }
}
