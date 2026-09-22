import '../mock/mock_platform_stats.dart';
import '../models/platform_stats.dart';
import '../repositories/platform_stats_repository.dart';

/// In-memory platform statistics backed by mock data.
class MockPlatformStatsRepository implements PlatformStatsRepository {
  @override
  Future<PlatformStats> getPlatformStats() async => MockPlatformStats.current;

  @override
  Future<CampaignTransparency> getCampaignTransparency(
    String campaignId,
  ) async {
    // Demo transparency data for c1; a generic snapshot otherwise.
    if (campaignId == 'c1') return MockPlatformStats.campaignC1Transparency;
    return CampaignTransparency(
      campaignId: campaignId,
      targetAmount: 10000,
      collectedAmount: 5000,
      donorCount: 80,
      beneficiaryCount: 10,
      status: 'published',
    );
  }
}
