import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores authentication tokens.
///
/// Uses the platform keychain/keystore via `flutter_secure_storage`.
/// Never stores payment data (card numbers, CVV, PIN) — only session
/// tokens and the refresh token.
class TokenStorage {
  TokenStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  /// Stores both tokens.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Returns the current access token, or null.
  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  /// Returns the current refresh token, or null.
  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  /// Clears both tokens (logout / session expiry).
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Whether a session exists (access token present).
  static Future<bool> hasSession() async => (await getAccessToken()) != null;
}
