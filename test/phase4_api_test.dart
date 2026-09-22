import 'dart:convert';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:athar/data/api/api_client.dart';
import 'package:athar/data/api/api_config.dart';
import 'package:athar/data/api/api_error.dart';
import 'package:athar/data/di/app_dependencies.dart';
import 'package:athar/data/models/campaign.dart';
import 'package:athar/data/models/campaign_enums.dart';
import 'package:athar/data/models/donation.dart';
import 'package:athar/data/repositories/api_auth_repository.dart';
import 'package:athar/data/repositories/api_campaign_repository.dart';
import 'package:athar/data/repositories/api_donation_repository.dart';
import 'package:athar/data/repositories/mock_auth_repository.dart';
import 'package:athar/data/repositories/mock_campaign_repository.dart';
import 'package:athar/data/repositories/mock_donation_repository.dart';
import 'package:athar/data/services/payment_gateway.dart';

/// Builds a mock HTTP client that returns [body] for every request.
http.Client _jsonClient(Object body, {int status = 200}) {
  return MockClient((request) async {
    return http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );
  });
}

/// Builds a mock HTTP client that throws a network error.
http.Client _networkErrorClient() {
  return MockClient((request) async {
    throw http.ClientException('Connection refused');
  });
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    // Use the in-memory secure storage platform for tests.
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      <String, String>{},
    );
    ApiConfig.baseUrlOverride = 'https://test.athar.ly';
    AppDependencies.isMock = true;
  });

  tearDown(() {
    ApiConfig.baseUrlOverride = null;
  });

  group('Mock mode (isMock = true)', () {
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

    test('mock campaign loading works', () async {
      final repo = MockCampaignRepository();
      final campaigns = await repo.getCampaigns();
      expect(campaigns, isNotEmpty);
      expect(campaigns.first.id, isNotEmpty);
    });

    test('mock donation creation works', () async {
      final repo = MockDonationRepository();
      final donation = await repo.createDonation(
        campaignId: 'c1',
        campaignTitleAr: 'علاج',
        campaignTitleEn: 'Treatment',
        charityNameAr: 'جمعية',
        charityNameEn: 'Charity',
        amount: 50,
        type: DonationType.oneTime,
        paymentMethod: 'card',
      );
      expect(donation.id, isNotEmpty);
      expect(donation.amount, 50);
      expect(donation.isSuccessful, isTrue);
    });

    test('mock payment success', () async {
      const gateway = MockPaymentGateway();
      final result = await gateway.pay(amount: 10, method: 'card');
      expect(result.success, isTrue);
      expect(result.reference, isNotEmpty);
    });

    test('mock payment failure', () async {
      const gateway = MockPaymentGateway();
      // Amounts ending in 4 simulate failure (1 in 5).
      final result = await gateway.pay(amount: 14, method: 'card');
      expect(result.success, isFalse);
    });

    test('DI resolves mock repositories when isMock = true', () {
      AppDependencies.isMock = true;
      expect(
        AppDependencies.instance.campaignRepository,
        isA<MockCampaignRepository>(),
      );
      expect(
        AppDependencies.instance.donationRepository,
        isA<MockDonationRepository>(),
      );
      expect(
        AppDependencies.instance.authRepository,
        isA<MockAuthRepository>(),
      );
    });
  });

  group('API mode architecture (isMock = false)', () {
    test('DI resolves API repositories when isMock = false', () {
      AppDependencies.isMock = false;
      AppDependencies.reset();
      expect(
        AppDependencies.instance.campaignRepository,
        isA<ApiCampaignRepository>(),
      );
      expect(
        AppDependencies.instance.donationRepository,
        isA<ApiDonationRepository>(),
      );
      expect(AppDependencies.instance.authRepository, isA<ApiAuthRepository>());
    });

    test('ApiClient builds correct URLs with version prefix', () async {
      final client = ApiClient(client: _jsonClient({'ok': true}));
      final data = await client.get('/campaigns');
      expect(data, {'ok': true});
    });

    test('ApiClient maps 401 to unauthorized error', () async {
      final client = ApiClient(
        client: _jsonClient({'message': 'expired'}, status: 401),
      );
      expect(
        () => client.get('/campaigns'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.unauthorized,
          ),
        ),
      );
    });

    test('ApiClient maps 500 to server error', () async {
      final client = ApiClient(client: _jsonClient({}, status: 500));
      expect(
        () => client.get('/campaigns'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.server,
          ),
        ),
      );
    });

    test('ApiClient maps network failure to network error', () async {
      final client = ApiClient(client: _networkErrorClient());
      expect(
        () => client.get('/campaigns'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.network,
          ),
        ),
      );
    });

    test('ApiCampaignRepository parses campaign list', () async {
      final client = ApiClient(
        client: _jsonClient([
          {
            'id': 'c1',
            'titleAr': 'علاج',
            'titleEn': 'Treatment',
            'descriptionAr': 'وصف',
            'descriptionEn': 'Desc',
            'imageUrl': '',
            'charityId': 'ch1',
            'charityName': 'جمعية',
            'category': 'treatment',
            'targetAmount': 1000,
            'collectedAmount': 500,
            'beneficiaryCount': 10,
            'location': 'طرابلس',
            'isUrgent': true,
            'createdAt': '2026-09-01T00:00:00.000',
            'endDate': '2026-12-01T00:00:00.000',
            'status': 'active',
            'isFeatured': true,
          },
        ]),
      );
      final repo = ApiCampaignRepository(client: client);
      final campaigns = await repo.getCampaigns();
      expect(campaigns, hasLength(1));
      expect(campaigns.first.id, 'c1');
      expect(campaigns.first.category, CampaignCategory.treatment);
      expect(campaigns.first.isActive, isTrue);
    });

    test('ApiCampaignRepository caches campaigns', () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return http.Response(
          jsonEncode([
            {
              'id': 'c1',
              'titleAr': 'علاج',
              'titleEn': 'Treatment',
              'descriptionAr': '',
              'descriptionEn': '',
              'imageUrl': '',
              'charityId': 'ch1',
              'charityName': 'جمعية',
              'category': 'general',
              'targetAmount': 100,
              'collectedAmount': 0,
              'beneficiaryCount': 1,
              'location': 'طرابلس',
              'isUrgent': false,
              'createdAt': '2026-09-01T00:00:00.000',
              'endDate': '2026-12-01T00:00:00.000',
              'status': 'active',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = ApiCampaignRepository(client: ApiClient(client: client));
      await repo.getCampaigns();
      await repo.getCampaigns();
      expect(calls, 1, reason: 'second call should hit the cache');
    });

    test(
      'ApiDonationRepository creates donation with backend reference',
      () async {
        final client = ApiClient(
          client: _jsonClient({
            'id': 'd1',
            'campaignId': 'c1',
            'campaignTitleAr': 'علاج',
            'campaignTitleEn': 'Treatment',
            'charityNameAr': 'جمعية',
            'charityNameEn': 'Charity',
            'amount': 50,
            'date': '2026-09-17T10:00:00.000',
            'status': 'success',
            'type': 'oneTime',
            'paymentMethod': 'card',
            'reference': 'TXN-ABC-123',
          }),
        );
        final repo = ApiDonationRepository(client: client);
        final donation = await repo.createDonation(
          campaignId: 'c1',
          campaignTitleAr: 'علاج',
          campaignTitleEn: 'Treatment',
          charityNameAr: 'جمعية',
          charityNameEn: 'Charity',
          amount: 50,
          type: DonationType.oneTime,
          paymentMethod: 'card',
        );
        expect(donation.reference, 'TXN-ABC-123');
        expect(donation.isSuccessful, isTrue);
      },
    );

    test('ApiAuthRepository login stores tokens', () async {
      final client = ApiClient(
        client: _jsonClient({
          'accessToken': 'access-123',
          'refreshToken': 'refresh-123',
          'user': {
            'id': 'u1',
            'firstName': 'محمد',
            'lastName': 'أحمد',
            'phone': '0912345678',
            'createdAt': '2025-03-01T00:00:00.000',
            'isVerified': true,
          },
        }),
      );
      final repo = ApiAuthRepository(client: client);
      final result = await repo.login('0912345678', '1234');
      expect(result.success, isTrue);
      expect(result.user?.id, 'u1');
    });

    test('ApiAuthRepository login failure returns error result', () async {
      final client = ApiClient(
        client: _jsonClient({'message': 'invalid otp'}, status: 401),
      );
      final repo = ApiAuthRepository(client: client);
      final result = await repo.login('0912345678', '9999');
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });
  });

  group('Error messages', () {
    test('network error maps to Arabic message', () {
      expect(
        ApiErrorMessages.ar(ApiErrorType.network),
        'لا يوجد اتصال بالإنترنت',
      );
    });

    test('server error maps to Arabic message', () {
      expect(
        ApiErrorMessages.ar(ApiErrorType.server),
        'حدث خطأ، يرجى المحاولة مرة أخرى',
      );
    });

    test('unauthorized maps to English message', () {
      expect(
        ApiErrorMessages.en(ApiErrorType.unauthorized),
        'Session expired, please log in again',
      );
    });
  });

  group('Model serialization', () {
    test('Campaign round-trips through JSON', () {
      final campaign = Campaign(
        id: 'c1',
        titleAr: 'علاج',
        titleEn: 'Treatment',
        descriptionAr: 'وصف',
        descriptionEn: 'Desc',
        imageUrl: '',
        charityId: 'ch1',
        charityName: 'جمعية',
        category: CampaignCategory.treatment,
        targetAmount: 1000,
        collectedAmount: 500,
        beneficiaryCount: 10,
        location: 'طرابلس',
        isUrgent: true,
        createdAt: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 12, 1),
        status: CampaignStatus.published,
        isFeatured: true,
      );
      final restored = Campaign.fromJson(campaign.toJson());
      expect(restored.id, campaign.id);
      expect(restored.category, campaign.category);
      expect(restored.status, campaign.status);
      expect(restored.progress, campaign.progress);
    });

    test('Donation round-trips through JSON', () {
      final donation = Donation(
        id: 'd1',
        campaignId: 'c1',
        campaignTitleAr: 'علاج',
        campaignTitleEn: 'Treatment',
        charityNameAr: 'جمعية',
        charityNameEn: 'Charity',
        amount: 50,
        date: DateTime(2026, 9, 17),
        status: DonationStatus.success,
        type: DonationType.oneTime,
        paymentMethod: 'card',
        reference: 'TXN-1',
      );
      final restored = Donation.fromJson(donation.toJson());
      expect(restored.id, donation.id);
      expect(restored.reference, 'TXN-1');
      expect(restored.isSuccessful, isTrue);
    });
  });
}
