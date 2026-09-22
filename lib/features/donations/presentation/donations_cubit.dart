import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/donation.dart';

/// Time filter for donation history.
enum DonationFilter { all, thisMonth, thisYear }

/// My Donations state.
class DonationsState {
  const DonationsState({
    this.loading = true,
    this.error = false,
    this.filter = DonationFilter.all,
    this.donations = const [],
  });

  final bool loading;
  final bool error;
  final DonationFilter filter;
  final List<Donation> donations;

  DonationsState copyWith({
    bool? loading,
    bool? error,
    DonationFilter? filter,
    List<Donation>? donations,
  }) {
    return DonationsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      donations: donations ?? this.donations,
    );
  }
}

/// Loads the user's donations from the repository.
class DonationsCubit extends Cubit<DonationsState> {
  DonationsCubit() : super(const DonationsState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: false));
    try {
      final donations = await AppDependencies.instance.donationRepository
          .getDonations();
      emit(state.copyWith(loading: false, donations: donations));
    } catch (_) {
      emit(state.copyWith(loading: false, error: true));
    }
  }

  void setFilter(DonationFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  /// Donations matching the active time filter.
  List<Donation> get filteredDonations {
    final now = DateTime.now();
    return state.donations.where((d) {
      switch (state.filter) {
        case DonationFilter.all:
          return true;
        case DonationFilter.thisMonth:
          return d.date.month == now.month && d.date.year == now.year;
        case DonationFilter.thisYear:
          return d.date.year == now.year;
      }
    }).toList();
  }

  /// Aggregate helpers used by the UI.
  double get totalDonated => filteredDonations
      .where((d) => d.isSuccessful)
      .fold(0, (sum, d) => sum + d.amount);

  int get successCount => filteredDonations.where((d) => d.isSuccessful).length;

  /// Number of distinct campaigns supported.
  int get campaignsSupported => filteredDonations
      .where((d) => d.isSuccessful)
      .map((d) => d.campaignId)
      .toSet()
      .length;
}
