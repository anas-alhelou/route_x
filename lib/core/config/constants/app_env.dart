// lib/core/config/constants/app_env.dart

/// Environment variables used by the app at build/run time.
///
/// Values are injected via `--dart-define` so secrets/config are not
/// hardcoded in source code.
class AppEnv {
  AppEnv._();

  /// Google OAuth server client ID (web client ID) used by the backend to
  /// verify Google ID tokens issued to the mobile app.
  ///
  /// Inject with:
  ///   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
