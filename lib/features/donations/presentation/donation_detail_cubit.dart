import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/donation.dart';

/// Single donation state.
class DonationDetailState {
  const DonationDetailState({
    this.loading = true,
    this.error = false,
    this.donation,
  });

  final bool loading;
  final bool error;
  final Donation? donation;

  DonationDetailState copyWith({
    bool? loading,
    bool? error,
    Donation? donation,
  }) {
    return DonationDetailState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      donation: donation ?? this.donation,
    );
  }
}

/// Loads one donation by id.
class DonationDetailCubit extends Cubit<DonationDetailState> {
  DonationDetailCubit(this.donationId) : super(const DonationDetailState());

  final String donationId;

  Future<void> load() async {
    emit(const DonationDetailState(loading: true));
    try {
      final donation = await AppDependencies.instance.donationRepository
          .getDonationById(donationId);
      emit(DonationDetailState(loading: false, donation: donation));
    } catch (_) {
      emit(const DonationDetailState(loading: false, error: true));
    }
  }
}
