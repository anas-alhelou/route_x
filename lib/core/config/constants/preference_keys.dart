// lib/core/config/constants/preference_keys.dart

/// Centralized SharedPreferences key registry.
///
/// Every raw string key used with [SharedPreferences] MUST be declared here.
/// This prevents silent key collisions and makes the full storage contract
/// discoverable in one place — critical as the app grows and more developers
/// add preferences.
///
/// Naming convention: `app.preference.<domain>.<name>`
/// Using dotted namespaces (instead of plain strings) prevents collisions
/// with third-party packages that may also write to SharedPreferences.
abstract final class PreferenceKeys {
  PreferenceKeys._();

  // ── App-level preferences ──────────────────────────────────────────────
  // These survive logout. They express user intent at the *app* level
  // (how the app looks and speaks), not at the *session* level.

  /// The BCP-47 language code last chosen by the user — e.g. "en", "ar".
  /// Read on app start to restore the locale before the first frame.
  static const String languageCode = 'app.preference.language_code';

  /// The theme mode last chosen by the user.
  /// Valid values: "light" | "dark" | "system".
  /// Read on app start to restore the brightness before the first frame.
  static const String themeMode = 'app.preference.theme_mode';

  // ── Session-level preferences ──────────────────────────────────────────
  // These are cleared on logout (via [AppPreferencesService.clearUserPreferences]).
  // Do NOT add app-level preferences below this line.

  /// Whether the user checked "Remember Me" on the login screen.
  /// When true the app may skip the login screen on next cold start.
  static const String rememberMe = 'app.preference.remember_me';


  static const String onboardingCompleted = 'app.preference.onboarding_completed';
}
