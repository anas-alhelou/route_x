// lib/features/auth/data/datasources/google_sign_in_service.dart
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:routex_mobile/core/config/constants/app_env.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';

/// [GoogleSignInService] backed by the native `google_sign_in` SDK (v7.2).
///
/// The only class in the app that imports the SDK: the presentation layer and
/// every other layer talk to the [GoogleSignInService] interface instead.
class GoogleSignInServiceImpl implements GoogleSignInService {
  GoogleSignInServiceImpl({
    GoogleSignIn? signIn,
    ExceptionMapper exceptionMapper = const ExceptionMapper(),
    String? serverClientIdOverride,
  }) : _signIn = signIn ?? GoogleSignIn.instance,
       _exceptionMapper = exceptionMapper,
       _serverClientIdOverride = serverClientIdOverride;

  final GoogleSignIn _signIn;
  final ExceptionMapper _exceptionMapper;

  /// Optional override for testing: when non-null, used instead of [AppEnv].
  ///
  /// Allows tests to verify the initialize-retry logic without needing a real
  /// `--dart-define=GOOGLE_SERVER_CLIENT_ID` value.
  final String? _serverClientIdOverride;

  /// Retryable Google failure, as a key resolved by `translateValidationKey`.
  static const String _googleSignInFailedKey = 'errGoogleSignInFailed';

  /// Guards [GoogleSignIn.initialize]: the SDK requires it to run exactly once
  /// per process, and calling it twice is undefined behaviour.
  Future<void>? _initialization;

  @override
  Future<GoogleAuthResult> signIn() async {
    // Fail fast, in debug only.
    //
    // With no server client id the SDK silently falls back to whatever the
    // platform config provides, and on a machine without the Firebase
    // `google-services.json` there is nothing to fall back to. The user then
    // just sees a generic "sign-in failed" with no clue why, which is the
    // single most common cause of a broken Google button. A release build keeps
    // the previous silent behaviour: an unconfigured build is a misconfiguration
    // to be fixed before shipping, not something to crash a user's session over.
    if (kDebugMode && _serverClientId == null) {
      _log(
        'GOOGLE_SERVER_CLIENT_ID is empty. Sign-in can only work if the '
        'platform config supplies an OAuth web client (Android: '
        'google-services.json + an OAuth client whose SHA-1 matches the debug '
        'keystore). Run with --dart-define-from-file=env/dev.json, or copy '
        'env/dev.example.json to env/dev.json and fill it in.',
        name: 'GoogleSignIn',
      );
      return const GoogleAuthResult.failure(GoogleAuthConfigurationFailure());
    }

    try {
      await _ensureInitialized();

      final account = await _signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        // The SDK reported success but handed back no token. On Android that is
        // what a missing/invalid server client id looks like, so it is reported
        // as the configuration problem it usually is rather than as a mystery.
        _log(
          'The SDK returned an account with no idToken. This normally means the '
          'server client id is missing or does not match the OAuth client '
          'registered for this package name.',
          name: 'GoogleSignIn',
        );
        return const GoogleAuthResult.failure(GoogleAuthConfigurationFailure());
      }
      _log(
        'Obtained an id token; sending it to the API.',
        name: 'GoogleSignIn',
      );
      return GoogleAuthResult.success(
        idToken,
        displayName: account.displayName,
        email: account.email,
      );
    } on GoogleSignInException catch (error, stackTrace) {
      // The SDK's `description` can quote platform internals, so it is only
      // ever written to the developer log — never into a Failure message and
      // never onto the screen.
      _log(
        'The Google Sign-In SDK failed with ${error.code.name}: '
        '${error.description}',
        name: 'GoogleSignIn',
        error: error,
        stackTrace: stackTrace,
      );

      switch (error.code) {
        // The user dismissed the chooser, or the flow was interrupted. Both
        // mean "no answer given", not "something went wrong", so they stay
        // silent: no failure, no log line, nothing on screen.
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          return const GoogleAuthResult.cancelled();

        // Only the developer can fix these, and only by changing the build or
        // the Google/Firebase console.
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          return const GoogleAuthResult.failure(
            GoogleAuthConfigurationFailure(),
          );

        // `uiUnavailable` and `userMismatch` are transient/platform problems
        // and `unknownError` is the SDK's catch-all, but all three mean the
        // attempt failed rather than that the app is misconfigured — so they
        // share the retryable Google copy instead of the app-wide generic one.
        case GoogleSignInExceptionCode.uiUnavailable:
        case GoogleSignInExceptionCode.userMismatch:
        case GoogleSignInExceptionCode.unknownError:
          return const GoogleAuthResult.failure(
            ServerFailure(_googleSignInFailedKey),
          );
      }
    } catch (error, stackTrace) {
      _log(
        'Unexpected error while signing in with Google',
        name: 'GoogleSignIn',
        error: error,
        stackTrace: stackTrace,
      );
      return GoogleAuthResult.failure(_exceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _signIn.signOut();
    } catch (error, stackTrace) {
      // Logout must always complete: the local session is already gone, and a
      // stuck Google session only means the chooser is pre-filled next time.
      _log(
        'Failed to sign out of Google; the local session is unaffected',
        name: 'GoogleSignIn',
        error: error,
        stackTrace: stackTrace,
      );
      _exceptionMapper.map(error, stackTrace);
    }
  }

  /// Initializes the SDK at most once, memoizing the in-flight future so two
  /// concurrent sign-in attempts cannot race into a double `initialize`.
  ///
  /// If the underlying `initialize` throws, the cached future is cleared so the
  /// next tap can retry instead of replaying the same failed future forever.
  Future<void> _ensureInitialized() async {
    final existing = _initialization;
    if (existing != null) {
      await existing;
      return;
    }
    final future = _signIn.initialize(serverClientId: _serverClientId);
    _initialization = future;
    try {
      await future;
    } catch (_) {
      // Do not cache a failed initialization — the next sign-in should retry.
      if (identical(_initialization, future)) {
        _initialization = null;
      }
      rethrow;
    }
  }

  /// Null when no `--dart-define=GOOGLE_SERVER_CLIENT_ID=...` was supplied, so
  /// the SDK falls back to the platform configuration file instead of being
  /// handed an empty string.
  String? get _serverClientId {
    final override = _serverClientIdOverride;
    if (override != null) {
      final trimmed = override.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    final configured = AppEnv.googleServerClientId.trim();
    return configured.isEmpty ? null : configured;
  }

  /// Writes a developer-only diagnostic line.
  ///
  /// Gated on [kDebugMode] so nothing reaches a release log, and written
  /// through `dart:developer` so DevTools keeps it attached to the error and
  /// stack trace instead of scattering it through the console.
  ///
  /// Tokens, emails and user identifiers are never passed in: everything
  /// logged here is either a constant string or a value the SDK itself marked
  /// as developer-facing.
  static void _log(
    String message, {
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    developer.log(message, name: name, error: error, stackTrace: stackTrace);
  }
}
