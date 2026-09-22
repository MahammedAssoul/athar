import '../models/app_user.dart';

/// Result of an authentication attempt.
class AuthResult {
  const AuthResult({required this.success, this.user, this.error});

  final bool success;
  final AppUser? user;
  final String? error;
}

/// Contract for authentication data sources (mock or remote).
abstract class AuthRepository {
  /// Sends an OTP to [phone] and returns a mock verification code.
  Future<String> sendOtp(String phone);

  /// Verifies [otp] for [phone]. Returns a session token on success.
  Future<String> verifyOtp(String phone, String otp);

  /// Registers a new user after OTP verification.
  Future<AuthResult> register({
    required String phone,
    required String otp,
    required String firstName,
    required String lastName,
    String? email,
    String? city,
  });

  /// Logs in with phone + OTP (mock flow).
  Future<AuthResult> login(String phone, String otp);

  /// Logs out the current user.
  Future<void> logout();

  /// Returns the currently logged-in user, or null.
  Future<AppUser?> getCurrentUser();

  /// Updates the current user's profile.
  Future<AppUser> updateProfile(AppUser user);

  /// Resets the password (mock — always succeeds).
  Future<bool> resetPassword(String phone, String newPassword);
}
