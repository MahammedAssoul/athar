import '../models/app_user.dart';

/// The demo logged-in user for Phase 1.
class MockUser {
  MockUser._();

  static final AppUser current = AppUser(
    id: 'u1',
    firstName: 'محمد',
    lastName: 'أحمد',
    phone: '091 234 5678',
    email: 'mohammed@example.com',
    city: 'طرابلس',
    createdAt: DateTime(2025, 3, 1),
    isVerified: true,
    totalDonations: 535,
    donationCount: 6,
  );
}
