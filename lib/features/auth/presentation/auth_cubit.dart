import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/app_user.dart';

/// Auth screen state.
class AuthState {
  const AuthState({
    this.loading = false,
    this.error,
    this.otpSent = false,
    this.otp = '',
    this.phone = '',
    this.user,
  });

  final bool loading;
  final String? error;
  final bool otpSent;
  final String otp;
  final String phone;

  /// The authenticated user, or null when signed out.
  final AppUser? user;

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    bool? loading,
    String? error,
    bool? otpSent,
    String? otp,
    String? phone,
    AppUser? user,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      otpSent: otpSent ?? this.otpSent,
      otp: otp ?? this.otp,
      phone: phone ?? this.phone,
      user: user ?? this.user,
    );
  }
}

/// Drives the mock phone + OTP authentication flow.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  /// Restores a persisted session (app restart) into the state.
  Future<void> restoreSession() async {
    final user = await AppDependencies.instance.authRepository.getCurrentUser();
    if (user != null) {
      emit(state.copyWith(user: user));
    }
  }

  Future<bool> sendOtp(String phone) async {
    emit(state.copyWith(loading: true, error: null, phone: phone));
    try {
      final otp = await AppDependencies.instance.authRepository.sendOtp(phone);
      emit(state.copyWith(loading: false, otpSent: true, otp: otp));
      return true;
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'send_failed'));
      return false;
    }
  }

  Future<AppUser?> login(String phone, String otp) async {
    emit(state.copyWith(loading: true, error: null));
    final result = await AppDependencies.instance.authRepository.login(
      phone,
      otp,
    );
    if (result.success) {
      emit(state.copyWith(loading: false, user: result.user));
      return result.user;
    }
    emit(state.copyWith(loading: false, error: result.error ?? 'login_failed'));
    return null;
  }

  Future<AppUser?> register({
    required String phone,
    required String otp,
    required String firstName,
    required String lastName,
    String? email,
    String? city,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    final result = await AppDependencies.instance.authRepository.register(
      phone: phone,
      otp: otp,
      firstName: firstName,
      lastName: lastName,
      email: email,
      city: city,
    );
    if (result.success) {
      emit(state.copyWith(loading: false, user: result.user));
      return result.user;
    }
    emit(
      state.copyWith(loading: false, error: result.error ?? 'register_failed'),
    );
    return null;
  }

  Future<bool> resetPassword(String phone, String newPassword) async {
    emit(state.copyWith(loading: true, error: null));
    final ok = await AppDependencies.instance.authRepository.resetPassword(
      phone,
      newPassword,
    );
    emit(state.copyWith(loading: false));
    return ok;
  }

  Future<void> logout() async {
    await AppDependencies.instance.authRepository.logout();
    emit(const AuthState());
  }
}
