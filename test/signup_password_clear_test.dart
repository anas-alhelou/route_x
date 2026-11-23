import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/pages/signup_step2_content.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_password_form_view.dart';

/// Password retention across backward navigation in the signup flow.
///
/// The flow shell keeps both steps alive inside a [PageView], so the
/// `TextEditingController`s owned by [AuthPasswordFormView] on step 2 outlive
/// every page change. Without an explicit wipe, a user who taps back, changes
/// something on step 1 and then moves forward again finds their old password
/// sitting in the field again — which defeats the point of clearing it.
void main() {
  group('Signup step 2 password', () {
    late SignupBloc bloc;

    setUpAll(() async {
      // get_it registrations can only happen once per process, and
      // SignupBloc is a factory, so every test below still gets a brand new
      // bloc that starts at step 1.
      SharedPreferences.setMockInitialValues({});
      await setupDependencyInjection();
    });

    setUp(() {
      bloc = getIt<SignupBloc>();
    });

    /// Mounts step 2 the way the flow shell does: a real [SignupBloc] above it,
    /// and the page left in the tree for the whole test so the controllers
    /// survive "navigation" the way `PageView`'s keep-alive makes them.
    Future<void> showStep2(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(400, 800),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: BlocProvider<SignupBloc>.value(
                value: bloc,
                child: const SignupStep2Content(onBack: _noop),
              ),
            ),
          ),
        ),
      );
    }

    /// Moves the bloc from step 1 to step 2 with valid Step 1 data.
    ///
    /// `ValidateSignupStep1UseCase` only caches credentials in memory, so this
    /// never touches the network.
    Future<void> goToStep2(WidgetTester tester) async {
      bloc.add(
        const SignupStep1Submitted(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          phone: '0599114453',
          phoneCountryIsoCode: 'PS',
        ),
      );
      await _settle(tester);
      expect(bloc.state.currentStep, 2);
    }

    /// The text currently held by the password and confirmation fields.
    List<String?> passwordFieldTexts(WidgetTester tester) => tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .map((field) => field.controller?.text)
        .toList();

    /// Types a password into both fields.
    Future<void> typePassword(WidgetTester tester, String password) async {
      await tester.enterText(find.byType(TextFormField).at(0), password);
      await tester.enterText(find.byType(TextFormField).at(1), password);
    }

    testWidgets('are wiped as soon as the user navigates back to step 1', (
      tester,
    ) async {
      // Mount before reaching step 2: the listener snapshots the bloc state
      // when it is first built, so it has to observe the 1 -> 2 move to be
      // able to recognise the later 2 -> 1 move.
      await showStep2(tester);
      expect(bloc.state.currentStep, 1);

      await goToStep2(tester);

      await typePassword(tester, 'Passw0rd!');
      expect(passwordFieldTexts(tester), ['Passw0rd!', 'Passw0rd!']);

      // This is exactly what the back button on step 2 dispatches.
      bloc.add(const SignupBackToStep1Requested());
      await _settle(tester);

      expect(bloc.state.currentStep, 1);
      expect(passwordFieldTexts(tester), [
        '',
        '',
      ], reason: 'leaving step 2 backwards must clear both fields immediately');
    });

    testWidgets('stay empty when the user comes back to step 2', (
      tester,
    ) async {
      await showStep2(tester);
      await goToStep2(tester);

      await typePassword(tester, 'Passw0rd!');
      expect(passwordFieldTexts(tester), ['Passw0rd!', 'Passw0rd!']);

      bloc.add(const SignupBackToStep1Requested());
      await _settle(tester);
      expect(passwordFieldTexts(tester), ['', '']);

      // Forward again: re-submitting step 1 returns the user to step 2, whose
      // controllers are still mounted and must not have been refilled.
      await goToStep2(tester);

      expect(passwordFieldTexts(tester), [
        '',
        '',
      ], reason: 'the old password must not reappear on the way forward');
    });

    testWidgets('are kept while the flow stays on step 2', (tester) async {
      await showStep2(tester);
      await goToStep2(tester);

      await typePassword(tester, 'Passw0rd!');
      // A non-decreasing step change must never wipe what the user typed.
      // Re-submitting step 1 leaves `currentStep` at 2.
      bloc.add(
        const SignupStep1Submitted(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          phone: '0599114453',
          phoneCountryIsoCode: 'PS',
        ),
      );
      await _settle(tester);

      expect(passwordFieldTexts(tester), [
        'Passw0rd!',
        'Passw0rd!',
      ], reason: 'forward progress must not clear the password');
    });
  });
}

/// Advances a few fixed frames.
///
/// Deliberately not [WidgetTester.pumpAndSettle]: a focused text field keeps
/// its cursor blinking, so another frame is always queued and `pumpAndSettle`
/// never returns. The [tester.runAsync] hop is what lets the bloc's own event
/// stream deliver the state change before the frames are drawn.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// No-op back handler: this test drives the bloc directly, exactly as the flow
/// shell's back button does.
void _noop() {}
