import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/app_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_signup_progress.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/pages/signup_flow_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/signup_step1_content.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/signup_back_button.dart';
import 'package:routex_mobile/main.dart';

void main() {
  testWidgets('Signup flow keeps a shared bloc and preserves step data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1704);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    await setupDependencyInjection();
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 4));
    await _pumpFlowTransition(tester);

    AppRouter.router.go(RoutersName.login);
    await _pumpFlowTransition(tester);
    _expectNoSignupFlowException(tester);

    AppRouter.router.pushReplacement(RoutersName.signupFlowScreen);
    await _pumpFlowTransition(tester);
    _expectNoSignupFlowException(tester);
    expect(find.byType(SignupFlowPage), findsOneWidget);
    // Step 1 scrolls rather than scaling itself down when the keyboard opens.
    // (A `FittedBox` may still be present inside the phone field's flag image,
    // so only the scaling wrapper is asserted against.)
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(_scaleDownFittedBoxes(tester), isEmpty);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.physics, isA<NeverScrollableScrollPhysics>());

    final progress = tester.widget<RouteXSignupProgress>(
      find.byType(RouteXSignupProgress),
    );
    expect(progress.currentStep, 1);
    expect(progress.totalSteps, 2);

    final step1Context = tester.element(find.byType(SignupStep1Content));
    final bloc = BlocProvider.of<SignupBloc>(step1Context);
    final step1Fields = find.byType(TextFormField);
    expect(step1Fields, findsNWidgets(4));

    await tester.enterText(step1Fields.at(0), 'John');
    await tester.enterText(step1Fields.at(1), 'Doe');
    await tester.enterText(step1Fields.at(2), 'john@example.com');
    // A number that is a real mobile number for the selected country (PS):
    // the flow validates against the dial-code picker, not just the digit count.
    // The field caps input at the 9-digit national number, so this is
    // `0599114453` with its trunk `0` dropped rather than rejected.
    await tester.enterText(step1Fields.at(3), '599114453');
    await _tapVisible(tester, find.byType(RouteXMainButton));
    await _pumpFlowTransition(tester);

    // Back to step 1, then change the name and submit again: the field keeps
    // what the user typed locally even though the bloc re-saves older data.
    await _tapVisible(tester, find.byType(SignupBackButton));
    await _pumpFlowTransition(tester);
    await tester.enterText(step1Fields.at(0), 'Johnny');
    final firstNameController = tester
        .widget<TextFormField>(step1Fields.at(0))
        .controller;
    bloc.add(
      const SignupStep1Submitted(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '599114453',
        phoneCountryIsoCode: 'PS',
      ),
    );
    await _pumpFlowTransition(tester);
    expect(firstNameController?.text, 'Johnny');
    _expectNoSignupFlowException(tester);

    // Now on the password step (step 2 of 2).
    expect(bloc.state.currentStep, 2);
    await tester.enterText(find.byType(TextFormField).at(0), 'LocalPass1!');
    await tester.enterText(find.byType(TextFormField).at(1), 'LocalPass1!');
    await tester.tap(find.byType(SignupBackButton));
    await _pumpFlowTransition(tester);
    await _tapVisible(tester, find.byType(RouteXMainButton));
    await _pumpFlowTransition(tester);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller
          ?.text,
      '',
    );
    // The password step scrolls too, and never scales the form down.
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(_scaleDownFittedBoxes(tester), isEmpty);
    expect(
      tester.widget<RouteXSignupProgress>(
        find.byType(RouteXSignupProgress),
      ).currentStep,
      2,
    );
    _expectNoSignupFlowException(tester);
  });
}

/// Every `FittedBox` used to shrink a form to fit, which is what the signup
/// steps must not do any more.
///
/// A flag image legitimately uses `BoxFit.cover`, so the fit is what
/// distinguishes the two.
Iterable<FittedBox> _scaleDownFittedBoxes(WidgetTester tester) => tester
    .widgetList<FittedBox>(find.byType(FittedBox))
    .where((box) => box.fit == BoxFit.scaleDown);

Future<void> _pumpFlowTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pumpAndSettle();
}

/// Taps [finder] after bringing it on screen.
///
/// The signup steps now scroll instead of scaling the whole form down to fit,
/// so an action that used to always be visible (the submit button) can
/// legitimately sit below the fold on a short viewport — exactly as it does on
/// a real device once the keyboard is up. `tester.tap` does not scroll for us
/// and would tap empty space instead.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  try {
    await tester.ensureVisible(finder);
  } catch (_) {
    // Fixed non-scrollable header buttons don't have a Scrollable ancestor
  }
  await tester.pump();
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _expectNoSignupFlowException(WidgetTester tester) {
  for (var i = 0; i < 8; i++) {
    final exception = tester.takeException();
    if (exception == null) return;
    final message = exception.toString();
    expect(message, isNot(contains('signup_step1_content')));
    expect(message, isNot(contains('signup_step2_content')));
    expect(message, isNot(contains('auth_password_form_view')));
    expect(message, isNot(contains('password_requirement_checklist')));
    expect(message, isNot(contains('SignupBloc')));
  }
  expect(
    tester.takeException(),
    isNull,
    reason: 'Unexpected number of pending Flutter errors in the signup flow.',
  );
}
