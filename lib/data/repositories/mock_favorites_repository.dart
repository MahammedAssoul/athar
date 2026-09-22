import '../repositories/favorites_repository.dart';
import '../services/local_storage.dart';

/// Favorites repository persisted locally via [LocalStorage].
///
/// Works in mock mode and keeps favorites across app restarts.
class MockFavoritesRepository implements FavoritesRepository {
  @override
  Future<List<String>> getFavoriteIds() => LocalStorage.getFavoriteIds();

  @override
  Future<bool> isFavorite(String campaignId) =>
      LocalStorage.isFavorite(campaignId);

  @override
  Future<void> addFavorite(String campaignId) =>
      LocalStorage.addFavorite(campaignId);

  @override
  Future<void> removeFavorite(String campaignId) =>
      LocalStorage.removeFavorite(campaignId);
}
