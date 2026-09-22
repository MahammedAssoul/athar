import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:athar/data/models/app_user.dart';
import 'package:athar/data/repositories/mock_auth_repository.dart';
import 'package:athar/features/onboarding/presentation/onboarding_page.dart';
import 'package:athar/main.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Athar mock mode flow', () {
    test('mock auth register + login + otp flow works', () async {
      final repo = MockAuthRepository();

      final otp = await repo.sendOtp('0912345678');
      expect(otp, '1234');

      final registerResult = await repo.register(
        phone: '0912345678',
        otp: '1234',
        firstName: 'Ali',
        lastName: 'Salem',
        email: 'ali@example.com',
        city: 'Tripoli',
      );
      expect(registerResult.success, isTrue);
      expect(registerResult.user, isNotNull);

      final loginResult = await repo.login('0912345678', '1234');
      expect(loginResult.success, isTrue);
      expect(loginResult.user?.phone, '0912345678');
    });

    test('user model stores and restores from JSON', () {
      final user = AppUser(
        id: 'u1',
        firstName: 'Ahmed',
        lastName: 'Qassem',
        phone: '0910000000',
        email: 'ahmed@example.com',
        city: 'Misrata',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      );

      final json = user.toJson();
      final restored = AppUser.fromJson(json);

      expect(restored.id, user.id);
      expect(restored.firstName, user.firstName);
      expect(restored.city, user.city);
    });

    testWidgets('app starts with onboarding when no session exists', (
      tester,
    ) async {
      await tester.pumpWidget(const AtharApp());
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage), findsOneWidget);
    });
  });
}
