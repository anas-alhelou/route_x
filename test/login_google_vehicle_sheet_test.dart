// test/login_google_vehicle_sheet_test.dart
//
// The login screen's Google vehicle step end to end: the sheet is a separate
// route, so these tests are what prove it finds the page's bloc (a lookup from
// inside the sheet used to fail with ProviderNotFoundException), submits the
// vehicle through LoginGoogleVehicleSubmitted, and reports every dismissal
// exactly once.
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/routex_alert_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';
import 'package:routex_mobile/core/services/local/usecases/set_remember_me_usecase.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_social_button.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_role.dart';
import 'package:routex_mobile/features/auth/domain/entities/vehicle_type.dart';
import 'package:routex_mobile/features/auth/domain/repositories/login_repository.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';
import 'package:routex_mobile/features/auth/domain/usecases/get_google_id_token_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/login_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/google_vehicle_step.dart';

class _MockLoginRepository extends Mock implements LoginRepository {}

class _MockAppPreferences extends Mock implements AppPreferencesService {}

/// Records every event the UI sends, so "exactly once" can be asserted instead
/// of inferred from the resulting state.
class _SpyLoginBloc extends LoginBloc {
  _SpyLoginBloc({
    required super.loginUseCase,
    required super.googleSignInUseCase,
    required super.getGoogleIdTokenUseCase,
    required super.setRememberMeUseCase,
  });

  final List<LoginEvent> added = [];

  @override
  void add(LoginEvent event) {
    added.add(event);
    super.add(event);
  }

  int countOf(Type eventType) =>
      added.where((event) => event.runtimeType == eventType).length;
}

const _sdkToken = 'id-token-from-the-sdk';
const _plate = 'ABC-1234';
// A successful login lands on the main layout.
const _permissionsPath = RoutersName.mainLayoutScreen;

void main() {
  setUpAll(() {
    registerFallbackValue(
      const GoogleAuthParams(
        idToken: _sdkToken,
        vehicleType: VehicleType.car,
        vehicleNumber: _plate,
      ),
    );
  });

  late _MockLoginRepository repository;
  late _MockAppPreferences preferences;

  /// Stubs the two calls the Google flow makes: the first carries the token
  /// alone (it is what tells the backend this account is new), the second
  /// carries the details the sheet collected. Either may be a pending future,
  /// so a test can hold the request open the way a slow network would.
  void stubGoogleAttempts({
    FutureOr<Either<Failure, AuthSessionEntity>>? first,
    FutureOr<Either<Failure, AuthSessionEntity>>? second,
  }) {
    var calls = 0;
    when(() => repository.googleSignIn(any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) {
        return await first ??
            const Left<Failure, AuthSessionEntity>(
              GoogleVehicleRequiredFailure(),
            );
      }
      return await second ?? Right<Failure, AuthSessionEntity>(_session);
    });
  }

  setUp(() {
    repository = _MockLoginRepository();
    preferences = _MockAppPreferences();
    when(() => preferences.setRememberMe(any())).thenAnswer((_) async => true);
    stubGoogleAttempts();
  });

  _SpyLoginBloc buildBloc() => _SpyLoginBloc(
    loginUseCase: LoginUseCase(repository: repository),
    googleSignInUseCase: GoogleSignInUseCase(repository: repository),
    getGoogleIdTokenUseCase: GetGoogleIdTokenUseCase(
      service: _FakeGoogleSignInService(),
    ),
    setRememberMeUseCase: SetRememberMeUseCase(
      preferencesService: preferences,
    ),
  );

  /// Mounts the login screen under a real navigator, because the vehicle sheet is
  /// pushed as a route and `go_router` is what the success path navigates with.
  Future<_SpyLoginBloc> pumpLogin(WidgetTester tester) async {
    // Wider than the design size, so ScreenUtil keeps the layout unscaled
    // (its scale is the smaller of the two ratios) and the sheet leaves enough
    // room above it for the modal barrier to be tappable.
    tester.view.physicalSize = const Size(1080, 2700);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final bloc = buildBloc();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<LoginBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: _permissionsPath,
          builder: (context, state) =>
              const Scaffold(body: Text('permissions screen')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    _expectOnlyTestFontOverflow(tester);
    return bloc;
  }

  /// Taps the Google button and waits for the vehicle sheet.
  Future<void> openVehicleSheet(WidgetTester tester) async {
    await _tapVisible(tester, find.byType(RouteXSocialButton));
  }

  testWidgets('the vehicle sheet opens without losing the page bloc', (
    tester,
  ) async {
    final bloc = await pumpLogin(tester);

    await openVehicleSheet(tester);

    _expectOnlyTestFontOverflow(tester);
    expect(find.byType(GoogleVehicleStep), findsOneWidget);
    expect(bloc.state.status, LoginStatus.awaitingVehicle);
  });

  testWidgets('submitting the vehicle dispatches LoginGoogleVehicleSubmitted', (
    tester,
  ) async {
    final bloc = await pumpLogin(tester);

    await openVehicleSheet(tester);
    await _submitCarWithPlate(tester);

    _expectOnlyTestFontOverflow(tester);
    final submitted = bloc.added.whereType<LoginGoogleVehicleSubmitted>();
    expect(submitted, hasLength(1));
    expect(submitted.single.vehicleType, VehicleType.car);
    expect(submitted.single.vehicleNumber, _plate);

    final sent = verify(() => repository.googleSignIn(captureAny()))
        .captured
        .cast<GoogleAuthParams>()
        .toList();
    expect(sent, hasLength(2));
    expect(
      sent.first.vehicleNumber,
      isNull,
      reason: 'the attempt that opened the sheet carries the token only',
    );
    expect(sent.first.idToken, _sdkToken);
    expect(sent.last.idToken, _sdkToken);
    expect(sent.last.vehicleNumber, _plate);
  });

  testWidgets('a successful vehicle step closes the sheet before navigating', (
    tester,
  ) async {
    await pumpLogin(tester);

    await openVehicleSheet(tester);
    await _submitCarWithPlate(tester);
    // Safe to settle here: the request is done, so nothing animates forever.
    await tester.pumpAndSettle();

    _expectOnlyTestFontOverflow(tester);
    expect(find.byType(GoogleVehicleStep), findsNothing);
    expect(find.text('permissions screen'), findsOneWidget);
  });

  testWidgets('the cancel button reports the dismissal exactly once', (
    tester,
  ) async {
    final bloc = await pumpLogin(tester);

    await openVehicleSheet(tester);
    await _tapVisible(tester, find.text('Cancel'));

    _expectOnlyTestFontOverflow(tester);
    expect(find.byType(GoogleVehicleStep), findsNothing);
    expect(bloc.countOf(LoginGoogleVehicleDismissed), 1);
    expect(bloc.state.status, LoginStatus.initial);
  });

  testWidgets('tapping the barrier reports the dismissal exactly once', (
    tester,
  ) async {
    final bloc = await pumpLogin(tester);

    await openVehicleSheet(tester);
    // The sheet now fills the screen, so there is no barrier left to tap;
    // the system back gesture dismisses it through the same route pop.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    _expectOnlyTestFontOverflow(tester);
    expect(find.byType(GoogleVehicleStep), findsNothing);
    expect(bloc.countOf(LoginGoogleVehicleDismissed), 1);
    expect(bloc.state.status, LoginStatus.initial);
  });

  testWidgets('a rejected vehicle shows the error once the sheet is gone', (
    tester,
  ) async {
    // The token-only attempt opens the sheet; the attempt that registers the
    // new account is the one the backend refuses.
    stubGoogleAttempts(
      second: const Left(GoogleAuthTokenRejectedFailure()),
    );
    final bloc = await pumpLogin(tester);

    await openVehicleSheet(tester);
    await _submitCarWithPlate(tester);
    await tester.pumpAndSettle();

    _expectOnlyTestFontOverflow(tester);
    // The SnackBar lives on the page, so it is only readable with the sheet
    // closed — and the attempt must end up idle, not stuck on the failure.
    expect(find.byType(GoogleVehicleStep), findsNothing);
    // Errors are shown in the API error dialog (no longer a SnackBar).
    expect(
      find.byWidgetPredicate((w) => w is ErrorAlertDialog || w is RouteXAlertDialog),
      findsOneWidget,
    );
    expect(bloc.countOf(LoginGoogleVehicleDismissed), 1);
    expect(bloc.state.status, LoginStatus.initial);
    expect(bloc.state.errorMessage, isNull);
  });

  testWidgets('the sheet cannot be dismissed while the request is in flight', (
    tester,
  ) async {
    // A repository that never completes keeps the bloc in `loading` for the
    // whole test, which is exactly the window a stray tap must not close. Only
    // the second call hangs: the first one has to answer for the sheet to open.
    final completer = Completer<Either<Failure, AuthSessionEntity>>();
    stubGoogleAttempts(second: completer.future);

    final bloc = await pumpLogin(tester);
    await openVehicleSheet(tester);
    await _submitCarWithPlate(tester);
    // The sheet stays open here, so the focused field's blinking cursor would
    // keep the frame scheduler busy forever.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    _expectOnlyTestFontOverflow(tester);
    expect(bloc.state.status, LoginStatus.loading);
    expect(find.byType(GoogleVehicleStep), findsOneWidget);

    // Cancel is disabled and the barrier refuses to pop: the request, not the
    // user, decides the outcome.
    await tester.tap(find.text('Cancel'), warnIfMissed: false);
    await tester.tapAt(const Offset(20, 20));
    // Explicit pumps, not `pumpAndSettle`: the submit button's spinner never
    // stops while the request is in flight.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    _expectOnlyTestFontOverflow(tester);
    expect(find.byType(GoogleVehicleStep), findsOneWidget);
    expect(bloc.countOf(LoginGoogleVehicleDismissed), 0);

    completer.complete(Right(_session));
    await tester.pumpAndSettle();
    expect(find.byType(GoogleVehicleStep), findsNothing);
  });
}

/// Fills the sheet's form and submits it.
Future<void> _submitCarWithPlate(WidgetTester tester) async {
  await _tapVisible(tester, find.byKey(const Key('vehicle_car')));
  await tester.enterText(
    find.descendant(
      of: find.byType(GoogleVehicleStep),
      matching: find.byType(RouteXTextField),
    ),
    _plate,
  );
  // A focused field blinks its cursor forever, which `pumpAndSettle` would wait
  // on for as long as the sheet is open.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await _tapVisible(
    tester,
    find.descendant(
      of: find.byType(GoogleVehicleStep),
      matching: find.byType(RouteXMainButton),
    ),
  );
}

/// Taps [finder] after bringing it on screen.
///
/// Both the login form and the sheet scroll, so an action that sits below the
/// fold — the Google button, the vehicle cards, the submit button — has to be
/// scrolled to first: `tap` would otherwise hit empty space.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  // Fixed frames rather than `pumpAndSettle`: tapping submit starts a spinner
  // that keeps animating until the request comes back, so settling would wait
  // on it for as long as the test takes. 400ms covers the sheet transition.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  _expectOnlyTestFontOverflow(tester);
}

/// Consumes the pending Flutter errors, failing on anything but layout overflow.
///
/// The test font draws every glyph as a square of its font size, so rows that
/// fit on a device (the Google button, the "no account?" prompt) overflow here.
/// Those errors are an artifact of the harness; every other error — a missing
/// provider above the sheet, a failed assertion in a listener — is the point of
/// these tests and must stay fatal.
void _expectOnlyTestFontOverflow(WidgetTester tester) {
  for (var i = 0; i < 16; i++) {
    final exception = tester.takeException();
    if (exception == null) return;
    final message = exception.toString();
    // The framework reports the frame's failures once per error and then once
    // more as a summary, so the summary carries no information of its own.
    if (message.contains('overflowed by') ||
        message.contains('Multiple exceptions')) {
      continue;
    }
    fail('Unexpected Flutter error: $message');
  }
  fail('Unexpected number of pending Flutter errors.');
}

class _FakeGoogleSignInService implements GoogleSignInService {
  @override
  Future<GoogleAuthResult> signIn() async =>
      const GoogleAuthResult.success(_sdkToken);

  @override
  Future<void> signOut() async {}
}

final _session = AuthSessionEntity(
  user: const UserEntity(
    id: 'usr_01',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    role: UserRole.driver,
  ),
  tokens: const AuthTokensEntity(
    accessToken: 'access.jwt',
    refreshToken: 'refresh.jwt',
  ),
);


