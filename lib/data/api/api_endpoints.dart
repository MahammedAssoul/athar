/// Central endpoint definitions.
///
/// Every backend route used by the app is declared here so URLs stay
/// consistent and easy to maintain.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String resetPassword = '/auth/reset-password';

  // ── Campaigns ─────────────────────────────────────────
  static const String campaigns = '/campaigns';
  static const String campaignCategories = '/campaigns/categories';
  static const String campaignFavorites = '/campaigns/favorites';

  /// Single campaign route: `/campaigns/{id}`.
  static String campaign(String id) => '$campaigns/$id';

  // ── Charities ─────────────────────────────────────────
  static const String charities = '/charities';

  /// Single charity route: `/charities/{id}`.
  static String charity(String id) => '$charities/$id';

  /// Campaigns of a charity: `/charities/{id}/campaigns`.
  static String charityCampaigns(String id) => '$charities/$id/campaigns';

  // ── Donations ─────────────────────────────────────────
  static const String donations = '/donations';

  /// Single donation route: `/donations/{id}`.
  static String donation(String id) => '$donations/$id';

  /// Receipt for a donation: `/donations/{id}/receipt`.
  static String donationReceipt(String id) => '$donations/$id/receipt';

  // ── Recurring donations ───────────────────────────────
  static const String recurringDonations = '/donations/recurring';

  /// Single recurring donation route: `/donations/recurring/{id}`.
  static String recurringDonation(String id) => '$recurringDonations/$id';

  // ── Gift donations ────────────────────────────────────
  static const String giftDonations = '/donations/gifts';

  // ── Notifications ─────────────────────────────────────
  static const String notifications = '/notifications';

  /// Mark a single notification as read: `/notifications/{id}/read`.
  static String notificationRead(String id) => '$notifications/$id/read';

  /// Mark all notifications as read.
  static const String notificationsReadAll = '/notifications/read-all';

  // ── Push notifications ────────────────────────────────
  static const String pushDevices = '/notifications/push/devices';

  /// Single push device: `/notifications/push/devices/{token}`.
  static String pushDevice(String token) => '$pushDevices/$token';

  static const String pushNotifications = '/notifications/push';

  /// Mark a push notification as read: `/notifications/push/{id}/read`.
  static String pushNotificationRead(String id) =>
      '$pushNotifications/$id/read';

  // ── Beneficiaries ─────────────────────────────────────
  /// Beneficiaries of a campaign: `/campaigns/{id}/beneficiaries`.
  static String campaignBeneficiaries(String campaignId) =>
      '$campaigns/$campaignId/beneficiaries';

  /// Public beneficiary count: `/campaigns/{id}/beneficiaries/count`.
  static String campaignBeneficiaryCount(String campaignId) =>
      '$campaigns/$campaignId/beneficiaries/count';

  /// Single beneficiary: `/beneficiaries/{id}`.
  static String beneficiary(String id) => '/beneficiaries/$id';

  /// Needs of a beneficiary: `/beneficiaries/{id}/needs`.
  static String beneficiaryNeeds(String id) => '/beneficiaries/$id/needs';

  /// Support history: `/beneficiaries/{id}/support`.
  static String beneficiarySupportHistory(String id) =>
      '/beneficiaries/$id/support';

  // ── Campaign lifecycle (charity/admin) ────────────────
  /// Submit a campaign for review: `/campaigns/{id}/submit`.
  static String campaignSubmit(String id) => '$campaigns/$id/submit';

  /// Approve a campaign: `/campaigns/{id}/approve`.
  static String campaignApprove(String id) => '$campaigns/$id/approve';

  /// Reject a campaign: `/campaigns/{id}/reject`.
  static String campaignReject(String id) => '$campaigns/$id/reject';

  /// Suspend a campaign: `/campaigns/{id}/suspend`.
  static String campaignSuspend(String id) => '$campaigns/$id/suspend';

  /// Transparency snapshot: `/campaigns/{id}/transparency`.
  static String campaignTransparency(String id) =>
      '$campaigns/$id/transparency';

  // ── Charity management ────────────────────────────────
  /// Charity profile: `/charities/{id}/profile`.
  static String charityProfile(String id) => '$charities/$id/profile';

  /// Charity stats: `/charities/{id}/stats`.
  static String charityStats(String id) => '$charities/$id/stats';

  // ── Platform statistics ───────────────────────────────
  static const String platformStats = '/stats/platform';

  // ── Reports ───────────────────────────────────────────
  static const String reports = '/reports';

  // ── Security & audit ──────────────────────────────────
  static const String auditLogs = '/security/audit-logs';
  static const String sessions = '/security/sessions';

  /// Single session: `/security/sessions/{id}`.
  static String session(String id) => '$sessions/$id';

  // ── Observability ─────────────────────────────────────
  static const String observabilityLogs = '/observability/logs';
  static const String observabilityCrashes = '/observability/crashes';
  static const String observabilityEvents = '/observability/events';
}
