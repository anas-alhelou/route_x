import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/dialogs/routex_alert_dialog.dart';
import 'package:routex_mobile/features/join_company/data/datasources/join_company_remote_datasource.dart';
import 'fake_join_company_remote.dart';
import 'package:routex_mobile/features/join_company/data/repositories/join_company_repository_impl.dart';
import 'package:routex_mobile/features/join_company/domain/repositories/join_company_repository.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/cancel_company_request_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/get_request_status_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/send_company_request_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/verify_company_code_usecase.dart';
import 'package:routex_mobile/features/join_company/presentation/bloc/join_company_bloc.dart';
import 'package:routex_mobile/features/join_company/presentation/pages/company_under_review_page.dart';
import 'package:routex_mobile/features/join_company/presentation/pages/confirm_company_page.dart';
import 'package:routex_mobile/features/join_company/presentation/pages/enter_company_code_page.dart';

final _designSize = Size(
  AppSizes.figmaDesignWidth,
  AppSizes.figmaDesignHeight,
);

void main() {
  setUp(() {
    getIt.reset();

    final dataSource = FakeJoinCompanyRemote();
    final repository = JoinCompanyRepositoryImpl(dataSource);
    final verifyUseCase = VerifyCompanyCodeUseCase(repository);
    final sendUseCase = SendCompanyRequestUseCase(repository);
    final getStatusUseCase = GetRequestStatusUseCase(repository);
    final cancelUseCase = CancelCompanyRequestUseCase(repository);

    getIt.registerLazySingleton<JoinCompanyRemoteDataSource>(() => dataSource);
    getIt.registerLazySingleton<JoinCompanyRepository>(() => repository);
    getIt.registerLazySingleton(() => verifyUseCase);
    getIt.registerLazySingleton(() => sendUseCase);
    getIt.registerLazySingleton(() => getStatusUseCase);
    getIt.registerLazySingleton(() => cancelUseCase);

    getIt.registerLazySingleton<JoinCompanyBloc>(
      () => JoinCompanyBloc(
        verifyCompanyCodeUseCase: verifyUseCase,
        sendCompanyRequestUseCase: sendUseCase,
        getRequestStatusUseCase: getStatusUseCase,
        cancelCompanyRequestUseCase: cancelUseCase,
      ),
    );
  });

  tearDown(() {
    getIt.reset();
  });

  Future<void> settle(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<GoRouter> pumpJoinCompanyApp(
    WidgetTester tester, {
    String initialLocation = RoutersName.joinCompanyScreen,
  }) async {
    tester.view.physicalSize = _designSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          name: RoutersName.joinCompanyScreen,
          path: RoutersName.joinCompanyScreen,
          builder: (context, state) => const EnterCompanyCodePage(),
        ),
        GoRoute(
          name: RoutersName.confirmCompanyScreen,
          path: RoutersName.confirmCompanyScreen,
          builder: (context, state) => const ConfirmCompanyPage(),
        ),
        GoRoute(
          name: RoutersName.companyUnderReviewScreen,
          path: RoutersName.companyUnderReviewScreen,
          builder: (context, state) => const CompanyUnderReviewPage(),
        ),
        GoRoute(
          path: RoutersName.login,
          builder: (context, state) =>
              const Scaffold(body: Text('login screen')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        minTextAdapt: true,
        builder: (context, _) => MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );
    await settle(tester);
    return router;
  }

  group('Join Company Flow Integration Tests', () {
    testWidgets('J01 renders title, subtitle, caption, info card, and continue button',
        (tester) async {
      await pumpJoinCompanyApp(tester);

      expect(
        find.byWidgetPredicate((w) =>
            w is RichText &&
            w.text.toPlainText().contains('Join your') &&
            w.text.toPlainText().contains('company.')),
        findsOneWidget,
      );
      expect(find.text('Letters and numbers, not case-sensitive'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('Where do I find my code?'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('J02 shows invalid code error when entering RSX481', (tester) async {
      await pumpJoinCompanyApp(tester);

      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('RSX481'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await settle(tester);

      // The code is only checked when the request is sent, so J04 comes first.
      await tester.tap(find.text('Send request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      expect(
        find.text("We couldn't find a company with this code. Check it and try again."),
        findsOneWidget,
      );

      // Typing any character clears error back to J01
      bloc.add(const CompanyCodeChanged('RSX48'));
      await settle(tester);
      expect(
        find.text("We couldn't find a company with this code. Check it and try again."),
        findsNothing,
      );
    });

    testWidgets('J03 shows disabled code error when entering KTW210', (tester) async {
      await pumpJoinCompanyApp(tester);

      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('KTW210'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await settle(tester);

      await tester.tap(find.text('Send request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      expect(
        find.text('This code is turned off. Ask your company for a new one.'),
        findsOneWidget,
      );
    });

    testWidgets('J04 navigates to Confirm Company on valid code RSX482', (tester) async {
      await pumpJoinCompanyApp(tester);

      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('RSX482'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await settle(tester);

      // Verify J04 contents
      expect(
        find.byWidgetPredicate((w) =>
            w is RichText &&
            w.text.toPlainText().contains('Is this your') &&
            w.text.toPlainText().contains('company?')),
        findsOneWidget,
      );
      expect(find.text('Company code · RSX482'), findsOneWidget);
      expect(find.text('What happens next'), findsOneWidget);
      expect(find.text('Send request'), findsOneWidget);
      expect(find.text('Not my company'), findsOneWidget);
    });

    testWidgets('J10 & J10b flow: Send request -> Under review -> Check for updates',
        (tester) async {
      await pumpJoinCompanyApp(tester);

      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('RSX484'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await settle(tester);

      // Tap Send request on J04
      await tester.tap(find.text('Send request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      // Verify J10 Under review contents
      expect(find.textContaining('Hamza Barakat'), findsOneWidget);
      expect(find.text('Driver account'), findsOneWidget);
      expect(find.text('Waiting for Red Sea Express'), findsOneWidget);
      expect(find.text('Under review'), findsOneWidget);
      expect(find.text('Your request'), findsOneWidget);
      expect(find.text('Request sent'), findsOneWidget);
      expect(find.text('Company review'), findsOneWidget);
      expect(find.text('Start getting orders'), findsOneWidget);
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.text('Cancel request'), findsOneWidget);

      // Trigger update check (J10b)
      bloc.add(const CheckForUpdatesRequested());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Checking for updates...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1600));
      await settle(tester);
      expect(find.text('Pull down to check for updates'), findsOneWidget);
    });
    testWidgets('J10 Cancel request -> confirm resets the flow without errors',
        (tester) async {
      await pumpJoinCompanyApp(tester);

      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('RSX484'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await settle(tester);
      await tester.tap(find.text('Send request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);
      expect(find.text('Contact support'), findsOneWidget);

      await tester.tap(find.text('Cancel request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);
      // J11 bottom sheet
      expect(find.text('Cancel your request?'), findsOneWidget);
      expect(find.text('Keep my request'), findsOneWidget);
      expect(
        find.text(
          "Red Sea Express won't see your request anymore. "
          'You can join again later with a code.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Yes, cancel request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Contact support'), findsNothing);
      expect(find.text('Continue'), findsOneWidget); // back on J01
      expect(bloc.state.currentStep, JoinCompanyStep.enterCode);
      expect(bloc.state.verifiedCompany, isNull);
      expect(bloc.state.reviewStatus, isNull);
      expect(bloc.state.code, isEmpty);
    });

    testWidgets('J11 Keep my request closes the sheet and stays on the page',
        (tester) async {
      await pumpJoinCompanyApp(tester);

      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('RSX484'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await settle(tester);
      await tester.tap(find.text('Send request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      await tester.tap(find.text('Cancel request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);
      await tester.tap(find.text('Keep my request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Contact support'), findsOneWidget);
      expect(bloc.state.currentStep, JoinCompanyStep.underReview);
    });

    testWidgets('J04 Not my company pops back to J01 without errors',
        (tester) async {
      await pumpJoinCompanyApp(tester);

      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('RSX482'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await settle(tester);
      expect(find.text('Not my company'), findsOneWidget);

      // The button sits below the fold at the Figma size: scroll to it first.
      await tester.ensureVisible(find.text('Not my company'));
      await tester.pump();
      await tester.tap(find.text('Not my company'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Not my company'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
      expect(bloc.state.currentStep, JoinCompanyStep.enterCode);
    });

    testWidgets(
        'J04 Not my company goes to J01 when J04 is the only page in the stack',
        (tester) async {
      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('RSX482'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await tester.pump();

      await pumpJoinCompanyApp(
        tester,
        initialLocation: RoutersName.confirmCompanyScreen,
      );
      expect(find.text('Not my company'), findsOneWidget);

      // The button sits below the fold at the Figma size: scroll to it first.
      await tester.ensureVisible(find.text('Not my company'));
      await tester.pump();
      await tester.tap(find.text('Not my company'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Continue'), findsOneWidget);
    });
    testWidgets('Log out on J01 and J10 reaches the login screen without errors',
        (tester) async {
      await pumpJoinCompanyApp(tester);
      await tester.tap(find.text('Log out'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(RouteXAlertDialog),
          matching: find.text('Log out'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('login screen'), findsOneWidget);
    });

    testWidgets('Log out on J10 (under review) reaches the login screen',
        (tester) async {
      await pumpJoinCompanyApp(tester);
      final bloc = getIt<JoinCompanyBloc>();
      bloc.add(const CompanyCodeChanged('RSX484'));
      await tester.pump();
      bloc.add(const VerifyCodeSubmitted());
      await settle(tester);
      await tester.tap(find.text('Send request'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);

      await tester.tap(find.text('Log out'));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(RouteXAlertDialog),
          matching: find.text('Log out'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('login screen'), findsOneWidget);
    });
  });
}
