// test/remember_me_flow_test.dart
//
// Acceptance tests for the "Remember me" feature.
//
//   1. fresh install          -> checkbox unchecked
//   2. box checked, no login  -> nothing persisted, checkbox unchecked again
//   3. box checked + login    -> flag persisted, cold start goes straight home
//   4. box unchecked + login  -> flag false, cold start goes to login
//   5. remembered + logout    -> flag cleared, cold start goes to login
//   6. flag true, no tokens   -> flag reset, cold start goes to login
//   7. failed login           -> nothing persisted
//
// The tests drive the real production classes (LoginBloc, SplashCubit,
// AuthBloc, CheckRememberedSessionUseCase, AuthRepositoryImpl) over a Dio fake
// transport, and only fake the two local storages — so the persistence
// contract itself is what gets verified, not a mock's expectations.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:routex_mobile/core/config/constants/preference_keys.dart';
import 'package:routex_mobile/core/router/app_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';
import 'package:routex_mobile/core/services/local/usecases/clear_user_preferences_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/get_remember_me_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/set_remember_me_usecase.dart';
import 'package:routex_mobile/core/storage/secure_storage_service.dart';
import 'package:routex_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:routex_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';
import 'package:routex_mobile/features/auth/domain/usecases/check_remembered_session_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/get_google_id_token_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/auth_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/auth_event.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/login_bloc.dart';
import 'package:routex_mobile/features/splash/domain/repositories/splash_repository.dart';
import 'package:routex_mobile/features/splash/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:routex_mobile/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:routex_mobile/features/splash/presentation/pages/splash_page.dart';

const _email = 'driver@routex.com';
const _password = 'A!1111111';

void main() {
  late _FakeAppPreferencesService preferences;
  late _FakeSecureStorageService storage;
  // The concrete implementation satisfies both [AuthRepository] (session +
  // hasStoredSession) and [LoginRepository] (login / googleSignIn), exactly as
  // the GetIt registration does.
  late AuthRepositoryImpl repository;

  // Plain async tests: real I/O and real timers, no fake clock to hang on.
  Future<void> runAsync(Future<void> Function() body) => body();

  setUp(() {
    preferences = _FakeAppPreferencesService();
    storage = _FakeSecureStorageService();
    repository = _repositoryWith(storage, _loginSucceeds());
  });

  SetRememberMeUseCase setRememberMe() =>
      SetRememberMeUseCase(preferencesService: preferences);

  LoginBloc buildLoginBloc() => LoginBloc(
    loginUseCase: LoginUseCase(repository: repository),
    googleSignInUseCase: GoogleSignInUseCase(repository: repository),
    getGoogleIdTokenUseCase: GetGoogleIdTokenUseCase(
      service: _FakeGoogleSignInService(),
    ),
    setRememberMeUseCase: setRememberMe(),
  );

  CheckRememberedSessionUseCase buildSessionCheck() =>
      CheckRememberedSessionUseCase(
        getRememberMeUseCase: GetRememberMeUseCase(
          preferencesService: preferences,
        ),
        setRememberMeUseCase: setRememberMe(),
        repository: repository,
      );

  SplashCubit buildSplashCubit() => SplashCubit(
    checkOnboardingStatusUseCase: CheckOnboardingStatusUseCase(
      _FakeSplashRepository(preferences),
    ),
    checkRememberedSessionUseCase: buildSessionCheck(),
  );

  /// Simulates a cold start: a brand new SplashCubit, the 3s brand delay and
  /// the entry screen it selects.
  ///
  /// Only local reads happen here, so the fake clock is enough — the splash
  /// flow makes no network call.
  Future<SplashNavigationState> coldStart() async {
    final cubit = buildSplashCubit();
    final emitted = expectLater(
      cubit.stream,
      emits(
        isA<SplashNavigationState>().having(
          (state) => state,
          'a destination',
          isNot(SplashNavigationState.initial),
        ),
      ),
    );
    cubit.checkNavigationTarget();
    await emitted;
    final destination = cubit.state;
    await cubit.close();
    return destination;
  }

  /// Fills the login form, submits it and waits for the attempt to finish.
  ///
  /// Runs inside [WidgetTester.runAsync] because the login is a real HTTP
  /// round-trip over the fake transport: a widget test's fake clock never
  /// lets real I/O complete on its own.
  Future<LoginState> submitLogin(
    {required bool rememberMe,
  }) async {
    final bloc = buildLoginBloc();
    bloc.add(LoginRememberMeToggled(value: rememberMe));
    bloc.add(const LoginSubmitted(email: _email, password: _password));

    await runAsync(() async {
      await bloc.stream.firstWhere(
        (state) =>
            state.status == LoginStatus.success ||
            state.status == LoginStatus.failure,
      );
      await bloc.close();
    });
    return bloc.state;
  }

  // ── 1. Fresh install -> checkbox unchecked ───────────────────────────────
  test('fresh install opens the login screen with the checkbox unchecked', () {
    final bloc = buildLoginBloc();
    expect(bloc.state.rememberMe, isFalse);
    expect(bloc.state.status, LoginStatus.initial);
    bloc.close();
  });

  test('a login screen is never pre-checked from a previous session', () {
    // The flag is true on disk (a remembered session exists), yet the login
    // screen must still start unchecked: the bloc never reads storage.
    preferences.seedRememberMe = true;
    final bloc = buildLoginBloc();
    expect(bloc.state.rememberMe, isFalse);
    bloc.close();
  });

  // ── 2. Check the box, no login, reopen -> nothing saved ──────────────────
  test('toggling the checkbox persists nothing and reopens unchecked', () async {
    final bloc = buildLoginBloc();
    bloc.add(const LoginRememberMeToggled(value: true));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.rememberMe, isTrue);
    expect(
      preferences.getRememberMe(),
      isFalse,
      reason: 'the checkbox is transient UI state until a login succeeds',
    );

    // "Kill the app": a fresh bloc is unchecked even though the old one ticked.
    await bloc.close();
    final reopened = buildLoginBloc();
    expect(reopened.state.rememberMe, isFalse);
    await reopened.close();
  });

  // ── 3. Checked + successful login -> remembered session ──────────────────
  test('checked login persists the flag and cold starts to home', () async {
    await preferences.setOnboardingCompleted(true);
    final state = await submitLogin(rememberMe: true);

    expect(state.status, LoginStatus.success);
    expect(preferences.getRememberMe(), isTrue);
    expect(
      storage.refreshToken,
      'refresh.jwt',
      reason: 'the repository saved the tokens before the flag was written',
    );

    // Cold start: flag + tokens still on the device -> straight to home.
    expect(await coldStart(), SplashNavigationState.navigateToHome);
  });

  // ── 4. Unchecked + successful login -> login on the next cold start ──────
  test('unchecked login keeps the flag false and cold starts to login', () async {
    await preferences.setOnboardingCompleted(true);
    final state = await submitLogin(rememberMe: false);

    expect(state.status, LoginStatus.success);
    expect(preferences.getRememberMe(), isFalse);
    expect(storage.refreshToken, 'refresh.jwt');

    // Onboarding is a one-time gate, so it is not shown again.
    expect(await coldStart(), SplashNavigationState.navigateToLogin);
  });

  // ── 5. Remembered session + logout -> login on the next cold start ───────
  test('logout clears the flag so the next cold start asks to log in', () async {
    await preferences.setOnboardingCompleted(true);
    final state = await submitLogin(rememberMe: true);
    expect(state.status, LoginStatus.success);
    expect(preferences.getRememberMe(), isTrue);

    // Logout only touches local storage, so the fake clock is enough here.
    final authBloc = AuthBloc(
      repository: repository,
      clearUserPreferencesUseCase: ClearUserPreferencesUseCase(
        preferencesService: preferences,
      ),
    );
    authBloc.add(LogoutRequested());
    await runAsync(() async {
      await authBloc.stream.firstWhere((s) => s is AuthUnauthenticated);
      await authBloc.close();
    });

    expect(authBloc.state, isA<AuthUnauthenticated>());
    expect(storage.refreshToken, isNull);
    expect(
      preferences.getRememberMe(),
      isFalse,
      reason: 'the flag must never outlive the tokens it refers to',
    );

    expect(await coldStart(), SplashNavigationState.navigateToLogin);
    final reopened = buildLoginBloc();
    expect(reopened.state.rememberMe, isFalse);
    await reopened.close();
  });

  // ── 6. Flag true but the tokens are gone -> login ────────────────────────
  test('a stale flag with missing tokens is reset and routes to login', () async {
    preferences.seedRememberMe = true;
    await preferences.setOnboardingCompleted(true);
    expect(storage.refreshToken, isNull);

    expect(await coldStart(), SplashNavigationState.navigateToLogin);
    expect(
      preferences.getRememberMe(),
      isFalse,
      reason: 'the stale flag is cleared so the next launch behaves the same',
    );
  });

  test('a blank refresh token is treated as no session', () async {
    preferences.seedRememberMe = true;
    await preferences.setOnboardingCompleted(true);
    storage.refreshToken = '   ';

    expect(await coldStart(), SplashNavigationState.navigateToLogin);
    expect(preferences.getRememberMe(), isFalse);
  });

  test('a fresh install with no session starts on onboarding', () async {
    expect(
      await coldStart(),
      SplashNavigationState.navigateToOnboarding,
    );
  });

  // ── 7. Failed login with the box checked -> nothing persisted ────────────
  test('a failed login persists nothing', () async {
    repository = _repositoryWith(storage, _loginFails());

    final bloc = buildLoginBloc();
    bloc.add(const LoginRememberMeToggled(value: true));
    bloc.add(const LoginSubmitted(email: _email, password: 'wrong-password'));
    await runAsync(() async {
      await bloc.stream.firstWhere((s) => s.status == LoginStatus.failure);
      await bloc.close();
    });

    expect(bloc.state.status, LoginStatus.failure);
    expect(bloc.state.errorMessage, isNotNull);
    expect(
      preferences.getRememberMe(),
      isFalse,
      reason: 'a rejected attempt must not leave a remembered session behind',
    );
    expect(storage.refreshToken, isNull);
    expect(storage.accessToken, isNull);
  });

  group('entry point', () {
    test('the router starts on the splash route', () {
      final location =
          AppRouter.router.routeInformationProvider.value.uri.toString();
      expect(location, RoutersName.splash);
    });

    testWidgets('the splash listener honours every destination', (
      tester,
    ) async {
      const destinations = <SplashNavigationState, String>{
        SplashNavigationState.navigateToHome: 'HOME',
        SplashNavigationState.navigateToLogin: 'LOGIN',
        SplashNavigationState.navigateToOnboarding: 'ONBOARDING',
      };
      const paths = <SplashNavigationState, String>{
        SplashNavigationState.navigateToHome: RoutersName.mainLayoutScreen,
        SplashNavigationState.navigateToLogin: RoutersName.login,
        SplashNavigationState.navigateToOnboarding: RoutersName.onboarding,
      };

      for (final entry in destinations.entries) {
        final cubit = _ScriptedSplashCubit(entry.key, buildSplashCubit());
        final router = GoRouter(
          initialLocation: RoutersName.splash,
          routes: [
            GoRoute(
              path: RoutersName.splash,
              builder: (_, _) => BlocProvider<SplashCubit>.value(
                value: cubit,
                child: const SplashPage(),
              ),
            ),
            for (final d in destinations.entries)
              GoRoute(path: paths[d.key]!, builder: (_, _) => Text(d.value)),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}');
        await cubit.close();
      }
    });
  });
}

/// Builds the real repository on top of a Dio transport backed by [adapter],
/// so a successful login really does persist the session in [storage].
AuthRepositoryImpl _repositoryWith(
  SecureStorageService storage,
  HttpClientAdapter adapter,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://backend.test'))
    ..httpClientAdapter = adapter;
  return AuthRepositoryImpl(AuthRemoteDataSourceImpl(dio), storage);
}

/// Serves a 200 `/auth/login` body, so the repository persists a real session.
_FakeAdapter _loginSucceeds() => _FakeAdapter((options) async {
  if (options.path == '/auth/login') {
    return _json({
      'success': true,
      'data': {
        'message': 'Login successful',
        'user': {
          'id': 'usr_01',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': _email,
          'role': 'DRIVER',
        },
        'tokens': {
          'accessToken': 'access.jwt',
          'refreshToken': 'refresh.jwt',
        },
      },
      'timestamp': '2026-01-01T00:00:00.000Z',
    });
  }
  return _json({'success': true, 'data': <String, dynamic>{}});
});

/// Serves a 401, mirroring the backend's own "Invalid email or password".
_FakeAdapter _loginFails() => _FakeAdapter(
  (options) async => _json({
    'statusCode': 401,
    'message': 'Invalid email or password',
    'error': 'Unauthorized',
  }, statusCode: 401),
);

/// Builds the JSON response body the data source parses.
ResponseBody _json(Object? payload, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// SplashCubit that skips the brand delay and reports a fixed destination, so
/// the page's listener can be tested in isolation.
class _ScriptedSplashCubit extends SplashCubit {
  _ScriptedSplashCubit(this._destination, SplashCubit source)
    : super(
        checkOnboardingStatusUseCase: source.checkOnboardingStatusUseCase,
        checkRememberedSessionUseCase: source.checkRememberedSessionUseCase,
      );

  final SplashNavigationState _destination;

  @override
  Future<void> checkNavigationTarget() async {
    // SplashPage calls this from initState, before its BlocListener has
    // subscribed. Emit on the next tick (as the real cubit does after its
    // brand delay) so the listener actually receives the destination.
    await Future<void>.delayed(const Duration(milliseconds: 1));
    emit(_destination);
  }
}

/// In-memory stand-in for SharedPreferences, so a "fresh install" is an empty
/// map and a "kill + reopen" keeps exactly the same values on disk.
class _FakeAppPreferencesService implements AppPreferencesService {
  /// Writes the remember-me flag straight into the store, standing in for a
  /// flag left behind by a previous app run.
  set seedRememberMe(bool value) => _store[PreferenceKeys.rememberMe] = value;

  final Map<String, Object> _store = {};

  @override
  bool getRememberMe() => _store[PreferenceKeys.rememberMe] as bool? ?? false;

  @override
  Future<bool> setRememberMe(bool value) async {
    _store[PreferenceKeys.rememberMe] = value;
    return true;
  }

  @override
  Future<bool> clearUserPreferences() async =>
      _store.remove(PreferenceKeys.rememberMe) != null;

  @override
  Future<bool> setLanguageCode(String code) async => true;

  @override
  String? getLanguageCode() => null;

  @override
  Future<bool> setThemeMode(String mode) async => true;

  @override
  String? getThemeMode() => null;

  @override
  Future<bool> setOnboardingCompleted(bool value) async {
    _store[PreferenceKeys.onboardingCompleted] = value;
    return true;
  }

  @override
  bool isOnboardingCompleted() =>
      _store[PreferenceKeys.onboardingCompleted] as bool? ?? false;
}

/// In-memory stand-in for the platform keychain/keystore.
class _FakeSecureStorageService implements SecureStorageService {
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

/// Stands in for the SDK so `LoginBloc` can be built: these tests exercise the
/// email/password path, so the Google branch is never taken.
class _FakeGoogleSignInService implements GoogleSignInService {
  @override
  Future<GoogleAuthResult> signIn() async => const GoogleAuthResult.cancelled();

  @override
  Future<void> signOut() async {}
}

/// Splash repository bound to the same fake preferences instance.
class _FakeSplashRepository implements SplashRepository {
  _FakeSplashRepository(this._preferencesService);

  final AppPreferencesService _preferencesService;

  @override
  bool isOnboardingCompleted() => _preferencesService.isOnboardingCompleted();

  @override
  Future<bool> setOnboardingCompleted(bool value) =>
      _preferencesService.setOnboardingCompleted(value);
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
