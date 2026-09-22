import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/recurring_donation.dart';

/// Recurring donations state.
class RecurringDonationsState {
  const RecurringDonationsState({
    this.loading = true,
    this.error = false,
    this.items = const [],
    this.busyId,
  });

  final bool loading;
  final bool error;
  final List<RecurringDonation> items;

  /// Id of the item currently being paused/resumed/cancelled.
  final String? busyId;

  RecurringDonationsState copyWith({
    bool? loading,
    bool? error,
    List<RecurringDonation>? items,
    String? busyId,
  }) {
    return RecurringDonationsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      items: items ?? this.items,
      busyId: busyId,
    );
  }
}

/// Loads and manages recurring donations.
class RecurringDonationsCubit extends Cubit<RecurringDonationsState> {
  RecurringDonationsCubit() : super(const RecurringDonationsState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: false));
    try {
      final items = await AppDependencies.instance.recurringDonationRepository
          .getRecurringDonations();
      emit(state.copyWith(loading: false, items: items));
    } catch (_) {
      emit(state.copyWith(loading: false, error: true));
    }
  }

  Future<void> pause(String id) async {
    emit(state.copyWith(busyId: id));
    try {
      final updated = await AppDependencies.instance.recurringDonationRepository
          .pause(id);
      _replace(updated);
    } finally {
      emit(state.copyWith(busyId: null));
    }
  }

  Future<void> resume(String id) async {
    emit(state.copyWith(busyId: id));
    try {
      final updated = await AppDependencies.instance.recurringDonationRepository
          .resume(id);
      _replace(updated);
    } finally {
      emit(state.copyWith(busyId: null));
    }
  }

  Future<void> cancel(String id) async {
    emit(state.copyWith(busyId: id));
    try {
      final updated = await AppDependencies.instance.recurringDonationRepository
          .cancel(id);
      _replace(updated);
    } finally {
      emit(state.copyWith(busyId: null));
    }
  }

  void _replace(RecurringDonation updated) {
    emit(
      state.copyWith(
        items: state.items
            .map((r) => r.id == updated.id ? updated : r)
            .toList(),
      ),
    );
  }
}
