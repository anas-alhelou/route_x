// lib/core/services/local/app_preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

import 'package:routex_mobile/core/config/constants/preference_keys.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN NOTES
// ─────────────────────────────────────────────────────────────────────────────
// This service is intentionally split into TWO categories of preferences:
//
//  ┌─────────────────────────────────────────────────────────┐
//  │  APP-LEVEL  (language, theme, onboarding status)         │
//  │  • Tied to the device/user, NOT to a login session.     │
//  │  • Persist across logout. Never cleared here.           │
//  └─────────────────────────────────────────────────────────┘
//  ┌─────────────────────────────────────────────────────────┐
//  │  SESSION-LEVEL  (remember me)                           │
//  │  • Tied to the current login session.                   │
//  │  • Cleared by clearUserPreferences() on logout.         │
//  └─────────────────────────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────

/// Contract for persisting the user-level app preferences.
abstract class AppPreferencesService {
  // ── Language ─────────────────────────────────────────────────────────────

  /// Persists [code] as the active language (e.g. "en", "ar").
  Future<bool> setLanguageCode(String code);

  /// Returns the last persisted language code, or `null` if never set.
  String? getLanguageCode();

  // ── Theme Mode ───────────────────────────────────────────────────────────

  /// Persists [mode] as the active theme.
  Future<bool> setThemeMode(String mode);

  /// Returns the last persisted theme mode string, or `null` if never set.
  String? getThemeMode();

  // ── Onboarding ───────────────────────────────────────────────────────────

  /// Persists [value] indicating whether onboarding has been completed.
  Future<bool> setOnboardingCompleted(bool value);

  /// Returns whether onboarding was completed. Defaults to `false`.
  bool isOnboardingCompleted();

  // ── Remember Me ──────────────────────────────────────────────────────────

  /// Persists [value] as the "remember me" login flag.
  Future<bool> setRememberMe(bool value);

  /// Returns the persisted "remember me" flag, defaulting to `false`.
  bool getRememberMe();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  /// Clears all SESSION-LEVEL preferences.
  Future<bool> clearUserPreferences();
}

/// Concrete implementation backed by [SharedPreferences].
class AppPreferencesServiceImpl implements AppPreferencesService {
  const AppPreferencesServiceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  // ── Language ─────────────────────────────────────────────────────────────

  @override
  Future<bool> setLanguageCode(String code) =>
      _prefs.setString(PreferenceKeys.languageCode, code);

  @override
  String? getLanguageCode() => _prefs.getString(PreferenceKeys.languageCode);

  // ── Theme Mode ───────────────────────────────────────────────────────────

  @override
  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(PreferenceKeys.themeMode, mode);

  @override
  String? getThemeMode() => _prefs.getString(PreferenceKeys.themeMode);

  // ── Onboarding ───────────────────────────────────────────────────────────

  @override
  Future<bool> setOnboardingCompleted(bool value) =>
      _prefs.setBool(PreferenceKeys.onboardingCompleted, value);

  @override
  bool isOnboardingCompleted() =>
      _prefs.getBool(PreferenceKeys.onboardingCompleted) ?? false;

  // ── Remember Me ──────────────────────────────────────────────────────────

  @override
  Future<bool> setRememberMe(bool value) =>
      _prefs.setBool(PreferenceKeys.rememberMe, value);

  @override
  bool getRememberMe() => _prefs.getBool(PreferenceKeys.rememberMe) ?? false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  Future<bool> clearUserPreferences() async {
    final removed = await _prefs.remove(PreferenceKeys.rememberMe);
    return removed;
  }
}