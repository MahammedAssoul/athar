import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/notification_preferences.dart';
import '../../../data/services/local_storage.dart';

/// Notification preferences state.
class NotificationPreferencesState {
  const NotificationPreferencesState({
    this.loading = true,
    this.error = false,
    this.preferences = const NotificationPreferences(),
  });

  final bool loading;
  final bool error;
  final NotificationPreferences preferences;

  NotificationPreferencesState copyWith({
    bool? loading,
    bool? error,
    NotificationPreferences? preferences,
  }) {
    return NotificationPreferencesState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// Loads and persists notification preferences locally.
class NotificationPreferencesCubit extends Cubit<NotificationPreferencesState> {
  NotificationPreferencesCubit() : super(const NotificationPreferencesState());

  Future<void> load() async {
    emit(const NotificationPreferencesState(loading: true));
    try {
      final preferences = await LocalStorage.getNotificationPreferences();
      emit(
        NotificationPreferencesState(loading: false, preferences: preferences),
      );
    } catch (_) {
      emit(const NotificationPreferencesState(loading: false, error: true));
    }
  }

  Future<void> set(NotificationPreferenceKey key, bool value) async {
    final current = state.preferences;
    final updated = switch (key) {
      NotificationPreferenceKey.donationSuccess => current.copyWith(
        donationSuccess: value,
      ),
      NotificationPreferenceKey.campaignCompleted => current.copyWith(
        campaignCompleted: value,
      ),
      NotificationPreferenceKey.campaignUpdates => current.copyWith(
        campaignUpdates: value,
      ),
      NotificationPreferenceKey.recurringDonation => current.copyWith(
        recurringDonation: value,
      ),
      NotificationPreferenceKey.impactUpdates => current.copyWith(
        impactUpdates: value,
      ),
      NotificationPreferenceKey.systemMessages => current.copyWith(
        systemMessages: value,
      ),
    };
    await LocalStorage.setNotificationPreferences(updated);
    emit(state.copyWith(preferences: updated));
  }
}
