import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/notification_preferences.dart';

/// Keys used in local storage.
class StorageKeys {
  StorageKeys._();

  static const String onboardingDone = 'onboarding_done';
  static const String language = 'app_language';
  static const String sessionToken = 'auth_token';
  static const String currentUser = 'auth_user';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String notificationPreferences = 'notification_preferences';
  static const String favoriteCampaigns = 'favorite_campaigns';
}

/// Thin wrapper around [SharedPreferences].
///
/// Stores non-sensitive state only: onboarding, mock session,
/// language and user preferences. Never stores payment data.
class LocalStorage {
  LocalStorage._();

  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  // ── Onboarding ─────────────────────────────────────────
  static Future<bool> isOnboardingDone() async =>
      (await _prefs).getBool(StorageKeys.onboardingDone) ?? false;

  static Future<void> setOnboardingDone(bool done) async =>
      (await _prefs).setBool(StorageKeys.onboardingDone, done);

  // ── Language ───────────────────────────────────────────
  static Future<String?> getLanguage() async =>
      (await _prefs).getString(StorageKeys.language);

  static Future<void> setLanguage(String code) async =>
      (await _prefs).setString(StorageKeys.language, code);

  // ── Session ────────────────────────────────────────────
  static Future<String?> getSessionToken() async =>
      (await _prefs).getString(StorageKeys.sessionToken);

  static Future<void> setSessionToken(String token) async =>
      (await _prefs).setString(StorageKeys.sessionToken, token);

  static Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(StorageKeys.sessionToken);
    await prefs.remove(StorageKeys.currentUser);
  }

  // ── User ───────────────────────────────────────────────
  static Future<AppUser?> getStoredUser() async {
    final raw = (await _prefs).getString(StorageKeys.currentUser);
    if (raw == null) return null;
    try {
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> storeUser(AppUser user) async => (await _prefs).setString(
    StorageKeys.currentUser,
    jsonEncode(user.toJson()),
  );

  // ── Preferences ────────────────────────────────────────
  static Future<bool> areNotificationsEnabled() async =>
      (await _prefs).getBool(StorageKeys.notificationsEnabled) ?? true;

  static Future<void> setNotificationsEnabled(bool enabled) async =>
      (await _prefs).setBool(StorageKeys.notificationsEnabled, enabled);

  // ── Notification preferences ───────────────────────────
  static Future<NotificationPreferences> getNotificationPreferences() async {
    final raw = (await _prefs).getString(StorageKeys.notificationPreferences);
    if (raw == null) return const NotificationPreferences();
    try {
      return NotificationPreferences.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const NotificationPreferences();
    }
  }

  static Future<void> setNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    await (await _prefs).setString(
      StorageKeys.notificationPreferences,
      jsonEncode(preferences.toJson()),
    );
  }

  // ── Favorites ──────────────────────────────────────────
  static Future<List<String>> getFavoriteIds() async {
    final raw = (await _prefs).getStringList(StorageKeys.favoriteCampaigns);
    return raw ?? const [];
  }

  static Future<bool> isFavorite(String campaignId) async {
    final ids = await getFavoriteIds();
    return ids.contains(campaignId);
  }

  static Future<void> addFavorite(String campaignId) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList(StorageKeys.favoriteCampaigns) ?? [];
    if (!ids.contains(campaignId)) {
      ids.add(campaignId);
      await prefs.setStringList(StorageKeys.favoriteCampaigns, ids);
    }
  }

  static Future<void> removeFavorite(String campaignId) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList(StorageKeys.favoriteCampaigns) ?? [];
    ids.remove(campaignId);
    await prefs.setStringList(StorageKeys.favoriteCampaigns, ids);
  }
}
