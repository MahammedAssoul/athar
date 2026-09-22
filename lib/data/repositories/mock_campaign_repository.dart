import '../mock/mock_campaigns.dart';
import '../models/campaign.dart';
import '../models/campaign_enums.dart';
import '../repositories/campaign_repository.dart';

/// In-memory campaign repository backed by mock data.
class MockCampaignRepository implements CampaignRepository {
  final List<Campaign> _campaigns = List.of(MockCampaigns.all);

  @override
  Future<List<Campaign>> getCampaigns() async => List.of(_campaigns);

  @override
  Future<List<Campaign>> getFeaturedCampaigns() async =>
      _campaigns.where((c) => c.isFeatured).toList();

  @override
  Future<List<Campaign>> getUrgentCampaigns() async =>
      _campaigns.where((c) => c.isUrgent && c.isActive).toList();

  @override
  Future<Campaign?> getCampaignById(String id) async {
    for (final c in _campaigns) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<List<Campaign>> searchCampaigns({
    String query = '',
    CampaignCategory? category,
    String? sort,
    CampaignSearchField? searchField,
    Set<CampaignFilter> filters = const {},
  }) async {
    var results = List.of(_campaigns);

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results.where((c) {
        final field = searchField ?? CampaignSearchField.title;
        return switch (field) {
          CampaignSearchField.title =>
            c.titleAr.toLowerCase().contains(q) ||
                c.titleEn.toLowerCase().contains(q),
          CampaignSearchField.charity => c.charityName.toLowerCase().contains(
            q,
          ),
          CampaignSearchField.city => c.location.toLowerCase().contains(q),
          CampaignSearchField.category =>
            c.category.name.toLowerCase().contains(q),
        };
      }).toList();
    }

    if (category != null) {
      results = results.where((c) => c.category == category).toList();
    }

    // Quick filters.
    if (filters.contains(CampaignFilter.urgent)) {
      results = results.where((c) => c.isUrgent).toList();
    }
    if (filters.contains(CampaignFilter.verified)) {
      // Mock: charities with ids ch1, ch2, ch3, ch5 are verified.
      const verifiedIds = {'ch1', 'ch2', 'ch3', 'ch5'};
      results = results
          .where((c) => verifiedIds.contains(c.charityId))
          .toList();
    }
    if (filters.contains(CampaignFilter.nearMe)) {
      // Mock: "near me" = campaigns in the user's city (Tripoli).
      results = results.where((c) => c.location == 'طرابلس').toList();
    }
    if (filters.contains(CampaignFilter.mostNeeded)) {
      // Most needed = lowest progress first.
      results.sort((a, b) => a.progress.compareTo(b.progress));
    }
    if (filters.contains(CampaignFilter.recentlyAdded)) {
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    switch (sort) {
      case CampaignSort.newest:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CampaignSort.mostCollected:
        results.sort((a, b) => b.collectedAmount.compareTo(a.collectedAmount));
        break;
      case CampaignSort.urgentFirst:
        results.sort((a, b) {
          if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    return results;
  }

  @override
  Future<Campaign> updateCampaignCollected(String id, double amount) async {
    final index = _campaigns.indexWhere((c) => c.id == id);
    final current = _campaigns[index];
    final updated = current.copyWith(
      collectedAmount: current.collectedAmount + amount,
      status: current.collectedAmount + amount >= current.targetAmount
          ? CampaignStatus.completed
          : current.status,
    );
    _campaigns[index] = updated;
    return updated;
  }
}
