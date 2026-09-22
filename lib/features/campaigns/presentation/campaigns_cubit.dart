import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/campaign_enums.dart';
import '../../../data/repositories/campaign_repository.dart';

/// Campaigns list state.
class CampaignsState {
  const CampaignsState({
    this.loading = true,
    this.error = false,
    this.query = '',
    this.category,
    this.sort,
    this.searchField,
    this.filters = const {},
    this.campaigns = const [],
  });

  final bool loading;
  final bool error;
  final String query;
  final CampaignCategory? category;
  final String? sort;
  final CampaignSearchField? searchField;
  final Set<CampaignFilter> filters;
  final List<Campaign> campaigns;

  CampaignsState copyWith({
    bool? loading,
    bool? error,
    String? query,
    CampaignCategory? category,
    String? sort,
    CampaignSearchField? searchField,
    Set<CampaignFilter>? filters,
    List<Campaign>? campaigns,
  }) {
    return CampaignsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      query: query ?? this.query,
      category: category,
      sort: sort ?? this.sort,
      searchField: searchField ?? this.searchField,
      filters: filters ?? this.filters,
      campaigns: campaigns ?? this.campaigns,
    );
  }
}

/// Loads and filters campaigns from the repository.
class CampaignsCubit extends Cubit<CampaignsState> {
  CampaignsCubit({String query = '', CampaignCategory? category})
    : super(CampaignsState(query: query, category: category));

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: false));
    try {
      final campaigns = await AppDependencies.instance.campaignRepository
          .searchCampaigns(
            query: state.query,
            category: state.category,
            sort: state.sort,
            searchField: state.searchField,
            filters: state.filters,
          );
      emit(state.copyWith(loading: false, campaigns: campaigns));
    } catch (_) {
      emit(state.copyWith(loading: false, error: true));
    }
  }

  void search(String query) {
    emit(state.copyWith(query: query));
    load();
  }

  void setCategory(CampaignCategory? category) {
    emit(state.copyWith(category: category));
    load();
  }

  void setSort(String? sort) {
    emit(state.copyWith(sort: sort));
    load();
  }

  void setSearchField(CampaignSearchField? field) {
    emit(state.copyWith(searchField: field));
    load();
  }

  void toggleFilter(CampaignFilter filter) {
    final filters = Set<CampaignFilter>.of(state.filters);
    if (!filters.add(filter)) {
      filters.remove(filter);
    }
    emit(state.copyWith(filters: filters));
    load();
  }

  void clearFilters() {
    emit(
      state.copyWith(
        category: null,
        sort: null,
        searchField: null,
        filters: const {},
      ),
    );
    load();
  }
}
