import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_error.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../services/local_storage.dart';
import '../services/token_storage.dart';

/// Real authentication repository backed by the Athar backend.
///
/// Used when `isMock == false`. Tokens are stored securely via
/// [TokenStorage] (keychain/keystore) — never in plain text.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<String> sendOtp(String phone) async {
    final data = await _client.post(
      ApiEndpoints.sendOtp,
      body: {'phone': phone},
      authenticated: false,
    );
    // Backend may return a dev OTP; in production it sends via SMS.
    return (data as Map<String, dynamic>)['otp'] as String? ?? '';
  }

  @override
  Future<String> verifyOtp(String phone, String otp) async {
    final data = await _client.post(
      ApiEndpoints.verifyOtp,
      body: {'phone': phone, 'otp': otp},
      authenticated: false,
    );
    final map = data as Map<String, dynamic>;
    final access = map['accessToken'] as String?;
    final refresh = map['refreshToken'] as String?;
    if (access == null) {
      throw const ApiException(ApiErrorType.unauthorized);
    }
    await TokenStorage.saveTokens(
      accessToken: access,
      refreshToken: refresh ?? '',
    );
    return access;
  }

  @override
  Future<AuthResult> register({
    required String phone,
    required String otp,
    required String firstName,
    required String lastName,
    String? email,
    String? city,
  }) async {
    try {
      final data = await _client.post(
        ApiEndpoints.register,
        body: {
          'phone': phone,
          'otp': otp,
          'firstName': firstName,
          'lastName': lastName,
          'email': ?email,
          'city': ?city,
        },
        authenticated: false,
      );
      final map = data as Map<String, dynamic>;
      final access = map['accessToken'] as String?;
      final refresh = map['refreshToken'] as String?;
      if (access != null) {
        await TokenStorage.saveTokens(
          accessToken: access,
          refreshToken: refresh ?? '',
        );
      }
      final user = AppUser.fromJson(map['user'] as Map<String, dynamic>);
      await LocalStorage.storeUser(user);
      return AuthResult(success: true, user: user);
    } on ApiException catch (e) {
      return AuthResult(success: false, error: e.message);
    }
  }

  @override
  Future<AuthResult> login(String phone, String otp) async {
    try {
      final data = await _client.post(
        ApiEndpoints.login,
        body: {'phone': phone, 'otp': otp},
        authenticated: false,
      );
      final map = data as Map<String, dynamic>;
      final access = map['accessToken'] as String?;
      final refresh = map['refreshToken'] as String?;
      if (access != null) {
        await TokenStorage.saveTokens(
          accessToken: access,
          refreshToken: refresh ?? '',
        );
      }
      final user = AppUser.fromJson(map['user'] as Map<String, dynamic>);
      await LocalStorage.storeUser(user);
      return AuthResult(success: true, user: user);
    } on ApiException catch (e) {
      return AuthResult(success: false, error: e.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } on ApiException {
      // Best-effort: clear local session regardless of server response.
    }
    await TokenStorage.clearTokens();
    await LocalStorage.clearSession();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final data = await _client.get(ApiEndpoints.me);
      final user = AppUser.fromJson(data as Map<String, dynamic>);
      await LocalStorage.storeUser(user);
      return user;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await TokenStorage.clearTokens();
        await LocalStorage.clearSession();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    final data = await _client.patch(
      ApiEndpoints.me,
      body: {
        'firstName': user.firstName,
        'lastName': user.lastName,
        if (user.email != null) 'email': user.email,
        if (user.city != null) 'city': user.city,
      },
    );
    final updated = AppUser.fromJson(data as Map<String, dynamic>);
    await LocalStorage.storeUser(updated);
    return updated;
  }

  @override
  Future<bool> resetPassword(String phone, String newPassword) async {
    try {
      await _client.post(
        ApiEndpoints.resetPassword,
        body: {'phone': phone, 'newPassword': newPassword},
        authenticated: false,
      );
      return true;
    } on ApiException {
      return false;
    }
  }
}
