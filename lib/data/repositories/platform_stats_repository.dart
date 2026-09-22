import '../models/platform_stats.dart';

/// Contract for platform statistics (mock or remote).
///
/// These endpoints are public and safe — they only expose aggregated
/// numbers, never donor identities or beneficiary personal data.
abstract class PlatformStatsRepository {
  /// Public platform-wide statistics.
  Future<PlatformStats> getPlatformStats();

  /// Transparency snapshot for a single campaign.
  Future<CampaignTransparency> getCampaignTransparency(String campaignId);
}
