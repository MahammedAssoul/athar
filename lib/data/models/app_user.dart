/// The authenticated user of the app.
class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.avatar,
    this.city,
    required this.createdAt,
    this.isVerified = false,
    this.totalDonations = 0,
    this.donationCount = 0,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? avatar;
  final String? city;
  final DateTime createdAt;
  final bool isVerified;
  final double totalDonations;
  final int donationCount;

  /// Full display name.
  String get name => '$firstName $lastName';

  /// Short name (first name only), used for greetings.
  String get shortName => firstName;

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? avatar,
    String? city,
    bool? isVerified,
    double? totalDonations,
    int? donationCount,
  }) {
    return AppUser(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      city: city ?? this.city,
      createdAt: createdAt,
      isVerified: isVerified ?? this.isVerified,
      totalDonations: totalDonations ?? this.totalDonations,
      donationCount: donationCount ?? this.donationCount,
    );
  }

  /// Serializes the user for local storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'avatar': avatar,
    'city': city,
    'createdAt': createdAt.toIso8601String(),
    'isVerified': isVerified,
    'totalDonations': totalDonations,
    'donationCount': donationCount,
  };

  /// Deserializes a user from local storage.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      city: json['city'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      totalDonations: (json['totalDonations'] as num?)?.toDouble() ?? 0,
      donationCount: json['donationCount'] as int? ?? 0,
    );
  }
}
