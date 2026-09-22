import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/app_user.dart';

/// Profile state.
class ProfileState {
  const ProfileState({this.loading = true, this.error = false, this.user});

  final bool loading;
  final bool error;
  final AppUser? user;

  ProfileState copyWith({bool? loading, bool? error, AppUser? user}) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

/// Loads the current (mock) user and supports profile updates.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  Future<void> load() async {
    emit(const ProfileState(loading: true));
    try {
      final user = await AppDependencies.instance.userRepository
          .getCurrentUser();
      emit(ProfileState(loading: false, user: user));
    } catch (_) {
      emit(const ProfileState(loading: false, error: true));
    }
  }

  Future<void> updateUser(AppUser updated) async {
    final user = await AppDependencies.instance.authRepository.updateProfile(
      updated,
    );
    emit(state.copyWith(user: user));
  }
}
