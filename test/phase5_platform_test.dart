import 'dart:convert';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:athar/data/api/api_client.dart';
import 'package:athar/data/api/api_config.dart';
import 'package:athar/data/config/app_environment.dart';
import 'package:athar/data/di/app_dependencies.dart';
import 'package:athar/data/models/beneficiary.dart';
import 'package:athar/data/models/campaign.dart';
import 'package:athar/data/models/campaign_enums.dart';
import 'package:athar/data/models/charity_profile.dart';
import 'package:athar/data/models/donation.dart';
import 'package:athar/data/models/platform_stats.dart';
import 'package:athar/data/models/push_notification.dart';
import 'package:athar/data/models/report.dart';
import 'package:athar/data/models/security.dart';
import 'package:athar/data/repositories/api_beneficiary_repository.dart';
import 'package:athar/data/repositories/api_platform_stats_repository.dart';
import 'package:athar/data/repositories/api_report_repository.dart';
import 'package:athar/data/repositories/api_security_repository.dart';
import 'package:athar/data/repositories/mock_beneficiary_repository.dart';
import 'package:athar/data/repositories/mock_charity_management_repository.dart';
import 'package:athar/data/repositories/mock_platform_stats_repository.dart';
import 'package:athar/data/repositories/mock_report_repository.dart';
import 'package:athar/data/repositories/mock_security_repository.dart';
import 'package:athar/data/services/notification_service.dart';
import 'package:athar/data/services/observability_service.dart';

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

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      <String, String>{},
    );
    ApiConfig.baseUrlOverride = 'https://test.athar.ly';
    AppDependencies.isMock = true;
    RateLimiter.reset();
    MockObservabilityService.reset();
  });

  tearDown(() {
    ApiConfig.baseUrlOverride = null;
  });

  group('Campaign lifecycle', () {
    test('legacy active status maps to published', () {
      final campaign = Campaign.fromJson({
        'id': 'c1',
        'titleAr': 'علاج',
        'titleEn': 'Treatment',
        'descriptionAr': '',
        'descriptionEn': '',
        'imageUrl': '',
        'charityId': 'ch1',
        'charityName': 'جمعية',
        'category': 'treatment',
        'targetAmount': 1000,
        'collectedAmount': 500,
        'beneficiaryCount': 1,
        'location': 'طرابلس',
        'isUrgent': false,
        'createdAt': '2026-09-01T00:00:00.000',
        'endDate': '2026-12-01T00:00:00.000',
        'status': 'active',
      });
      expect(campaign.status, CampaignStatus.published);
      expect(campaign.isActive, isTrue);
    });

    test('legacy closed status maps to completed', () {
      final campaign = Campaign.fromJson({
        'id': 'c2',
        'titleAr': 'سلة',
        'titleEn': 'Basket',
        'descriptionAr': '',
        'descriptionEn': '',
        'imageUrl': '',
        'charityId': 'ch2',
        'charityName': 'جمعية',
        'category': 'food',
        'targetAmount': 1000,
        'collectedAmount': 1000,
        'beneficiaryCount': 10,
        'location': 'بنغازي',
        'isUrgent': false,
        'createdAt': '2026-09-01T00:00:00.000',
        'endDate': '2026-12-01T00:00:00.000',
        'status': 'closed',
      });
      expect(campaign.status, CampaignStatus.completed);
      expect(campaign.isActive, isFalse);
    });

    test('full lifecycle statuses parse correctly', () {
      for (final status in CampaignStatus.values) {
        final campaign = Campaign.fromJson({
          'id': 'c1',
          'titleAr': 'علاج',
          'titleEn': 'Treatment',
          'descriptionAr': '',
          'descriptionEn': '',
          'imageUrl': '',
          'charityId': 'ch1',
          'charityName': 'جمعية',
          'category': 'treatment',
          'targetAmount': 1000,
          'collectedAmount': 0,
          'beneficiaryCount': 1,
          'location': 'طرابلس',
          'isUrgent': false,
          'createdAt': '2026-09-01T00:00:00.000',
          'endDate': '2026-12-01T00:00:00.000',
          'status': status.name,
        });
        expect(campaign.status, status);
      }
    });

    test('only published campaigns are active', () {
      expect(CampaignStatus.published.isActive, isTrue);
      expect(CampaignStatus.draft.isActive, isFalse);
      expect(CampaignStatus.submitted.isActive, isFalse);
      expect(CampaignStatus.underReview.isActive, isFalse);
      expect(CampaignStatus.approved.isActive, isFalse);
      expect(CampaignStatus.completed.isActive, isFalse);
      expect(CampaignStatus.rejected.isActive, isFalse);
      expect(CampaignStatus.suspended.isActive, isFalse);
    });

    test('charity cannot publish directly — submit goes to review', () async {
      final repo = MockCharityManagementRepository();
      final draft = Campaign(
        id: 'c99',
        titleAr: 'حملة جديدة',
        titleEn: 'New campaign',
        descriptionAr: 'وصف',
        descriptionEn: 'Desc',
        imageUrl: '',
        charityId: 'ch1',
        charityName: 'جمعية الأمل',
        category: CampaignCategory.emergency,
        targetAmount: 5000,
        collectedAmount: 0,
        beneficiaryCount: 10,
        location: 'طرابلس',
        isUrgent: true,
        createdAt: DateTime.now(),
        endDate: DateTime(2026, 12, 31),
        status: CampaignStatus.draft,
      );
      final submitted = await repo.submitCampaign(draft);
      expect(submitted.status, CampaignStatus.submitted);
      expect(submitted.status.isActive, isFalse);
    });
  });

  group('Beneficiary management', () {
    test('mock beneficiaries are filtered by campaign', () async {
      final repo = MockBeneficiaryRepository();
      final beneficiaries = await repo.getBeneficiaries('c1');
      expect(beneficiaries, isNotEmpty);
      expect(beneficiaries.every((b) => b.campaignId == 'c1'), isTrue);
    });

    test('beneficiary count is public and safe', () async {
      final repo = MockBeneficiaryRepository();
      final count = await repo.getBeneficiaryCount('c1');
      expect(count, greaterThan(0));
    });

    test('beneficiary needs and support history load', () async {
      final repo = MockBeneficiaryRepository();
      final needs = await repo.getNeeds('b1');
      expect(needs, isNotEmpty);
      final history = await repo.getSupportHistory('b1');
      expect(history, isNotEmpty);
    });

    test('beneficiary round-trips through JSON', () {
      final beneficiary = Beneficiary(
        id: 'b1',
        campaignId: 'c1',
        charityId: 'ch1',
        fullName: 'مريم أحمد',
        category: CaseCategory.medical,
        verificationStatus: BeneficiaryVerificationStatus.verified,
        age: 4,
        isMinor: true,
        supportAmount: 16250,
        supportCount: 214,
        createdAt: DateTime(2026, 8, 20),
      );
      final restored = Beneficiary.fromJson(beneficiary.toJson());
      expect(restored.id, beneficiary.id);
      expect(restored.category, beneficiary.category);
      expect(restored.verificationStatus, beneficiary.verificationStatus);
      expect(restored.isMinor, isTrue);
    });

    test('ApiBeneficiaryRepository parses list', () async {
      final client = ApiClient(
        client: _jsonClient([
          {
            'id': 'b1',
            'campaignId': 'c1',
            'charityId': 'ch1',
            'fullName': 'مريم',
            'category': 'medical',
            'verificationStatus': 'verified',
            'isMinor': true,
          },
        ]),
      );
      final repo = ApiBeneficiaryRepository(client: client);
      final beneficiaries = await repo.getBeneficiaries('c1');
      expect(beneficiaries, hasLength(1));
      expect(beneficiaries.first.category, CaseCategory.medical);
    });
  });

  group('Platform statistics & transparency', () {
    test('mock platform stats load', () async {
      final repo = MockPlatformStatsRepository();
      final stats = await repo.getPlatformStats();
      expect(stats.totalDonations, greaterThan(0));
      expect(stats.donorCount, greaterThan(0));
      expect(stats.campaignCount, greaterThan(0));
    });

    test('campaign transparency exposes progress history', () async {
      final repo = MockPlatformStatsRepository();
      final transparency = await repo.getCampaignTransparency('c1');
      expect(transparency.targetAmount, 25000);
      expect(transparency.collectedAmount, 16250);
      expect(transparency.donorCount, 214);
      expect(transparency.history, isNotEmpty);
    });

    test('platform stats round-trip through JSON', () {
      final stats = PlatformStats(
        totalDonations: 1250000,
        monthlyDonations: 96000,
        donorCount: 18400,
        campaignCount: 320,
        charityCount: 45,
        beneficiaryCount: 12500,
        successfulCampaigns: 87,
        updatedAt: DateTime(2026, 9, 18),
      );
      final restored = PlatformStats.fromJson(stats.toJson());
      expect(restored.totalDonations, stats.totalDonations);
      expect(restored.donorCount, stats.donorCount);
    });

    test('ApiPlatformStatsRepository parses stats', () async {
      final client = ApiClient(
        client: _jsonClient({
          'totalDonations': 1000,
          'monthlyDonations': 100,
          'donorCount': 50,
          'campaignCount': 10,
          'charityCount': 5,
          'beneficiaryCount': 200,
          'successfulCampaigns': 3,
          'updatedAt': '2026-09-18T00:00:00.000',
        }),
      );
      final repo = ApiPlatformStatsRepository(client: client);
      final stats = await repo.getPlatformStats();
      expect(stats.totalDonations, 1000);
      expect(stats.donorCount, 50);
    });
  });

  group('Charity management', () {
    test('charity profile loads', () async {
      final repo = MockCharityManagementRepository();
      final profile = await repo.getCharityProfile('ch1');
      expect(profile, isNotNull);
      expect(profile!.isVerified, isTrue);
    });

    test('charity stats load', () async {
      final repo = MockCharityManagementRepository();
      final stats = await repo.getCharityStats('ch1');
      expect(stats.totalDonations, greaterThan(0));
      expect(stats.donorCount, greaterThan(0));
    });

    test('charity profile round-trips through JSON', () {
      final profile = CharityProfile(
        id: 'ch1',
        nameAr: 'جمعية الأمل',
        nameEn: 'Al-Amal',
        description: 'وصف',
        verificationStatus: CharityVerificationStatus.verified,
        campaignCount: 12,
        totalRaised: 240000,
        beneficiaryCount: 850,
      );
      final restored = CharityProfile.fromJson(profile.toJson());
      expect(restored.id, profile.id);
      expect(restored.isVerified, isTrue);
    });
  });

  group('Reports', () {
    test('mock reports load by type', () async {
      final repo = MockReportRepository();
      final donations = await repo.getDonationReports(ReportPeriod.monthly);
      expect(donations, isNotEmpty);
      final campaigns = await repo.getCampaignReports(ReportPeriod.annual);
      expect(campaigns, isNotEmpty);
      final charities = await repo.getCharityReports(ReportPeriod.monthly);
      expect(charities, isNotEmpty);
    });

    test('donation receipt loads', () async {
      final repo = MockReportRepository();
      final receipt = await repo.getDonationReceipt('d1');
      expect(receipt.receiptNumber, isNotEmpty);
      expect(receipt.amount, greaterThan(0));
    });

    test('report round-trips through JSON', () {
      final report = Report(
        id: 'r1',
        titleAr: 'تقرير',
        titleEn: 'Report',
        period: ReportPeriod.monthly,
        generatedAt: DateTime(2026, 9, 1),
        rows: [ReportRow(label: 'سبتمبر', value: 100)],
        total: 100,
      );
      final restored = Report.fromJson(report.toJson());
      expect(restored.id, report.id);
      expect(restored.rows, hasLength(1));
      expect(restored.total, 100);
    });

    test('ApiReportRepository parses report list', () async {
      final client = ApiClient(
        client: _jsonClient([
          {
            'id': 'r1',
            'titleAr': 'تقرير',
            'titleEn': 'Report',
            'period': 'monthly',
            'generatedAt': '2026-09-01T00:00:00.000',
            'rows': [
              {'label': 'سبتمبر', 'value': 100},
            ],
            'total': 100,
            'format': 'json',
          },
        ]),
      );
      final repo = ApiReportRepository(client: client);
      final reports = await repo.getDonationReports(ReportPeriod.monthly);
      expect(reports, hasLength(1));
      expect(reports.first.total, 100);
    });
  });

  group('Security & fraud', () {
    test('rate limiter allows within window and blocks after', () {
      RateLimiter.reset();
      for (var i = 0; i < 5; i++) {
        final result = RateLimiter.check('otp:0912345678', maxRequests: 5);
        expect(result.allowed, isTrue);
      }
      final blocked = RateLimiter.check('otp:0912345678', maxRequests: 5);
      expect(blocked.allowed, isFalse);
      expect(blocked.retryAfterSeconds, greaterThan(0));
    });

    test('rate limiter resets', () {
      RateLimiter.reset();
      final first = RateLimiter.check('key', maxRequests: 1);
      expect(first.allowed, isTrue);
      final second = RateLimiter.check('key', maxRequests: 1);
      expect(second.allowed, isFalse);
      RateLimiter.reset();
      final afterReset = RateLimiter.check('key', maxRequests: 1);
      expect(afterReset.allowed, isTrue);
    });

    test('duplicate donation detection flags repeats', () async {
      final now = DateTime.now();
      final recent = [
        Donation(
          id: 'd1',
          campaignId: 'c1',
          campaignTitleAr: 'علاج',
          campaignTitleEn: 'Treatment',
          charityNameAr: 'جمعية',
          charityNameEn: 'Charity',
          amount: 50,
          date: now.subtract(const Duration(minutes: 1)),
          status: DonationStatus.success,
          type: DonationType.oneTime,
          paymentMethod: 'card',
        ),
      ];
      final result = await FraudDetector.checkDuplicateDonation(
        campaignId: 'c1',
        amount: 50,
        recentDonations: recent,
      );
      expect(result.allowed, isFalse);
      expect(result.flags, contains(FraudFlag.duplicateDonation));
    });

    test('unusual amount detection flags large donations', () async {
      final result = await FraudDetector.checkUnusualAmount(amount: 10000);
      expect(result.allowed, isFalse);
      expect(result.flags, contains(FraudFlag.unusualAmount));
    });

    test('audit log round-trips through JSON', () {
      final entry = AuditLogEntry(
        id: 'a1',
        actorId: 'u1',
        action: 'donation.created',
        resource: 'donation/d1',
        severity: AuditSeverity.info,
        timestamp: DateTime(2026, 9, 15),
        details: {'amount': 50},
      );
      final restored = AuditLogEntry.fromJson(entry.toJson());
      expect(restored.id, entry.id);
      expect(restored.severity, AuditSeverity.info);
    });

    test('mock security repository returns sessions and logs', () async {
      final repo = MockSecurityRepository();
      final logs = await repo.getAuditLogs();
      expect(logs, isNotEmpty);
      final sessions = await repo.getActiveSessions();
      expect(sessions, isNotEmpty);
      expect(sessions.first.isCurrent, isTrue);
    });

    test('ApiSecurityRepository parses sessions', () async {
      final client = ApiClient(
        client: _jsonClient([
          {
            'id': 's1',
            'deviceName': 'iPhone',
            'lastActiveAt': '2026-09-18T00:00:00.000',
            'isCurrent': true,
            'location': 'طرابلس',
          },
        ]),
      );
      final repo = ApiSecurityRepository(client: client);
      final sessions = await repo.getActiveSessions();
      expect(sessions, hasLength(1));
      expect(sessions.first.isCurrent, isTrue);
    });
  });

  group('Observability', () {
    test('mock observability records logs, crashes and events', () async {
      MockObservabilityService.reset();
      const service = MockObservabilityService();
      await service.log(
        LogEntry(
          level: LogLevel.info,
          message: 'donation created',
          timestamp: DateTime.now(),
          category: 'donation',
        ),
      );
      await service.trackEvent('donation_started');
      await service.reportCrash(StateError('boom'), context: 'home');
      expect(MockObservabilityService.entries, hasLength(1));
      expect(MockObservabilityService.events, contains('donation_started'));
      expect(MockObservabilityService.crashes, hasLength(1));
    });

    test('sensitive data is redacted before logging', () {
      final redacted = SensitiveDataRedactor.redact({
        'phone': '0912345678',
        'otp': '1234',
        'cardNumber': '4111111111111111',
        'cvv': '123',
        'accessToken': 'abc',
        'amount': 50,
        'nested': {'password': 'secret', 'city': 'طرابلس'},
      });
      expect(redacted['otp'], '***');
      expect(redacted['cardNumber'], '***');
      expect(redacted['cvv'], '***');
      expect(redacted['accessToken'], '***');
      expect(redacted['amount'], 50);
      expect((redacted['nested'] as Map)['password'], '***');
      expect((redacted['nested'] as Map)['city'], 'طرابلس');
    });
  });

  group('Push notifications', () {
    test('mock notification service returns demo notifications', () async {
      final service = MockNotificationService();
      final notifications = await service.getNotifications();
      expect(notifications, isNotEmpty);
      expect(
        notifications.first.type,
        PushNotificationType.donationConfirmation,
      );
    });

    test('mark as read updates notification', () async {
      final service = MockNotificationService();
      final updated = await service.markAsRead('p1');
      expect(updated.isRead, isTrue);
    });

    test('push notification round-trips through JSON', () {
      final notification = PushNotification(
        id: 'p1',
        type: PushNotificationType.securityAlert,
        titleAr: 'تنبيه',
        titleEn: 'Alert',
        bodyAr: 'جسم',
        bodyEn: 'Body',
        createdAt: DateTime(2026, 9, 12),
        deepLink: '/security',
      );
      final restored = PushNotification.fromJson(notification.toJson());
      expect(restored.id, notification.id);
      expect(restored.type, PushNotificationType.securityAlert);
      expect(restored.deepLink, '/security');
    });
  });

  group('Environment configuration', () {
    test('environment config applies base URL', () {
      AppEnvironment.apply(ApiEnvironment.dev);
      expect(ApiConfig.effectiveBaseUrl, 'https://dev-api.athar.ly');
      expect(AppEnvironment.isDev, isTrue);

      AppEnvironment.apply(ApiEnvironment.prod);
      expect(ApiConfig.effectiveBaseUrl, 'https://api.athar.ly');
      expect(AppEnvironment.isProd, isTrue);
    });

    test('logging config differs per environment', () {
      expect(LoggingConfig.minLevel(ApiEnvironment.dev), LogLevel.debug);
      expect(LoggingConfig.minLevel(ApiEnvironment.prod), LogLevel.warning);
      expect(LoggingConfig.remoteLoggingEnabled(ApiEnvironment.dev), isFalse);
      expect(LoggingConfig.remoteLoggingEnabled(ApiEnvironment.prod), isTrue);
    });

    test('notification config disables SMS in dev', () {
      expect(NotificationConfig.smsEnabled(ApiEnvironment.dev), isFalse);
      expect(NotificationConfig.smsEnabled(ApiEnvironment.prod), isTrue);
      expect(NotificationConfig.pushEnabled(ApiEnvironment.dev), isFalse);
      expect(NotificationConfig.pushEnabled(ApiEnvironment.prod), isTrue);
    });
  });

  group('DI wiring', () {
    test('DI resolves new mock repositories when isMock = true', () {
      AppDependencies.isMock = true;
      AppDependencies.reset();
      expect(
        AppDependencies.instance.beneficiaryRepository,
        isA<MockBeneficiaryRepository>(),
      );
      expect(
        AppDependencies.instance.platformStatsRepository,
        isA<MockPlatformStatsRepository>(),
      );
      expect(
        AppDependencies.instance.reportRepository,
        isA<MockReportRepository>(),
      );
      expect(
        AppDependencies.instance.securityRepository,
        isA<MockSecurityRepository>(),
      );
    });

    test('DI resolves API repositories when isMock = false', () {
      AppDependencies.isMock = false;
      AppDependencies.reset();
      expect(
        AppDependencies.instance.beneficiaryRepository,
        isA<ApiBeneficiaryRepository>(),
      );
      expect(
        AppDependencies.instance.platformStatsRepository,
        isA<ApiPlatformStatsRepository>(),
      );
      expect(
        AppDependencies.instance.reportRepository,
        isA<ApiReportRepository>(),
      );
      expect(
        AppDependencies.instance.securityRepository,
        isA<ApiSecurityRepository>(),
      );
    });
  });
}
