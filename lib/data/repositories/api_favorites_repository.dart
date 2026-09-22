import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../repositories/favorites_repository.dart';

/// Real favorites repository backed by the Athar backend.
class ApiFavoritesRepository implements FavoritesRepository {
  ApiFavoritesRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<String>> getFavoriteIds() async {
    final data = await _client.get(ApiEndpoints.campaignFavorites);
    if (data is! List) {
      throw const ApiException(ApiErrorType.validation);
    }
    return data.map((e) => e.toString()).toList();
  }

  @override
  Future<bool> isFavorite(String campaignId) async {
    final ids = await getFavoriteIds();
    return ids.contains(campaignId);
  }

  @override
  Future<void> addFavorite(String campaignId) async {
    await _client.post(
      ApiEndpoints.campaignFavorites,
      body: {'campaignId': campaignId},
    );
  }

  @override
  Future<void> removeFavorite(String campaignId) async {
    await _client.delete('${ApiEndpoints.campaignFavorites}/$campaignId');
  }
}
