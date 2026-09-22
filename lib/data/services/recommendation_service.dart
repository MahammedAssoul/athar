import '../models/campaign.dart';
import '../models/donation.dart';

/// A personalized home recommendation section.
class RecommendationSection {
  const RecommendationSection({required this.title, required this.campaigns});

  final String title;
  final List<Campaign> campaigns;
}

/// Generates personalized home recommendations from donation history.
///
/// Phase 3: simple mock logic. A real recommendation engine can replace
/// this implementation later without touching the UI.
abstract class RecommendationService {
  /// Campaigns the user has already donated to (continue donating).
  Future<List<Campaign>> continueDonating(List<Donation> donations);

  /// Campaigns matching categories the user supports.
  Future<List<Campaign>> causesYouSupport(List<Donation> donations);

  /// Recently viewed campaigns (mock: newest active campaigns).
  Future<List<Campaign>> recentlyViewed(List<Campaign> allCampaigns);

  /// Recommended campaigns based on donation history.
  Future<List<Campaign>> recommended(List<Donation> donations);
}

/// Mock recommendation service used when `isMock == true`.
class MockRecommendationService implements RecommendationService {
  const MockRecommendationService();

  @override
  Future<List<Campaign>> continueDonating(List<Donation> donations) async {
    // Mock: no-op, resolved by the home cubit with real campaign data.
    return [];
  }

  @override
  Future<List<Campaign>> causesYouSupport(List<Donation> donations) async {
    // Mock: no-op, resolved by the home cubit with real campaign data.
    return [];
  }

  @override
  Future<List<Campaign>> recentlyViewed(List<Campaign> allCampaigns) async {
    // Mock: newest active campaigns.
    final active = allCampaigns.where((c) => c.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.take(5).toList();
  }

  @override
  Future<List<Campaign>> recommended(List<Donation> donations) async {
    // Mock: no-op, resolved by the home cubit with real campaign data.
    return [];
  }
}
