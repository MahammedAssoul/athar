import '../models/platform_stats.dart';

/// Demo platform statistics. Fictional data for Phase 5 only.
class MockPlatformStats {
  MockPlatformStats._();

  static final PlatformStats current = PlatformStats(
    totalDonations: 1250000,
    monthlyDonations: 96000,
    donorCount: 18400,
    campaignCount: 320,
    charityCount: 45,
    beneficiaryCount: 12500,
    successfulCampaigns: 87,
    updatedAt: DateTime(2026, 9, 18),
  );

  /// Demo progress history for campaign c1 (Mariam's treatment).
  static final List<CampaignProgressPoint> campaignC1History = [
    CampaignProgressPoint(
      campaignId: 'c1',
      date: DateTime(2026, 8, 20),
      collectedAmount: 0,
      donorCount: 0,
    ),
    CampaignProgressPoint(
      campaignId: 'c1',
      date: DateTime(2026, 8, 27),
      collectedAmount: 3200,
      donorCount: 41,
    ),
    CampaignProgressPoint(
      campaignId: 'c1',
      date: DateTime(2026, 9, 3),
      collectedAmount: 7800,
      donorCount: 98,
    ),
    CampaignProgressPoint(
      campaignId: 'c1',
      date: DateTime(2026, 9, 10),
      collectedAmount: 12400,
      donorCount: 156,
    ),
    CampaignProgressPoint(
      campaignId: 'c1',
      date: DateTime(2026, 9, 17),
      collectedAmount: 16250,
      donorCount: 214,
    ),
  ];

  static final CampaignTransparency campaignC1Transparency =
      CampaignTransparency(
        campaignId: 'c1',
        targetAmount: 25000,
        collectedAmount: 16250,
        donorCount: 214,
        beneficiaryCount: 1,
        status: 'published',
        history: campaignC1History,
      );
}
