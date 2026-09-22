import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/platform_stats.dart';
import '../repositories/platform_stats_repository.dart';

/// Real platform statistics repository backed by the Athar backend.
///
/// These endpoints are public and only expose aggregated numbers.
class ApiPlatformStatsRepository implements PlatformStatsRepository {
  ApiPlatformStatsRepository({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<PlatformStats> getPlatformStats() async {
    final data = await _client.get(
      ApiEndpoints.platformStats,
      authenticated: false,
    );
    return PlatformStats.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CampaignTransparency> getCampaignTransparency(
    String campaignId,
  ) async {
    final data = await _client.get(
      ApiEndpoints.campaignTransparency(campaignId),
      authenticated: false,
    );
    return CampaignTransparency.fromJson(data as Map<String, dynamic>);
  }
}
