/// Contract for campaign favorites (mock or remote).
abstract class FavoritesRepository {
  Future<List<String>> getFavoriteIds();
  Future<bool> isFavorite(String campaignId);
  Future<void> addFavorite(String campaignId);
  Future<void> removeFavorite(String campaignId);
}
