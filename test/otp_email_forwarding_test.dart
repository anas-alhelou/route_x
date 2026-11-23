// test/otp_email_forwarding_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/app_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_role.dart';
import 'package:routex_mobile/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/otp_verification_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/navigation/signup_navigator.dart';
import 'package:routex_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/youre_all_set_page.dart';
import 'package:routex_mobile/main.dart';

class _MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class _MockSignupBloc extends MockBloc<SignupEvent, SignupState>
    implements SignupBloc {}

const String _registeredEmail = 'john@example.com';
const String _correctOtp = '123456';

/// The session `POST /auth/verify-otp` returns for a correct code.
AuthSessionEntity _session() => AuthSessionEntity(
  user: const UserEntity(
    id: 'user-1',
    firstName: 'John',
    lastName: 'Doe',
    email: _registeredEmail,
    role: UserRole.driver,
  ),
  tokens: const AuthTokensEntity(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  ),
);

/// A 2xx that activated the account without signing anyone in.
AuthSessionEntity _sessionWithoutTokens() => AuthSessionEntity(
  user: const UserEntity(
    id: 'user-1',
    firstName: 'John',
    lastName: 'Doe',
    email: _registeredEmail,
    role: UserRole.driver,
  ),
  tokens: const AuthTokensEntity(accessToken: '', refreshToken: ''),
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const VerifyOtpParams(email: 'fallback@example.com', otp: '000000'),
    );
  });

  /// Tall enough that `YoureAllSetPage`'s call to action is on screen and can
  /// actually be tapped; the default test viewport crops it off the bottom.
  const Size tallViewport = Size(1080, 2400);

  Future<void> pumpApp(
    WidgetTester tester,
    SignupBloc bloc, {
    Size viewport = const Size(1080, 1704),
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    // The DI container is global, so it has to be cleared between tests before
    // the registrations can be replayed (and a stubbed use case re-applied).
    await getIt.reset();
    await setupDependencyInjection();
    await tester.pumpWidget(
      BlocProvider<SignupBloc>.value(value: bloc, child: const MyApp()),
    );
    await _pumpFrames(tester);
    AppRouter.router.go(RoutersName.login);
    await _pumpFrames(tester);
  }

  _MockVerifyOtpUseCase stubVerifyOtp({AuthSessionEntity? session}) {
    final useCase = _MockVerifyOtpUseCase();
    when(
      () => useCase(any()),
    ).thenAnswer((_) async => Right(session ?? _session()));
    getIt.unregister<VerifyOtpUseCase>();
    getIt.registerSingleton<VerifyOtpUseCase>(useCase);
    return useCase;
  }

  _MockSignupBloc stubSignupBloc(String email) {
    final bloc = _MockSignupBloc();
    when(() => bloc.state).thenReturn(SignupState(email: email));
    return bloc;
  }

  testWidgets(
    'a correct OTP is verified against the email the code was sent to',
    (tester) async {
      await pumpApp(tester, stubSignupBloc(_registeredEmail));
      // Registered after the container is rebuilt by [pumpApp].
      final useCase = stubVerifyOtp();

      // Reproduce the summary page's post-registration navigation.
      final context = tester.element(find.byType(LoginPage));
      SignupNavigator.goToOtpVerification(context);
      await _pumpFrames(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(OtpVerificationPage), findsOneWidget);
      // The sign-up design omits the address line (showEmail: false); the
      // email is still forwarded to the verification call below.

      final cubit = BlocProvider.of<OtpVerificationCubit>(
        tester.element(find.byType(OtpVerificationPage)),
      );
      expect(cubit.email, _registeredEmail);

      await cubit.verifyOtp(_correctOtp);
      await _pumpFrames(tester);

      // The code is submitted together with the registered email, so a correct
      // code is no longer rejected locally before it reaches the backend.
      verify(
        () => useCase(
          const VerifyOtpParams(email: _registeredEmail, otp: _correctOtp),
        ),
      ).called(1);
      // A correct code is accepted: the screen moves on to the success route.
      // (Asserted through the UI rather than the cubit state, because the
      // resend-cooldown timer keeps re-emitting `OtpVerificationInitial`.)
      expect(find.byType(YoureAllSetPage), findsOneWidget);
    },
  );

  testWidgets('the OTP screen is not reachable without a registered email', (
    tester,
  ) async {
    await pumpApp(tester, stubSignupBloc(_registeredEmail));
    stubVerifyOtp();

    // Reaching the route with no email (e.g. a deep link) must not render a
    // verification screen that would submit an empty email and blame the code.
    AppRouter.router.push(RoutersName.otpVerificationScreen);
    await _pumpFrames(tester);

    expect(find.byType(OtpVerificationPage), findsNothing);
  });

  group('after a correct code', () {
    /// Walks the real navigation up to the celebration screen.
    Future<OtpVerificationCubit> verifyCode(
      WidgetTester tester, {
      AuthSessionEntity? session,
    }) async {
      await pumpApp(
        tester,
        stubSignupBloc(_registeredEmail),
        viewport: tallViewport,
      );
      final useCase = stubVerifyOtp(session: session);

      final context = tester.element(find.byType(LoginPage));
      SignupNavigator.goToOtpVerification(context);
      await _pumpFrames(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final cubit = BlocProvider.of<OtpVerificationCubit>(
        tester.element(find.byType(OtpVerificationPage)),
      );
      await cubit.verifyOtp(_correctOtp);
      await _pumpFrames(tester);

      verify(() => useCase(any())).called(1);
      return cubit;
    }

    testWidgets('the session flag reaches the screen it decides on', (
      tester,
    ) async {
      await verifyCode(tester);

      expect(find.byType(YoureAllSetPage), findsOneWidget);
      expect(
        tester.widget<YoureAllSetPage>(find.byType(YoureAllSetPage)).hasSession,
        isTrue,
        reason: 'the verification returned tokens, so there is a session',
      );
    });

    testWidgets('"Start driving" continues into the app when signed in', (
      tester,
    ) async {
      await verifyCode(tester);

      await tester.tap(find.byType(RouteXMainButton));
      await _pumpFrames(tester);

      // Exactly where LoginPage sends a successful login, so both entry points
      // land on the same first-authenticated screen.
      expect(
        AppRouter.router.routeInformationProvider.value.uri.path,
        RoutersName.joinCompanyScreen,
      );
    });

    testWidgets(
      '"Start driving" goes to the login form when there is no session',
      (tester) async {
        await verifyCode(tester, session: _sessionWithoutTokens());

        // Still a success: a 2xx activated the account, so the user is not
        // shown an error. It simply did not sign anyone in.
        expect(find.byType(YoureAllSetPage), findsOneWidget);
        expect(
          tester
              .widget<YoureAllSetPage>(find.byType(YoureAllSetPage))
              .hasSession,
          isFalse,
        );

        await tester.tap(find.byType(RouteXMainButton));
        await _pumpFrames(tester);

        expect(
          AppRouter.router.routeInformationProvider.value.uri.path,
          RoutersName.login,
        );
      },
    );

    testWidgets('a duplicate submit never replaces the success with an error', (
      tester,
    ) async {
      await pumpApp(tester, stubSignupBloc(_registeredEmail));
      final useCase = stubVerifyOtp();

      final context = tester.element(find.byType(LoginPage));
      SignupNavigator.goToOtpVerification(context);
      await _pumpFrames(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final cubit = BlocProvider.of<OtpVerificationCubit>(
        tester.element(find.byType(OtpVerificationPage)),
      );

      await cubit.verifyOtp(_correctOtp);
      await _pumpFrames(tester);
      // The reported symptom: the same code was sent again and the second,
      // now-consumed attempt came back as "Invalid or expired verification
      // code", so the user was shown an error on a correct code.
      await cubit.verifyOtp(_correctOtp);
      await _pumpFrames(tester);

      verify(() => useCase(any())).called(1);
      expect(find.byType(YoureAllSetPage), findsOneWidget);
      expect(find.byType(OtpVerificationPage), findsNothing);
      expect(
        find.textContaining('Invalid or expired'),
        findsNothing,
        reason: 'no error may follow an accepted verification',
      );
    });
  });
}

/// Pumps a fixed number of frames.
///
/// `pumpAndSettle` cannot be used once the OTP screen is up: its resend
/// cooldown is a periodic timer that keeps requesting frames forever.
Future<void> _pumpFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
  _drainLayoutOverflows(tester);
}

/// Consumes the framework noise this screen produces under test: `RenderFlex`
/// overflows at this viewport size and blocked image fetches. Any other pending
/// Flutter error still fails the test.
void _drainLayoutOverflows(WidgetTester tester) {
  const tolerated = [
    'overflowed',
    // Reported when several of the above were queued in one frame.
    'Multiple exceptions',
    // Network images cannot be fetched in a widget test.
    'NetworkImageLoadException',
    'HTTP request failed',
  ];
  for (var i = 0; i < 20; i++) {
    final exception = tester.takeException();
    if (exception == null) return;
    final message = exception.toString();
    expect(
      tolerated.any(message.contains),
      isTrue,
      reason: 'Unexpected Flutter error: $message',
    );
  }
  expect(tester.takeException(), isNull);
}
