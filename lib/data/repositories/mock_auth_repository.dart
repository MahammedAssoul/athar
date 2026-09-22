import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../services/local_storage.dart';

/// Mock authentication backed by local storage.
///
/// Simulates the full flow: OTP send → verify → register/login.
/// The OTP is always `1234` for demo purposes and is never
/// sent via SMS. Session state persists across app restarts.
class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  @override
  Future<String> sendOtp(String phone) async {
    // Simulate network latency.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Demo OTP — always 1234.
    return '1234';
  }

  @override
  Future<String> verifyOtp(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (otp != '1234') {
      throw AuthException('Invalid OTP');
    }
    return 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
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
      final token = await verifyOtp(phone, otp);
      final user = AppUser(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        city: city,
        createdAt: DateTime.now(),
        isVerified: true,
      );
      await _saveSession(token, user);
      return AuthResult(success: true, user: user);
    } on AuthException catch (e) {
      return AuthResult(success: false, error: e.message);
    }
  }

  @override
  Future<AuthResult> login(String phone, String otp) async {
    try {
      final token = await verifyOtp(phone, otp);
      // Existing demo user, or a fresh one for any phone number.
      final user =
          _currentUser ??
          AppUser(
            id: 'u1',
            firstName: 'محمد',
            lastName: 'أحمد',
            phone: phone,
            email: 'mohammed@example.com',
            city: 'طرابلس',
            createdAt: DateTime(2025, 3, 1),
            isVerified: true,
          );
      await _saveSession(token, user);
      return AuthResult(success: true, user: user);
    } on AuthException catch (e) {
      return AuthResult(success: false, error: e.message);
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await LocalStorage.clearSession();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final stored = await LocalStorage.getStoredUser();
    final token = await LocalStorage.getSessionToken();
    if (stored != null && token != null) {
      _currentUser = stored;
      return stored;
    }
    return null;
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    _currentUser = user;
    await LocalStorage.storeUser(user);
    return user;
  }

  @override
  Future<bool> resetPassword(String phone, String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Mock — always succeeds.
    return true;
  }

  Future<void> _saveSession(String token, AppUser user) async {
    _currentUser = user;
    await LocalStorage.setSessionToken(token);
    await LocalStorage.storeUser(user);
  }
}

/// Thrown when authentication fails.
class AuthException implements Exception {
  AuthException(this.message);

  final String message;
}
