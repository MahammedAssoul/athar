import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/gift_donation.dart';

/// Gift success state.
class GiftSuccessState {
  const GiftSuccessState({this.loading = true, this.error = false, this.gift});

  final bool loading;
  final bool error;
  final GiftDonation? gift;

  GiftSuccessState copyWith({bool? loading, bool? error, GiftDonation? gift}) {
    return GiftSuccessState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      gift: gift ?? this.gift,
    );
  }
}

/// Loads a single gift donation for the confirmation screen.
class GiftSuccessCubit extends Cubit<GiftSuccessState> {
  GiftSuccessCubit(this.giftId) : super(const GiftSuccessState());

  final String giftId;

  Future<void> load() async {
    emit(const GiftSuccessState(loading: true));
    try {
      final gifts = await AppDependencies.instance.giftDonationRepository
          .getGiftDonations();
      GiftDonation? gift;
      for (final g in gifts) {
        if (g.id == giftId) {
          gift = g;
          break;
        }
      }
      emit(GiftSuccessState(loading: false, gift: gift));
    } catch (_) {
      emit(const GiftSuccessState(loading: false, error: true));
    }
  }
}
