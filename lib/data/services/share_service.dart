import '../models/campaign.dart';

/// Result of a share action.
class ShareResult {
  const ShareResult({required this.success, required this.message});

  final bool success;
  final String message;
}

/// Campaign sharing service.
///
/// Phase 3: mock implementation that simulates a platform share
/// (e.g. WhatsApp / Telegram / system share sheet). The interface is
/// intentionally small so a real platform integration can replace the
/// implementation without touching any UI code.
abstract class ShareService {
  /// Shares a campaign. Returns a [ShareResult] describing the outcome.
  Future<ShareResult> shareCampaign(Campaign campaign);
}

/// Mock share service used when `isMock == true`.
///
/// Simulates latency and always succeeds. In a real integration this
/// would open the system share sheet or a messaging app.
class MockShareService implements ShareService {
  const MockShareService();

  @override
  Future<ShareResult> shareCampaign(Campaign campaign) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return ShareResult(
      success: true,
      message: 'ATH-${campaign.id.toUpperCase()}',
    );
  }
}
