import '../models/campaign.dart';
import '../models/campaign_enums.dart';

/// Contract for campaign data sources (mock or remote).
abstract class CampaignRepository {
  Future<List<Campaign>> getCampaigns();
  Future<List<Campaign>> getFeaturedCampaigns();
  Future<List<Campaign>> getUrgentCampaigns();
  Future<Campaign?> getCampaignById(String id);
  Future<List<Campaign>> searchCampaigns({
    String query = '',
    CampaignCategory? category,
    String? sort,
    CampaignSearchField? searchField,
    Set<CampaignFilter> filters = const {},
  });
  Future<Campaign> updateCampaignCollected(String id, double amount);
}

/// Sort options for campaigns.
class CampaignSort {
  CampaignSort._();

  static const String newest = 'newest';
  static const String mostCollected = 'mostCollected';
  static const String urgentFirst = 'urgentFirst';
}

/// Field the search query is matched against.
enum CampaignSearchField { title, charity, city, category }

/// Quick filter chips for the campaigns screen.
enum CampaignFilter { urgent, verified, nearMe, mostNeeded, recentlyAdded }
