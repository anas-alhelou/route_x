// test/google_sign_in_test.dart
//
// Covers the Google Sign-In wiring end to end:
//   * `GetGoogleIdTokenUseCase` is the only caller of the SDK and calls it once.
//   * The repository is a pure backend exchange: the first attempt sends the
//     token alone, the one that registers an account adds the vehicle, and
//     `401`/`500` map to one retryable outcome that still carries the server's
//     own reason when it gave one.
//   * The vehicle-required signal (`422` + `VEHICLE_REQUIRED`, placeholder
//     pending backend confirmation) is the only thing read as "this account is
//     new" — no generic `400`/`401`/`404` ever opens the vehicle step.
//   * The SDK wrapper initializes at most once but retries after a failure.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:routex_mobile/core/config/constants/app_env.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/storage/secure_storage_service.dart';
import 'package:routex_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:routex_mobile/features/auth/data/datasources/google_sign_in_service.dart';
import 'package:routex_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/vehicle_type.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';
import 'package:routex_mobile/features/auth/domain/usecases/get_google_id_token_usecase.dart';

/// The token the SDK handed to the use case.
const _sdkToken = 'id-token-from-the-sdk';

/// A complete, valid `GoogleAuthParams` — the vehicle fields are mandatory.
const _params = GoogleAuthParams(
  idToken: _sdkToken,
  vehicleType: VehicleType.car,
  vehicleNumber: 'PAL-8899',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GetGoogleIdTokenUseCase', () {
    test('returns the token the SDK produced', () async {
      final service = _FakeGoogleSignInService(
        result: const GoogleAuthResult.success(_sdkToken),
      );

      final result = await GetGoogleIdTokenUseCase(service: service)();

      expect(result.idToken, _sdkToken);
      expect(result.failure, isNull);
      expect(result.isCancelled, isFalse);
    });

    test('a dismissed chooser is a cancellation, not a failure', () async {
      final service = _FakeGoogleSignInService(
        result: const GoogleAuthResult.cancelled(),
      );

      final result = await GetGoogleIdTokenUseCase(service: service)();

      expect(result.isCancelled, isTrue);
      expect(result.idToken, isNull);
      expect(result.failure, isNull);
    });

    test('an SDK failure is passed through untouched', () async {
      final service = _FakeGoogleSignInService(
        result: const GoogleAuthResult.failure(
          GoogleAuthConfigurationFailure(),
        ),
      );

      final result = await GetGoogleIdTokenUseCase(service: service)();

      expect(result.failure, isA<GoogleAuthConfigurationFailure>());
      expect(result.failure!.message, 'errGoogleNotConfigured');
      expect(result.isCancelled, isFalse);
    });

    test('calls the SDK exactly once per invocation', () async {
      final service = _FakeGoogleSignInService(
        result: const GoogleAuthResult.success(_sdkToken),
      );
      final useCase = GetGoogleIdTokenUseCase(service: service);

      await useCase();
      await useCase();

      // One chooser per tap. Two invocations means two taps, so the counter is
      // expected to grow with them — the invariant is 1:1, never 2 for one tap.
      expect(service.signInCalls, 2);
    });
  });

  group('the repository is a pure backend exchange', () {
    late _FakeGoogleSignInService google;
    late _FakeAdapter adapter;
    late _FakeStorage storage;
    late AuthRepositoryImpl repository;

    setUp(() {
      google = _FakeGoogleSignInService();
      storage = _FakeStorage();
      adapter = _authSucceeds();
      repository = _repositoryWith(storage, adapter, google);
    });

    test('sends the token, platform, fcmToken and vehicle fields', () async {
      final result = await repository.googleSignIn(
        const GoogleAuthParams(
          idToken: _sdkToken,
          fcmToken: 'fcm-token',
          vehicleType: VehicleType.motorcycle,
          vehicleNumber: 'ABC-1234',
        ),
      );

      expect(result.isRight(), isTrue);
      expect(adapter.requests.single.data, {
        'idToken': _sdkToken,
        'platform': 'MOBILE',
        'fcmToken': 'fcm-token',
        'vehicleType': 'BIKE',
        'vehicleNumber': 'ABC-1234',
      });
    });

    test('omits only the fcmToken when push is unavailable', () async {
      await repository.googleSignIn(_params);

      expect(adapter.requests.single.data, {
        'idToken': _sdkToken,
        'platform': 'MOBILE',
        'vehicleType': 'CAR',
        'vehicleNumber': 'PAL-8899',
      });
    });

    test('a token-only attempt leaves the vehicle fields out of the body', () async {
      // The first attempt asks the backend whether this account already exists;
      // sending vehicle fields with it is what used to get an existing account
      // refused (and could overwrite the vehicle it already has).
      final result = await repository.googleSignIn(
        const GoogleAuthParams(idToken: _sdkToken),
      );

      expect(result.isRight(), isTrue);
      expect(adapter.requests.single.data, {
        'idToken': _sdkToken,
        'platform': 'MOBILE',
      });
    });

    test('never runs the SDK itself', () async {
      await repository.googleSignIn(_params);

      // The interactive call belongs to GetGoogleIdTokenUseCase; running it
      // again here would show the account chooser a second time.
      expect(google.signInCalls, 0);
    });

    test('persists the session and returns it', () async {
      final result = await repository.googleSignIn(_params);

      final session = result.fold((_) => fail('expected a session'), (s) => s);
      expect(session.tokens.accessToken, 'access.jwt');
      expect(storage.accessToken, 'access.jwt');
      expect(storage.refreshToken, 'refresh.jwt');
      expect(storage.userId, 'usr_01');
    });

    test('a blank token never reaches the network', () async {
      // Unreachable through the UI, but a request with no token is certain to be
      // rejected and would surface as a confusing "invalid token" message.
      final result = await repository.googleSignIn(
        const GoogleAuthParams(
          idToken: '   ',
          vehicleType: VehicleType.car,
          vehicleNumber: 'PAL-8899',
        ),
      );

      expect(
        result.fold((failure) => failure, (_) => fail('expected a failure')),
        isA<GoogleAuthCancelledFailure>(),
      );
      expect(adapter.requests, isEmpty);
    });

    test('logout disconnects the Google account', () async {
      await repository.googleSignIn(_params);
      expect(storage.accessToken, isNotNull);

      await repository.logout();

      expect(storage.accessToken, isNull);
      expect(google.signOutCalls, 1);
    });
  });

  group('a rejected /auth/google call', () {
    late _FakeStorage storage;

    setUp(() => storage = _FakeStorage());

    Future<Failure> callWith(_FakeAdapter adapter) async {
      final result = await _repositoryWith(storage, adapter).googleSignIn(
        _params,
      );
      return result.fold((failure) => failure, (_) => fail('expected failure'));
    }

    test('a 401 keeps the reason the server gave', () async {
      // The only thing that tells "the token was rejected" apart from "this
      // account already exists" is the message, so it must reach the user
      // instead of being replaced by one generic sentence.
      final failure = await callWith(
        _failingWith(401, 'Invalid Google token'),
      );

      expect(failure, isA<GoogleAuthTokenRejectedFailure>());
      expect(failure.message, 'Invalid Google token');
    });

    test('an existing account is reported with the backend own reason', () async {
      // This is the second sign-in with an account that /auth/google already
      // created: the vehicle fields ride along again and the backend refuses
      // the request. Whatever it says is the diagnosis, so it is preserved.
      final failure = await callWith(
        _failingWith(401, 'Email already registered'),
      );

      expect(failure, isA<GoogleAuthTokenRejectedFailure>());
      expect(failure.message, 'Email already registered');
    });

    test('a 500 with no usable reason falls back to the localized key', () async {
      // "Internal server error" is the status-line default, repeated verbatim by
      // every framework. Echoing it would replace a real diagnosis with an
      // English, untranslated stand-in for the key we already have.
      final failure = await callWith(
        _failingWith(500, 'Internal server error'),
      );

      expect(failure, isA<GoogleAuthTokenRejectedFailure>());
      expect(failure.message, 'errGoogleAuthFailed');
    });

    test('a placeholder message never replaces the generic key', () async {
      const placeholders = [
        'Unauthorized',
        'unauthorized.',
        'Forbidden',
        'Bad Request',
        '  SERVER ERROR  ',
        'Something went wrong',
        '<html><body>502 Bad Gateway</body></html>',
        'e',
      ];

      for (final message in placeholders) {
        final failure = await callWith(_failingWith(401, message));
        expect(
          failure.message,
          'errGoogleAuthFailed',
          reason: '"$message" is a placeholder, not a reason to show',
        );
      }
    });

    test('a 401 nested in a 500 envelope is still treated as a rejection', () async {
      final failure = await callWith(
        _failingWith(500, 'Internal server error', nestedStatus: 401),
      );

      expect(failure, isA<GoogleAuthTokenRejectedFailure>());
      expect(failure.message, 'errGoogleAuthFailed');
    });

    test('the reason inside a wrapping 500 envelope survives', () async {
      // The backend answers some rejections with a 500 whose body embeds the
      // real status and message; the nested message is the actual reason and
      // must win over the wrapper's "Internal server error".
      final failure = await callWith(
        _failingWith(
          500,
          'User with this email already exists',
          nestedStatus: 409,
        ),
      );

      expect(failure.message, 'User with this email already exists');
    });

    test('a 400 keeps the backend validation message', () async {
      // A rejected field is actionable and the message is already human-readable,
      // so it must survive rather than be replaced by a generic string.
      final failure = await callWith(
        _failingWith(400, 'vehicleType must be provided'),
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'vehicleType must be provided');
    });

    test('a transport error is a NetworkFailure with a translatable key', () async {
      final failure = await callWith(
        _FakeAdapter((options) async {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'connection refused',
          );
        }),
      );

      expect(failure, isA<NetworkFailure>());
      // A key, not copy: NetworkFailure is built in the data layer, where there
      // is no BuildContext to translate with.
      expect(failure.message, 'errNoInternetConnection');
      expect(storage.accessToken, isNull);
    });
  });

  group('the vehicle-required signal', () {
    late _FakeStorage storage;

    setUp(() => storage = _FakeStorage());

    Future<Failure> callWith(_FakeAdapter adapter) async {
      final result = await _repositoryWith(storage, adapter).googleSignIn(
        // Token only, which is the attempt the signal answers: the vehicle
        // fields are never present when the backend says "still needed".
        const GoogleAuthParams(idToken: _sdkToken),
      );
      return result.fold((failure) => failure, (_) => fail('expected failure'));
    }

    test('a 422 naming VEHICLE_REQUIRED means the account is new', () async {
      final failure = await callWith(_vehicleRequired());

      expect(failure, isA<GoogleVehicleRequiredFailure>());
      // The vehicle step is opened by the failure's *type*, never by copy, so
      // the message it carries is only a safe fallback.
      expect(failure.message, GoogleVehicleRequiredFailure.messageKey);
      expect(storage.accessToken, isNull, reason: 'no session exists yet');
    });

    test('the code nested in a wrapping envelope still counts', () async {
      // The backend wraps some statuses in a 500 envelope: what defines the
      // signal is the effective status plus the code, not the outer frame.
      final failure = await callWith(_vehicleRequired(wrapped: true));

      expect(failure, isA<GoogleVehicleRequiredFailure>());
    });

    test('a generic 400/401/404 is never read as a new account', () async {
      // Even with the code in the message: the status has to be the one the
      // contract names, or an ordinary rejection would open the vehicle step.
      for (final status in [400, 401, 404]) {
        final failure = await callWith(_failingWith(status, 'VEHICLE_REQUIRED'));

        expect(
          failure,
          isNot(isA<GoogleVehicleRequiredFailure>()),
          reason: 'status $status says nothing about the account being new',
        );
      }
    });

    test('a 422 for an unrelated problem stays a validation failure', () async {
      final failure = await callWith(
        _failingWith(422, 'vehicleType must be one of CAR, BIKE, VAN, TRUCK'),
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'vehicleType must be one of CAR, BIKE, VAN, TRUCK');
    });

    test('a wrapped 422 without the code stays a validation failure', () async {
      final failure = await callWith(
        _failingWith(500, 'plate must be valid', nestedStatus: 422),
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'plate must be valid');
    });
  });

  group('the SDK wrapper', () {
    test('an unconfigured build fails fast instead of guessing', () async {
      final result = await GoogleSignInServiceImpl().signIn();

      expect(result.isCancelled, isFalse);
      expect(result.failure, isA<GoogleAuthConfigurationFailure>());
      expect(result.failure!.message, 'errGoogleNotConfigured');
      expect(result.idToken, isNull);
    }, skip: _skipWhenConfigured());

    test('initialize runs at most once for many sign-ins', () async {
      final sdk = _FakeGoogleSignInSdk();
      final service = _serviceOver(sdk);

      await service.signIn();
      await service.signIn();
      await service.signIn();

      expect(
        sdk.initializeCalls,
        1,
        reason: 'the SDK requires exactly one initialize per process',
      );
    });

    test('a failed initialize is not cached, so the next tap retries', () async {
      // The guard must prevent a *double* initialize, not a single attempt: if
      // the failed future stayed memoized, every later tap would replay the same
      // error and Google sign-in would be permanently broken.
      final sdk = _FakeGoogleSignInSdk(failInitializeTimes: 1);
      final service = _serviceOver(sdk);

      final first = await service.signIn();
      final second = await service.signIn();

      expect(sdk.initializeCalls, 2);
      expect(first.failure, isNotNull, reason: 'the first attempt failed');
      expect(second.idToken, 'sdk-token', reason: 'the retry reached Google');
    });

    test('a successful initialize is still shared by concurrent attempts', () async {
      // Two taps racing must not produce two `initialize` calls: the in-flight
      // future is memoized so the second attempt awaits the first.
      final sdk = _FakeGoogleSignInSdk(initializeDelay: Duration.zero);
      final service = _serviceOver(sdk);

      await Future.wait([service.signIn(), service.signIn()]);

      expect(sdk.initializeCalls, 1);
    });

    test('a dismissed chooser is reported as a cancellation', () async {
      final sdk = _FakeGoogleSignInSdk(
        throwOnAuthenticate: () => GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
        ),
      );
      final service = _serviceOver(sdk);

      final result = await service.signIn();

      expect(result.isCancelled, isTrue);
      expect(result.failure, isNull);
    });

    test('a configuration error from the SDK is not a retryable failure', () async {
      final sdk = _FakeGoogleSignInSdk(
        throwOnAuthenticate: () => GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        ),
      );
      final service = _serviceOver(sdk);

      final result = await service.signIn();

      expect(result.failure, isA<GoogleAuthConfigurationFailure>());
    });

    test('an SDK-reported success without a token reads as misconfiguration', () async {
      // On Android this is what a missing or mismatched server client id looks
      // like, so it is reported as the configuration problem it usually is.
      final sdk = _FakeGoogleSignInSdk(idToken: null);
      final service = _serviceOver(sdk);

      final result = await service.signIn();

      expect(result.failure, isA<GoogleAuthConfigurationFailure>());
      expect(result.idToken, isNull);
    });

    test('a transient SDK error uses the retryable Google copy', () async {
      final sdk = _FakeGoogleSignInSdk(
        throwOnAuthenticate: () => GoogleSignInException(
          code: GoogleSignInExceptionCode.unknownError,
        ),
      );
      final service = _serviceOver(sdk);

      final result = await service.signIn();

      expect(result.failure, isA<ServerFailure>());
      expect(result.failure!.message, 'errGoogleSignInFailed');
    });

    test('signOut never throws, even when initialize does', () async {
      // The local session is already gone at that point; a stuck Google session
      // would only mean the chooser is pre-filled next time.
      final sdk = _FakeGoogleSignInSdk(failInitializeAlways: true);
      final service = _serviceOver(sdk);

      await expectLater(service.signOut(), completes);
    });
  });
}

/// Skips the fail-fast test when the run itself supplied a real client id, in
/// which case the build genuinely is configured and there is nothing to assert.
Object? _skipWhenConfigured() => AppEnv.googleServerClientId.trim().isNotEmpty
    ? 'GOOGLE_SERVER_CLIENT_ID is set for this test run'
    : null;

/// Runs the real wrapper over [sdk], with a client id so the debug fail-fast
/// does not short-circuit before the SDK is ever reached.
GoogleSignInServiceImpl _serviceOver(_FakeGoogleSignInSdk sdk) {
  GoogleSignInPlatform.instance = sdk;
  addTearDown(() => GoogleSignInPlatform.instance = _NoPlatform());
  return GoogleSignInServiceImpl(serverClientIdOverride: _clientId);
}

const _clientId = 'test-client-id.apps.googleusercontent.com';

// ── Wiring helpers ──────────────────────────────────────────────────────────

/// Builds the real repository over a Dio transport that records requests, so
/// the assertions are made on the bytes that would reach the backend.
AuthRepositoryImpl _repositoryWith(
  SecureStorageService storage,
  HttpClientAdapter adapter, [
  GoogleSignInService? google,
]) => AuthRepositoryImpl(
  AuthRemoteDataSourceImpl(
    Dio(BaseOptions(baseUrl: 'https://backend.test'))
      ..httpClientAdapter = adapter,
  ),
  storage,
  googleSignInService: google,
);

/// Serves a 200 `/auth/google` body.
_FakeAdapter _authSucceeds() => _fakeAdapter((options) async {
  if (options.path == '/auth/google') {
    return _json({
      'success': true,
      'data': {
        'message': 'Google login successful',
        'user': {
          'id': 'usr_01',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'role': 'DRIVER',
        },
        'tokens': {'accessToken': 'access.jwt', 'refreshToken': 'refresh.jwt'},
      },
      'timestamp': '2026-01-01T00:00:00.000Z',
    });
  }
  return _json({'success': true, 'data': <String, dynamic>{}});
});

/// Serves an HTTP error for `/auth/google`.
///
/// [nestedStatus] reproduces the backend's habit of wrapping a real status in a
/// 500 envelope, which the mapper has to unwrap.
_FakeAdapter _failingWith(
  int statusCode,
  String message, {
  int? nestedStatus,
}) => _fakeAdapter((options) async {
  if (options.path != '/auth/google') {
    return _json({'success': true, 'data': <String, dynamic>{}});
  }
  return _json({
    'statusCode': statusCode,
    'message': message,
    'error': nestedStatus == null
        ? 'Bad Request'
        : {'statusCode': nestedStatus, 'message': message},
  }, statusCode: statusCode);
});

/// Serves the vehicle-required answer for `/auth/google`.
///
/// The status/code pair is the placeholder wire contract pending backend
/// confirmation, so these tests pin exactly what the mapper is expected to
/// react to — and what it must keep ignoring.
///
/// [wrapped] reproduces the backend's habit of putting the real status inside a
/// `500` envelope, with the code on the nested object.
_FakeAdapter _vehicleRequired({bool wrapped = false}) =>
    _fakeAdapter((options) async {
      if (options.path != '/auth/google') {
        return _json({'success': true, 'data': <String, dynamic>{}});
      }
      if (wrapped) {
        return _json({
          'statusCode': 500,
          'message': 'Internal server error',
          'error': {
            'statusCode': 422,
            'code': 'VEHICLE_REQUIRED',
            'message': 'Vehicle details are required',
          },
        }, statusCode: 500);
      }
      return _json({
        'statusCode': 422,
        'message': 'Vehicle details are required',
        'error': 'VEHICLE_REQUIRED',
      }, statusCode: 422);
    });

_FakeAdapter _fakeAdapter(
  Future<ResponseBody> Function(RequestOptions options) handler,
) => _FakeAdapter(handler);

// ── Test doubles ────────────────────────────────────────────────────────────

/// Scripted stand-in for the native SDK: the tests only need to decide what
/// `authenticate()` produced, never to run it.
class _FakeGoogleSignInService implements GoogleSignInService {
  _FakeGoogleSignInService({this.result = const GoogleAuthResult.cancelled()});

  GoogleAuthResult result;
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Future<GoogleAuthResult> signIn() async {
    signInCalls++;
    return result;
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}

/// Minimal stand-in for the platform plugin that counts `init` calls and scripts
/// `authenticate`, so the single-initialize guard and its retry behaviour can be
/// asserted without a device.
///
/// `GoogleSignIn` itself is a final singleton in v7 (private constructor), so the
/// supported seam is the platform interface the SDK delegates to.
class _FakeGoogleSignInSdk extends GoogleSignInPlatform {
  _FakeGoogleSignInSdk({
    this.failInitializeTimes = 0,
    this.failInitializeAlways = false,
    this.idToken = 'sdk-token',
    this.throwOnAuthenticate,
    this.initializeDelay = Duration.zero,
  }) : _remainingFailures = failInitializeTimes;

  /// How many `init` calls should throw before one succeeds.
  final int failInitializeTimes;

  /// When true every `init` throws (the permanently broken case).
  final bool failInitializeAlways;

  /// The token `authenticate` hands back, or null to simulate a missing one.
  final String? idToken;

  /// Thrown by `authenticate` when set.
  final GoogleSignInException Function()? throwOnAuthenticate;

  /// Simulates a slow platform channel so concurrency is observable.
  final Duration initializeDelay;

  int initializeCalls = 0;

  /// A budget consumed across calls, not a per-call decision: the retry tests
  /// need the *second* `init` to be the one that finally succeeds.
  int _remainingFailures;

  @override
  Future<void> init(InitParameters params) async {
    initializeCalls++;
    if (initializeDelay > Duration.zero) {
      await Future<void>.delayed(initializeDelay);
    }
    if (failInitializeAlways) {
      throw GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      );
    }
    if (_remainingFailures > 0) {
      _remainingFailures--;
      throw GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      );
    }
  }

  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) async {
    final error = throwOnAuthenticate?.call();
    if (error != null) throw error;

    return AuthenticationResults(
      user: const GoogleSignInUserData(
        id: 'usr_01',
        email: 'john@example.com',
        displayName: 'John Doe',
      ),
      authenticationTokens: AuthenticationTokenData(idToken: idToken),
    );
  }

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) => null;

  @override
  Future<void> signOut(SignOutParams params) async {}

  @override
  Future<void> disconnect(DisconnectParams params) async {}

  @override
  bool supportsAuthenticate() => true;

  @override
  bool authorizationRequiresUserInteraction() => true;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async => null;

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async => null;
}

/// Restores the "no plugin registered" state between tests, so a fake left
/// installed by one cannot leak into the next.
class _NoPlatform extends GoogleSignInPlatform {
  @override
  Future<void> init(InitParameters params) async =>
      throw UnimplementedError();

  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) =>
      throw UnimplementedError();

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) => null;

  @override
  Future<void> signOut(SignOutParams params) => throw UnimplementedError();

  @override
  Future<void> disconnect(DisconnectParams params) =>
      throw UnimplementedError();

  @override
  bool supportsAuthenticate() => false;

  @override
  bool authorizationRequiresUserInteraction() => true;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) => throw UnimplementedError();

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) => throw UnimplementedError();
}

/// In-memory stand-in for the platform keychain/keystore.
class _FakeStorage implements SecureStorageService {
  String? accessToken;
  String? refreshToken;
  String? userId;
  String? role;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<String?> readUserId() async => userId;

  @override
  Future<String?> readUserRole() async => role;

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> writeSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
  }) async {
    await writeTokens(accessToken: accessToken, refreshToken: refreshToken);
    this.userId = userId;
    this.role = role;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    role = null;
  }
}

/// Serves canned responses and records what was sent.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object? payload, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
