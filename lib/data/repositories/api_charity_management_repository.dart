import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/campaign.dart';
import '../models/charity_profile.dart';
import '../repositories/charity_management_repository.dart';

/// Real charity management repository backed by the Athar backend.
///
/// Used by the charity dashboard (separate app/web). The backend
/// enforces role-based access: only the owning charity or platform
/// admins can call these endpoints.
class ApiCharityManagementRepository implements CharityManagementRepository {
  ApiCharityManagementRepository({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<CharityProfile?> getCharityProfile(String charityId) async {
    final data = await _client.get(ApiEndpoints.charityProfile(charityId));
    return CharityProfile.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CharityDonationStats> getCharityStats(String charityId) async {
    final data = await _client.get(ApiEndpoints.charityStats(charityId));
    return CharityDonationStats.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Campaign> submitCampaign(Campaign campaign) async {
    final data = await _client.post(
      ApiEndpoints.campaignSubmit(campaign.id),
      body: campaign.toJson(),
    );
    return Campaign.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Campaign> updateDraftCampaign(Campaign campaign) async {
    final data = await _client.put(
      ApiEndpoints.campaign(campaign.id),
      body: campaign.toJson(),
    );
    return Campaign.fromJson(data as Map<String, dynamic>);
  }
}
