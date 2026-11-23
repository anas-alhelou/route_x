// test/features/home/enter_fleet_code_page_test.dart
//
// Page-level flow for Enter Fleet Code, driven through the real BLoC.
//
// The bloc tests already pin the state machine; the row tests already pin the
// six boxes. What is left in between is the wiring that used to break: the page
// used to mirror the code in its own state and hand the row a `GlobalKey`, which
// threw `setState() or markNeedsBuild() called during build` and then a
// duplicate-key exception. These tests exist to fail loudly if that wiring comes
// back, so each one goes through a real gesture on a real widget tree rather
// than calling the bloc directly.
//
// Every assertion is made against *rendered* output — the characters in the
// boxes, the visible error line, the page we land on — because a state-only test
// would still pass if the page stopped drawing the value it holds.
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/usecases/verify_fleet_code_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/enter_fleet_code_bloc.dart';
import 'package:routex_mobile/features/home/presentation/pages/enter_fleet_code_page.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_caption_row.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_error_line.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_footer.dart';
import 'package:routex_mobile/features/home/presentation/widgets/enter_code_help_button.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_code_input_row.dart';

class MockVerifyFleetCodeUseCase extends Mock
    implements VerifyFleetCodeUseCase {}

/// The code the fake fleet in the data layer accepts.
const _validCode = 'RSX482';

/// Same 412x917 canvas the app uses, so ScreenUtil scales exactly as it does on
/// the device and the fixed-height footer cannot collapse onto the boxes.
final _designSize = Size(
  AppSizes.figmaDesignWidth,
  AppSizes.figmaDesignHeight,
);

/// Registers the real Satoshi faces with the test font manager.
///
/// Without this, `flutter test` substitutes a wider fallback and the footer text
/// wraps inside its fixed-height button, which is an artefact of the substitute
/// rather than anything the app does.
Future<void> _loadSatoshi() async {
  const weights = {
    100: 'Satoshi-Light.otf',
    200: 'Satoshi-Light.otf',
    300: 'Satoshi-Light.otf',
    400: 'Satoshi-Regular.otf',
    500: 'Satoshi-Medium.otf',
    600: 'Satoshi-Medium.otf',
    700: 'Satoshi-Bold.otf',
    800: 'Satoshi-Bold.otf',
    900: 'Satoshi-Black.otf',
  };

  for (final entry in weights.entries) {
    final loader = FontLoader(
      'Satoshi${entry.key == 400 ? '' : ' ${entry.key}'}',
    )
      ..addFont(
        File('assets/fonts/satoshi/${entry.value}').readAsBytes().then(
          (bytes) => ByteData.view(Uint8List.fromList(bytes).buffer),
        ),
      );
    await loader.load();
  }
}

void main() {
  setUpAll(_loadSatoshi);

  setUpAll(() {
    registerFallbackValue(const VerifyFleetCodeParams(code: _validCode));
  });

  late MockVerifyFleetCodeUseCase verifyFleetCode;

  final pendingRequest = FleetRequest(
    fleetId: 'fleet-red-sea',
    fleetName: 'Red Sea Express',
    fleetLogoPath: 'assets/images/png/img_fleet_red_sea_express.png',
    requestedAt: DateTime(2026, 10, 3, 10, 30),
    status: FleetRequestStatus.pending,
  );

  setUp(() {
    verifyFleetCode = MockVerifyFleetCodeUseCase();
    // EnterFleetCodePage resolves its own bloc from the container so the route
    // stays a one-liner, so the only way to drive it is to register one.
    getIt.registerFactory<EnterFleetCodeBloc>(
      () => EnterFleetCodeBloc(verifyFleetCodeUseCase: verifyFleetCode),
    );
  });

  tearDown(() => getIt.reset());

  /// Settles the screen with a hard ceiling on how long that may take.
  ///
  /// Deliberately not a bare [WidgetTester.pumpAndSettle]. Two things on this
  /// screen queue frames without end: a focused box blinks its caret forever,
  /// and the primary button draws a `CircularProgressIndicator` for as long as a
  /// verification is in flight (`RouteXPrimaryCta`). `pumpAndSettle` waits for the
  /// frame queue to *drain*, so with either one up it blocks until its own
  /// ten-minute default timeout and the test stops without a verdict instead of
  /// failing — which is exactly how this file used to hang the whole suite.
  /// Releasing focus clears the caret, and the explicit timeout turns anything
  /// still animating into a fast, readable failure rather than a stall.
  Future<void> settle(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle(
      const Duration(milliseconds: 50),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
  }

  /// Mounts the page on top of a stub previous screen.
  ///
  /// The previous screen matters: a successful join calls `context.pop()`, and
  /// popping the only route in a stack is not a journey — with a page beneath it,
  /// "the driver left the code screen" becomes an assertion instead of a hope.
  Future<GoRouter> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = _designSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: RoutersName.homeScreen,
      routes: [
        GoRoute(
          path: RoutersName.homeScreen,
          builder: (context, state) =>
              const Scaffold(body: Text('home screen')),
        ),
        GoRoute(
          path: RoutersName.enterFleetCodeScreen,
          builder: (context, state) => const EnterFleetCodePage(),
        ),
        GoRoute(
          path: RoutersName.findFleetScreen,
          builder: (context, state) =>
              const Scaffold(body: Text('find fleet screen')),
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
        ),
      ),
    );
    router.push(RoutersName.enterFleetCodeScreen);
    await settle(tester);
    return router;
  }

  /// The characters currently drawn in the six boxes, as one string.
  ///
  /// Read out of the [TextField]s rather than the bloc: this is what the driver
  /// can actually see, and it is the thing the old build-phase loop corrupted.
  String boxesText(WidgetTester tester) => tester
      .widgetList<TextField>(find.descendant(
        of: find.byType(FleetCodeInputRow),
        matching: find.byType(TextField),
      ))
      .map((field) => field.controller?.text ?? '')
      .join();

  /// Types into the boxes the way a driver does, one character at a time.
  ///
  /// Goes through `enterText` on individual boxes rather than setting the value
  /// on the bloc, because the fan-out and the focus advance are the behaviour
  /// under test.
  Future<void> typeCode(WidgetTester tester, String code) async {
    for (var i = 0; i < code.length; i++) {
      await tester.enterText(
        find.descendant(
          of: find.byType(FleetCodeInputRow),
          matching: find.byType(TextField),
        ).at(i),
        code[i],
      );
      await tester.pump();
    }
  }

  group('EnterFleetCodePage', () {
    testWidgets('a valid code is verified and leaves the screen', (
      tester,
    ) async {
      when(
        () => verifyFleetCode(any()),
      ).thenAnswer((_) async => Right(pendingRequest));

      await pumpPage(tester);
      expect(boxesText(tester), '');

      await typeCode(tester, 'rsx482');
      expect(boxesText(tester), 'RSX482');

      await tester.tap(find.byType(EnterCodeFooter));
      await settle(tester);

      // Normalized on the way through the bloc, not just in the boxes.
      verify(() => verifyFleetCode(const VerifyFleetCodeParams(code: _validCode)))
          .called(1);
      expect(find.text('home screen'), findsOneWidget);
    });

    testWidgets('an invalid code keeps its characters so it can be corrected', (
      tester,
    ) async {
      when(
        () => verifyFleetCode(any()),
      ).thenAnswer((_) async => Left(const ValidationFailure('errFleetCodeInvalid')));

      await pumpPage(tester);
      await typeCode(tester, 'ZZ9999');

      await tester.tap(find.byType(EnterCodeFooter));
      await settle(tester);

      expect(find.byType(EnterCodeErrorLine), findsOneWidget);
      expect(find.byType(EnterCodeCaptionRow), findsNothing);
      expect(find.byType(EnterCodeHelpButton), findsOneWidget);

      // The point of the fix: the rejected code is still on screen to be
      // corrected. The old row emptied its boxes here and left nothing to fix.
      expect(boxesText(tester), 'ZZ9999');
      expect(find.text('home screen'), findsNothing);
    });

    testWidgets('Try again empties the boxes and dismisses the error', (
      tester,
    ) async {
      when(
        () => verifyFleetCode(any()),
      ).thenAnswer((_) async => Left(const ValidationFailure('errFleetCodeInvalid')));

      await pumpPage(tester);
      await typeCode(tester, 'ZZ9999');
      await tester.tap(find.byType(EnterCodeFooter));
      await settle(tester);
      expect(find.byType(EnterCodeErrorLine), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await settle(tester);

      expect(find.byType(EnterCodeErrorLine), findsNothing);
      expect(find.byType(EnterCodeCaptionRow), findsOneWidget);
      expect(find.byType(EnterCodeHelpButton), findsNothing);
      // Cleared through a BLoC event, so the boxes redraw themselves empty with
      // no imperative call and no key reaching into the row's State.
      expect(boxesText(tester), '');
    });

    testWidgets('a long paste through the caption fills six boxes and no more', (
      tester,
    ) async {
      await pumpPage(tester);

      // Faked on the platform channel rather than stubbed at a seam: the caption
      // button goes out to the clipboard for real and the page hands the raw
      // string to the bloc, so this exercises the whole path including the
      // normalization the bloc applies to it.
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        SystemChannels.platform,
        // Clipboard.getData answers with a map, which is where its `.text` in
        // the page comes from; returning a bare string would silently look like
        // an empty clipboard.
        (call) async => call.method == 'Clipboard.getData'
            ? <String, dynamic>{'text': 'RSX-482 9999'}
            : null,
      );
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await tester.tap(find.text('Paste'));
      await settle(tester);

      expect(boxesText(tester), 'RSX482');
    });

    testWidgets('an Arabic layout still shows the boxes left to right', (
      tester,
    ) async {
      tester.view.physicalSize = _designSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        initialLocation: RoutersName.enterFleetCodeScreen,
        routes: [
          GoRoute(
            path: RoutersName.enterFleetCodeScreen,
            builder: (context, state) => const EnterFleetCodePage(),
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
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await settle(tester);

      final row = tester.getRect(find.byType(FleetCodeInputRow));
      final firstBox = tester.getRect(
        find
            .descendant(
              of: find.byType(FleetCodeInputRow),
              matching: find.byType(TextField),
            )
            .first,
      );

      // A mirrored row would put box 1 on the right, so an Arabic driver reading
      // left to right would take the last character of the code as the first.
      expect(firstBox.left, lessThan(row.right));
      expect(
        firstBox.center.dx,
        lessThan(row.center.dx),
        reason: 'the first box must stay on the left under an RTL locale',
      );

      await typeCode(tester, 'RSX482');
      expect(boxesText(tester), 'RSX482');
    });
  });
}