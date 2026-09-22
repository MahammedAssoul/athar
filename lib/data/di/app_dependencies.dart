import '../api/api_client.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/api_beneficiary_repository.dart';
import '../repositories/api_campaign_repository.dart';
import '../repositories/api_charity_management_repository.dart';
import '../repositories/api_charity_repository.dart';
import '../repositories/api_donation_repository.dart';
import '../repositories/api_favorites_repository.dart';
import '../repositories/api_gift_donation_repository.dart';
import '../repositories/api_notification_repository.dart';
import '../repositories/api_platform_stats_repository.dart';
import '../repositories/api_recurring_donation_repository.dart';
import '../repositories/api_report_repository.dart';
import '../repositories/api_security_repository.dart';
import '../repositories/api_user_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/beneficiary_repository.dart';
import '../repositories/campaign_repository.dart';
import '../repositories/charity_management_repository.dart';
import '../repositories/charity_repository.dart';
import '../repositories/donation_repository.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/gift_donation_repository.dart';
import '../repositories/mock_auth_repository.dart';
import '../repositories/mock_beneficiary_repository.dart';
import '../repositories/mock_campaign_repository.dart';
import '../repositories/mock_charity_management_repository.dart';
import '../repositories/mock_charity_repository.dart';
import '../repositories/mock_donation_repository.dart';
import '../repositories/mock_favorites_repository.dart';
import '../repositories/mock_gift_donation_repository.dart';
import '../repositories/mock_notification_repository.dart';
import '../repositories/mock_platform_stats_repository.dart';
import '../repositories/mock_recurring_donation_repository.dart';
import '../repositories/mock_report_repository.dart';
import '../repositories/mock_security_repository.dart';
import '../repositories/mock_user_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/platform_stats_repository.dart';
import '../repositories/recurring_donation_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/security_repository.dart';
import '../repositories/user_repository.dart';
import '../services/impact_service.dart';
import '../services/notification_service.dart';
import '../services/observability_service.dart';
import '../services/payment_gateway.dart';
import '../services/receipt_service.dart';
import '../services/recommendation_service.dart';
import '../services/share_service.dart';
import '../services/zakat_calculator.dart';

/// Central dependency container.
///
/// The single `isMock` flag decides whether mock or real
/// API repositories are provided. Widgets never know where the
/// data comes from — the UI is identical in both modes.
class AppDependencies {
  AppDependencies._();

  /// Flag set by `main.dart`. Defaults to [true] so the app (and tests)
  /// always run in mock mode unless explicitly switched.
  static bool isMock = true;

  static AppDependencies _instance = AppDependencies._();

  /// The shared dependency container.
  static AppDependencies get instance => _instance;

  /// Recreates the container. Used by tests when switching `isMock`.
  static void reset() {
    _instance = AppDependencies._();
  }

  /// Shared HTTP client used by all API repositories.
  late final ApiClient apiClient = ApiClient();

  late final AuthRepository authRepository = isMock
      ? MockAuthRepository()
      : ApiAuthRepository(client: apiClient);
  late final CampaignRepository campaignRepository = isMock
      ? MockCampaignRepository()
      : ApiCampaignRepository(client: apiClient);
  late final CharityRepository charityRepository = isMock
      ? MockCharityRepository()
      : ApiCharityRepository(client: apiClient);
  late final DonationRepository donationRepository = isMock
      ? MockDonationRepository()
      : ApiDonationRepository(client: apiClient);
  late final NotificationRepository notificationRepository = isMock
      ? MockNotificationRepository()
      : ApiNotificationRepository(client: apiClient);
  late final UserRepository userRepository = isMock
      ? MockUserRepository()
      : ApiUserRepository(client: apiClient);
  late final RecurringDonationRepository recurringDonationRepository = isMock
      ? MockRecurringDonationRepository()
      : ApiRecurringDonationRepository(client: apiClient);
  late final GiftDonationRepository giftDonationRepository = isMock
      ? MockGiftDonationRepository()
      : ApiGiftDonationRepository(client: apiClient);
  late final FavoritesRepository favoritesRepository = isMock
      ? MockFavoritesRepository()
      : ApiFavoritesRepository(client: apiClient);

  // ── Phase 5: platform ecosystem ───────────────────────
  late final BeneficiaryRepository beneficiaryRepository = isMock
      ? MockBeneficiaryRepository()
      : ApiBeneficiaryRepository(client: apiClient);
  late final PlatformStatsRepository platformStatsRepository = isMock
      ? MockPlatformStatsRepository()
      : ApiPlatformStatsRepository(client: apiClient);
  late final CharityManagementRepository charityManagementRepository = isMock
      ? MockCharityManagementRepository()
      : ApiCharityManagementRepository(client: apiClient);
  late final ReportRepository reportRepository = isMock
      ? MockReportRepository()
      : ApiReportRepository(client: apiClient);
  late final SecurityRepository securityRepository = isMock
      ? MockSecurityRepository()
      : ApiSecurityRepository(client: apiClient);

  /// Payment gateway — the UI only depends on the [PaymentGateway]
  /// abstraction, so providers can be swapped without UI changes.
  late final PaymentGateway paymentGateway = isMock
      ? const MockPaymentGateway()
      : const RealPaymentGateway();

  late final ShareService shareService = isMock
      ? const MockShareService()
      : _unimplemented();
  late final ReceiptService receiptService = isMock
      ? const MockReceiptService()
      : _unimplemented();
  late final RecommendationService recommendationService = isMock
      ? const MockRecommendationService()
      : _unimplemented();
  late final ImpactService impactService = isMock
      ? const MockImpactService()
      : _unimplemented();
  late final ZakatCalculator zakatCalculator = isMock
      ? const ZakatCalculator()
      : _unimplemented();

  // ── Phase 5: observability & notifications ────────────
  late final ObservabilityService observabilityService = isMock
      ? const MockObservabilityService()
      : const ApiObservabilityService();
  late final NotificationService notificationService = isMock
      ? MockNotificationService()
      : ApiNotificationService();

  Never _unimplemented() {
    throw UnimplementedError(
      'Real implementation not available yet. Set isMock = true.',
    );
  }
}
