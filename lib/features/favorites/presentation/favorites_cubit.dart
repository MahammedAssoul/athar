import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';

/// Favorites state.
class FavoritesState {
  const FavoritesState({
    this.loading = true,
    this.error = false,
    this.campaigns = const [],
  });

  final bool loading;
  final bool error;
  final List<Campaign> campaigns;

  FavoritesState copyWith({
    bool? loading,
    bool? error,
    List<Campaign>? campaigns,
  }) {
    return FavoritesState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      campaigns: campaigns ?? this.campaigns,
    );
  }
}

/// Loads favorite campaigns and supports add/remove.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState());

  Future<void> load() async {
    emit(const FavoritesState(loading: true));
    try {
      final deps = AppDependencies.instance;
      final ids = await deps.favoritesRepository.getFavoriteIds();
      final all = await deps.campaignRepository.getCampaigns();
      final campaigns = all.where((c) => ids.contains(c.id)).toList();
      emit(FavoritesState(loading: false, campaigns: campaigns));
    } catch (_) {
      emit(const FavoritesState(loading: false, error: true));
    }
  }

  Future<void> remove(String campaignId) async {
    await AppDependencies.instance.favoritesRepository.removeFavorite(
      campaignId,
    );
    emit(
      state.copyWith(
        campaigns: state.campaigns.where((c) => c.id != campaignId).toList(),
      ),
    );
  }
}
