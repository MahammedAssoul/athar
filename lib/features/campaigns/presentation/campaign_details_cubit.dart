import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/charity.dart';

/// Campaign details state.
class CampaignDetailsState {
  const CampaignDetailsState({
    this.loading = true,
    this.error = false,
    this.campaign,
    this.charity,
    this.isFavorite = false,
  });

  final bool loading;
  final bool error;
  final Campaign? campaign;
  final Charity? charity;
  final bool isFavorite;

  CampaignDetailsState copyWith({
    bool? loading,
    bool? error,
    Campaign? campaign,
    Charity? charity,
    bool? isFavorite,
  }) {
    return CampaignDetailsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      campaign: campaign ?? this.campaign,
      charity: charity ?? this.charity,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Loads a campaign and its associated charity.
class CampaignDetailsCubit extends Cubit<CampaignDetailsState> {
  CampaignDetailsCubit(this.campaignId) : super(const CampaignDetailsState());

  final String campaignId;

  Future<void> load() async {
    emit(const CampaignDetailsState(loading: true));
    try {
      final deps = AppDependencies.instance;
      final campaign = await deps.campaignRepository.getCampaignById(
        campaignId,
      );
      final charity = campaign == null
          ? null
          : await deps.charityRepository.getCharityById(campaign.charityId);
      final isFavorite = campaign == null
          ? false
          : await deps.favoritesRepository.isFavorite(campaignId);
      emit(
        CampaignDetailsState(
          loading: false,
          campaign: campaign,
          charity: charity,
          isFavorite: isFavorite,
        ),
      );
    } catch (_) {
      emit(const CampaignDetailsState(loading: false, error: true));
    }
  }

  Future<void> toggleFavorite() async {
    final deps = AppDependencies.instance;
    if (state.isFavorite) {
      await deps.favoritesRepository.removeFavorite(campaignId);
    } else {
      await deps.favoritesRepository.addFavorite(campaignId);
    }
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }
}
