// test/features/home/home_widget_test.dart
//
// Pixel-spec assertions for the Home flow's shared components and the three
// Go Online sheets.
//
// The Figma MCP is unavailable in this workspace, so these tests are the only
// executable record of the spec: each expectation here names a token or a
// literal the design fixes. They read *rendered* geometry (RenderBox sizes,
// BoxDecoration fills, resolved text styles) rather than widget constructor
// arguments, so a widget cannot pass by being handed the right value and then
// ignoring it.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_info_card.dart';
import 'package:routex_mobile/core/widgets/routex_primary_cta.dart';
import 'package:routex_mobile/core/widgets/routex_secondary_cta.dart';
import 'package:routex_mobile/core/widgets/routex_top_bar.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_profile.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/domain/entities/setup_progress.dart';
import 'package:routex_mobile/features/home/domain/entities/shift_stats.dart';
import 'package:routex_mobile/features/home/presentation/widgets/find_fleet_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_avatar.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_code_input_row.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_status_badge.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_sheet.dart';
import 'package:routex_mobile/features/home/presentation/widgets/join_button.dart';

/// The Home frame is 412x917 and that is exactly what `main.dart` hands
/// ScreenUtil via [AppSizes.figmaDesignWidth]/[AppSizes.figmaDesignHeight], so
/// the tests scale against the same numbers the app does. Reading the tokens
/// rather than restating the size keeps the two from drifting apart.
final _designSize = Size(
  AppSizes.figmaDesignWidth,
  AppSizes.figmaDesignHeight,
);

void main() {
  Widget wrap(Widget child) => ScreenUtilInit(
    designSize: _designSize,
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );

  // A surface taller than the design is a realistic phone; matching the design
  // width keeps scaleWidth at 1 so widths compare against raw tokens, while
  // scaleHeight picks up the extra height. Both are read from ScreenUtil after
  // the tree is up, so the expectations cannot drift from whatever surface the
  // test set.
  void usePhoneSurface(
    WidgetTester tester, {
    Size size = const Size(412, 1146),
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  double sw(num value) => value * ScreenUtil().scaleWidth;
  double sh(num value) => value * ScreenUtil().scaleHeight;

  BoxDecoration? decorationOf(WidgetTester tester, Finder finder) =>
      tester.widget<Container>(finder).decoration as BoxDecoration?;

  // `find.text` rather than `find.widgetWithText`, which searches ancestors and
  // so never matches the Text that carries the string itself.
  Text textFor(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label).first);

  group('FleetStatusBadge', () {
    Future<void> pump(
      WidgetTester tester,
      FleetBadgeTone tone,
      String label,
    ) async {
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: Center(
              child: FleetStatusBadge(label: label, tone: tone),
            ),
          ),
        ),
      );
    }

    testWidgets('ACTIVE is a solid green pill with white type and a 6pt dot', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await pump(tester, FleetBadgeTone.active, 'ACTIVE');

      final containers = find.descendant(
        of: find.byType(FleetStatusBadge),
        matching: find.byType(Container),
      );
      final pill = decorationOf(tester, containers.at(0));
      expect(pill?.color, AppColors.surfaceBadgeActive);
      expect(pill?.borderRadius, BorderRadius.circular(sw(AppSizes.r3)));

      // The dot is the second Container in the pill: a 6pt circle tinted like
      // the type, because on a saturated fill the dot has to invert too.
      final dot = decorationOf(tester, containers.at(1));
      expect(dot?.shape, BoxShape.circle);
      expect(dot?.color, AppColors.textBadgeActive);
      expect(tester.getSize(containers.at(1)), Size(sw(6), sw(6)));

      final label2 = textFor(tester, 'ACTIVE');
      expect(label2.style?.color, AppColors.textBadgeActive);
      expect(label2.style?.letterSpacing, 1.2);
    });

    testWidgets('PAUSED is a solid grey pill with muted type', (tester) async {
      usePhoneSurface(tester);
      await pump(tester, FleetBadgeTone.paused, 'PAUSED');

      final containers = find.descendant(
        of: find.byType(FleetStatusBadge),
        matching: find.byType(Container),
      );
      expect(
        decorationOf(tester, containers.at(0))?.color,
        AppColors.surfaceBadgePaused,
      );
      expect(
        decorationOf(tester, containers.at(1))?.color,
        AppColors.textBadgePaused,
      );
      expect(textFor(tester, 'PAUSED').style?.color, AppColors.textBadgePaused);
    });

    testWidgets('pads the pill 8pt across and 3pt down', (tester) async {
      usePhoneSurface(tester);
      await pump(tester, FleetBadgeTone.active, 'ACTIVE');

      expect(
        tester.widget<Container>(find.byType(Container).first).padding,
        EdgeInsetsDirectional.symmetric(
          horizontal: sw(AppSpacing.s8),
          vertical: sh(AppSpacing.s3),
        ),
      );
    });
  });

  group('JoinButton', () {
    testWidgets('enabled is a 80x36 filled brand button', (tester) async {
      usePhoneSurface(tester);
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: Center(
              child: JoinButton(label: 'Join', onTap: () => taps++),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(JoinButton)),
        Size(sw(AppSizes.buttonW80), sh(AppSizes.buttonH36)),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(JoinButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, AppColors.brandMain);

      final inner = find.descendant(
        of: find.byType(JoinButton),
        matching: find.byType(Container),
      );
      expect(decorationOf(tester, inner.first)?.border, isNull);
      expect(textFor(tester, 'Join').style?.color, AppColors.brandBlack);

      await tester.tap(find.byType(JoinButton));
      expect(taps, 1);
    });

    testWidgets('disabled narrows to 64 and swaps the fill for an outline', (
      tester,
    ) async {
      usePhoneSurface(tester);
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: Center(
              child: JoinButton(
                label: 'Join',
                isEnabled: false,
                onTap: () => taps++,
              ),
            ),
          ),
        ),
      );

      // The width asymmetry is in the design: an outlined, narrower button is
      // what makes the paused row read as unavailable at a glance.
      expect(
        tester.getSize(find.byType(JoinButton)),
        Size(sw(AppSizes.buttonW64), sh(AppSizes.buttonH36)),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(JoinButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, AppColors.surfaceWhite);

      final inner = find.descendant(
        of: find.byType(JoinButton),
        matching: find.byType(Container),
      );
      final border = decorationOf(tester, inner.first)?.border;
      expect(border, isNotNull);
      expect((border! as Border).top.color, AppColors.borderDeactivated);
      expect(textFor(tester, 'Join').style?.color, AppColors.textMuted);

      await tester.tap(find.byType(JoinButton));
      expect(taps, 0, reason: 'a disabled row must not fire its callback');
    });

    testWidgets('busy replaces the label with a spinner and blocks taps', (
      tester,
    ) async {
      usePhoneSurface(tester);
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: Center(
              child: JoinButton(
                label: 'Join',
                isBusy: true,
                onTap: () => taps++,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Join'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(JoinButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(JoinButton));
      expect(taps, 0);
    });
  });

  group('RouteXInfoCard', () {
    testWidgets('is a white, borderless 10pt card with the info glyph', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(
          const Scaffold(
            body: RouteXInfoCard(
              title: 'Where do I find my code?',
              body: 'body',
            ),
          ),
        ),
      );

      final decoration = decorationOf(tester, find.byType(Container).first);
      expect(decoration?.color, AppColors.surfaceWhite);
      expect(decoration?.borderRadius, BorderRadius.circular(sw(AppSizes.r10)));
      // A white card on a near-white canvas with a hard edge is not what the
      // design draws, so neither is present by default.
      expect(decoration?.border, isNull);
    });

    testWidgets('showIcon false drops the leading glyph', (tester) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(
          const Scaffold(
            body: RouteXInfoCard(
              title: 'Reason from the dispatcher',
              body: 'body',
              showIcon: false,
            ),
          ),
        ),
      );

      expect(find.text('Reason from the dispatcher'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RouteXInfoCard),
          matching: find.byType(SvgPicture),
        ),
        findsNothing,
      );
    });
  });

  group('RouteXTopBar', () {
    testWidgets('puts the back button on the same 26pt margin at any height', (
      tester,
    ) async {
      usePhoneSurface(tester);

      // The design draws one 26pt side margin on both bar heights; an earlier
      // version inset the taller bar to 18, so the two screens disagreed on the
      // back button's x when moving between them.
      for (final height in [AppSizes.topBarH50, AppSizes.topBarH56]) {
        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: RouteXTopBar(onBack: () {}, title: 'Title', height: height),
            ),
          ),
        );

        expect(tester.getSize(find.byType(RouteXTopBar)).height, sh(height));
        expect(
          tester
              .getTopLeft(
                find.descendant(
                  of: find.byType(RouteXTopBar),
                  matching: find.byType(InkWell),
                ),
              )
              .dx,
          moreOrLessEquals(sw(AppSizes.screenGutter)),
          reason: 'back button at height $height',
        );
      }
    });

    testWidgets('pushes its trailing control to the far edge', (tester) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: RouteXTopBar(onBack: () {}, trailing: const Text('pill')),
          ),
        ),
      );

      final surface = tester.getSize(find.byType(RouteXTopBar));
      final trailingRight = tester.getTopRight(find.text('pill')).dx;
      expect(
        trailingRight,
        moreOrLessEquals(surface.width - sw(AppSizes.screenGutter)),
      );
    });
  });

  group('RouteXPrimaryCta', () {
    testWidgets('is a full-width 56pt brand button with 6pt corners', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(const Scaffold(body: RouteXPrimaryCta(label: 'Join fleet'))),
      );

      final size = tester.getSize(find.byType(RouteXPrimaryCta));
      expect(size.height, sh(AppSizes.buttonH56));
      expect(size.width, tester.getSize(find.byType(Scaffold)).width);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor?.resolve({}), AppColors.brandMain);
      final shape = button.style?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(shape?.borderRadius, BorderRadius.circular(sw(AppSizes.r6)));
      expect(textFor(tester, 'Join fleet').style?.fontSize, 16);
    });

    testWidgets('appends the forward arrow only when asked', (tester) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(const Scaffold(body: RouteXPrimaryCta(label: 'Join fleet'))),
      );
      expect(
        find.descendant(
          of: find.byType(RouteXPrimaryCta),
          matching: find.byType(SvgPicture),
        ),
        findsNothing,
      );

      await tester.pumpWidget(
        wrap(
          const Scaffold(
            body: RouteXPrimaryCta(label: 'Join fleet', showArrow: true),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(RouteXPrimaryCta),
          matching: find.byType(SvgPicture),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a null callback disables it', (tester) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(const Scaffold(body: RouteXPrimaryCta(label: 'Join fleet'))),
      );

      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    });
  });

  group('RouteXSecondaryCta', () {
    testWidgets('is outlined, full width and 52pt by default', (tester) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(
          const Scaffold(
            body: RouteXSecondaryCta(label: 'Notification settings'),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(RouteXSecondaryCta)).height,
        sh(AppSizes.buttonH52),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(
        button.style?.backgroundColor?.resolve({}),
        AppColors.surfaceWhite,
      );
      expect(
        button.style?.side?.resolve({})?.color,
        AppColors.borderDeactivated,
      );
    });

    testWidgets('showTrailingArrow puts an arrow on the trailing edge', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(
          const Scaffold(
            body: RouteXSecondaryCta(
              label: 'Enter fleet code',
              showTrailingArrow: true,
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(RouteXSecondaryCta),
          matching: find.byType(SvgPicture),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a leadingWidget switches to the centred layout', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: RouteXSecondaryCta(
              label: 'Notification settings',
              leadingWidget: const Icon(Icons.tune),
              showTrailingArrow: true,
            ),
          ),
        ),
      );

      // Icon + label centred; the trailing-arrow request is ignored because that
      // layout has no free edge to put it in.
      expect(find.byIcon(Icons.tune), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RouteXSecondaryCta),
          matching: find.byType(SvgPicture),
        ),
        findsNothing,
      );

      // The icon and the label travel together as one centred pair with the
      // design's 8pt gap, so the pair — not the label alone — is what sits on
      // the button's centre line.
      final iconRect = tester.getRect(find.byIcon(Icons.tune));
      final labelRect = tester.getRect(find.text('Notification settings'));
      expect(labelRect.left - iconRect.right, moreOrLessEquals(sw(8)));

      final pairCentre = (iconRect.left + labelRect.right) / 2;
      expect(
        pairCentre,
        moreOrLessEquals(
          tester.getSize(find.byType(RouteXSecondaryCta)).width / 2,
        ),
      );
    });
  });

  group('FleetCodeInputRow', () {
    // A controlled row only moves when its parent gives it a new `code`, so
    // every test drives one: a StatefulBuilder stands in for the BLoC, which is
    // the only difference between these and the real screen.
    Widget controlled(String code, ValueChanged<String> onChanged) =>
        wrap(
          Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => FleetCodeInputRow(
                code: code,
                onChanged: (value) => setState(() {
                  code = value;
                  onChanged(value);
                }),
              ),
            ),
          ),
        );

    testWidgets('draws six 52x64 boxes', (tester) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        wrap(Scaffold(body: FleetCodeInputRow(code: '', onChanged: (_) {}))),
      );

      expect(find.byType(TextField), findsNWidgets(6));

      for (var i = 0; i < 6; i++) {
        final box = find
            .ancestor(
              of: find.byType(TextField).at(i),
              matching: find.byType(Container),
            )
            .first;
        expect(
          tester.getSize(box),
          Size(sw(AppSizes.codeBoxW), sh(AppSizes.codeBoxH)),
          reason: 'box $i',
        );
      }
    });

    testWidgets('uppercases input and advances one box at a time', (
      tester,
    ) async {
      usePhoneSurface(tester);
      final codes = <String>[];
      var code = '';
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => FleetCodeInputRow(
                code: code,
                onChanged: (value) {
                  code = value;
                  setState(() {});
                  codes.add(value);
                },
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'r');
      await tester.pump();
      expect(codes.last, 'R');

      await tester.enterText(find.byType(TextField).at(1), 's');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(2), 'x');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(3), '4');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(4), '8');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(5), '2');
      await tester.pump();

      // The valid seed code, entered in lower case.
      expect(codes.last, 'RSX482');
    });

    testWidgets('hasError paints the boxes red without emptying them', (
      tester,
    ) async {
      usePhoneSurface(tester);
      var code = 'WRONG1';
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => FleetCodeInputRow(
                code: code,
                hasError: true,
                onChanged: (value) => setState(() => code = value),
              ),
            ),
          ),
        ),
      );

      final box = find
          .ancestor(
            of: find.byType(TextField).at(0),
            matching: find.byType(Container),
          )
          .first;
      expect(
        (decorationOf(tester, box)?.border! as Border).top.color,
        AppColors.textError,
      );

      // The rejected code is still there to be read and corrected — the row no
      // longer wipes the boxes the moment an error arrives.
      for (var i = 0; i < 6; i++) {
        expect(
          tester.widget<TextField>(find.byType(TextField).at(i)).controller?.text,
          'WRONG1'[i],
        );
      }
    });

    testWidgets('an externally supplied code populates all six boxes silently', (
      tester,
    ) async {
      usePhoneSurface(tester);
      final codes = <String>[];
      var code = '';
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => FleetCodeInputRow(
                code: code,
                onChanged: (value) {
                  code = value;
                  setState(() {});
                  codes.add(value);
                },
              ),
            ),
          ),
        ),
      );

      // The paste path: the parent hands over a new value and the row redraws.
      // onChanged must NOT fire — nothing the driver typed, and feeding it back
      // is what used to make the row write to its parent mid-build.
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: FleetCodeInputRow(code: 'rsx482', onChanged: codes.add),
          ),
        ),
      );
      await tester.pump();

      expect(codes, isEmpty, reason: 'a parent-driven update is not user input');

      for (var i = 0; i < 6; i++) {
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(i))
              .controller
              ?.text,
          'RSX482'[i],
        );
      }
    });

    testWidgets('a long paste into one box clamps to the six boxes', (
      tester,
    ) async {
      usePhoneSurface(tester);
      var code = '';
      await tester.pumpWidget(controlled('', (value) => code = value));

      // Everything lands in box 0. The row fans it out and clamps: no overflow,
      // and the code it reports is the six-character form the BLoC expects.
      await tester.enterText(find.byType(TextField).at(0), 'rsx482999');
      await tester.pump();

      expect(code, 'RSX482');
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 6; i++) {
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(i))
              .controller
              ?.text,
          'RSX482'[i],
        );
      }
    });

    testWidgets('renders six boxes left to right under Arabic', (tester) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: _designSize,
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              // Directionality(RTL) around the row, as an Arabic device would
              // provide.
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: Center(
                  child: FleetCodeInputRow(code: '', onChanged: _noop),
                ),
              ),
            ),
          ),
        ),
      );

      // An alphanumeric code does not mirror: box 0 stays the leftmost one, so
      // the driver reads position 1 as the first character on every device.
      final first = tester.getRect(find.byType(TextField).at(0));
      final last = tester.getRect(find.byType(TextField).at(5));
      expect(first.left, lessThan(last.left));
      expect(find.byType(TextField), findsNWidgets(6));
    });
  });

  group('FindFleetCard', () {
    FleetSummary fleet(FleetJoinStatus status) => FleetSummary(
      id: 'fleet-1',
      name: 'Red Sea Express',
      zone: 'Al Hamra',
      distanceKm: 2.4,
      // A .png path takes the Image.asset branch, whose errorBuilder keeps a
      // missing mark rendering as an empty box instead of throwing.
      logoPath: 'assets/images/png/img_fleet_red_sea_express.png',
      accentColor: 0xFF1B5E20,
      avatarFill: 0xFFF1F8E9,
      status: status,
      driverCount: 12,
    );

    Future<void> pumpCard(WidgetTester tester, FleetJoinStatus status) async {
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: FindFleetCard(fleet: fleet(status), onJoin: () {}),
          ),
        ),
      );
    }

    testWidgets('is a 105pt white card with 10pt corners and a 48pt logo', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await pumpCard(tester, FleetJoinStatus.active);

      final decoration = decorationOf(tester, find.byType(Container).first);
      expect(decoration?.color, AppColors.surfaceWhite);
      expect(decoration?.borderRadius, BorderRadius.circular(sw(AppSizes.r10)));
      expect(decoration?.border, isNotNull);

      final card = tester.getSize(find.byType(FindFleetCard));
      expect(card.height, sh(AppSizes.fleetCardH));

      final logo = tester.getSize(find.byType(FleetAvatar));
      expect(logo, Size(sw(AppSizes.avatarMd), sw(AppSizes.avatarMd)));
    });

    testWidgets('an active fleet shows a green ACTIVE badge and an 80pt Join', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await pumpCard(tester, FleetJoinStatus.active);

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('PAUSED'), findsNothing);
      expect(
        tester.getSize(find.byType(JoinButton)).width,
        sw(AppSizes.buttonW80),
      );
    });

    testWidgets('a paused fleet greys the badge and disables Join at 64pt', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await pumpCard(tester, FleetJoinStatus.paused);

      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.text('ACTIVE'), findsNothing);

      final join = tester.getSize(find.byType(JoinButton));
      expect(join.width, sw(AppSizes.buttonW64));
    });

    testWidgets(
      'isJoinEnabled false disables every row while a join is in flight',
      (tester) async {
        usePhoneSurface(tester);
        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: FindFleetCard(
                fleet: fleet(FleetJoinStatus.active),
                isJoinEnabled: false,
                onJoin: () {},
              ),
            ),
          ),
        );

        // A second tap must not queue a duplicate request, so the override wins
        // even over a fleet that is itself joinable.
        expect(
          tester.getSize(find.byType(JoinButton)).width,
          sw(AppSizes.buttonW64),
        );
      },
    );
  });

  group('GoOnlineSheet', () {
    HomeOverview overviewWith({
      required FleetRequestStatus status,
      String? declineReason,
    }) => HomeOverview(
      profile: const DriverProfile(displayName: 'Sara', avatarPath: ''),
      availability: DriverAvailability(isOnline: false, requestStatus: status),
      stats: const ShiftStats(
        deliveries: 0,
        deliveriesTarget: 0,
        distanceKm: 0,
        shiftDuration: Duration.zero,
      ),
      setup: const SetupProgress(steps: []),
      nearbyFleets: const [],
      fleetRequest: FleetRequest(
        fleetId: 'fleet-red-sea',
        fleetName: 'Red Sea Express',
        fleetLogoPath: 'assets/images/png/img_fleet_red_sea_express.png',
        requestedAt: DateTime(2026, 10, 3, 10, 30),
        status: status,
        declineReason: declineReason,
      ),
    );

    /// Pushes the sheet as a real route so its dismiss callbacks have something
    /// to pop, which is how the frame is reached in the app.
    Future<void> pumpSheet(
      WidgetTester tester, {
      required GoOnlineBlockedReason reason,
      HomeOverview? overview,
    }) async {
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: Align(
                          alignment: Alignment.bottomCenter,
                          child: GoOnlineSheet(
                            reason: reason,
                            overview: overview,
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('all three frames share one white 24pt-topped shell', (
      tester,
    ) async {
      usePhoneSurface(tester);

      for (final reason in GoOnlineBlockedReason.values) {
        await pumpSheet(tester, reason: reason);

        // The sheet's own root Container: white, rounded only at the top, since
        // it sits against the bottom of the screen.
        final shell = find.descendant(
          of: find.byType(GoOnlineSheet),
          matching: find.byType(Container),
        );
        final decoration = decorationOf(tester, shell.first);
        expect(decoration?.color, AppColors.surfaceWhite, reason: '$reason');
        expect(
          decoration?.borderRadius,
          BorderRadius.vertical(top: Radius.circular(sw(AppSizes.r24))),
          reason: '$reason',
        );

        // Pop the pushed route directly: the sheet is shown over a bare
        // Scaffold here, so there is no back button for `pageBack` to find.
        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('no-fleet frame lists the three setup steps, Fleet as next', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await pumpSheet(tester, reason: GoOnlineBlockedReason.noFleet);

      expect(find.text('Join a fleet to go online'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Fleet'), findsOneWidget);
      // Account and Phone are finished; Fleet is the one step left, so it is the
      // only one carrying a numeral instead of a tick.
      expect(find.text('Done'), findsNWidgets(2));
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      expect(find.text('Find a fleet'), findsOneWidget);
      expect(find.text('Enter fleet code'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('pending frame names the fleet, its request time and In review', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await pumpSheet(
        tester,
        reason: GoOnlineBlockedReason.pending,
        overview: overviewWith(status: FleetRequestStatus.pending),
      );

      expect(find.text('Waiting for Red Sea Express'), findsOneWidget);
      expect(find.text('In review'), findsOneWidget);
      // The clock time comes from MaterialLocalizations, not a hardcoded 10:30.
      expect(
        find.text(
          'Requested today, '
          '${MaterialLocalizations.of(tester.element(find.byType(GoOnlineSheet))).formatTimeOfDay(const TimeOfDay(hour: 10, minute: 30))}',
        ),
        findsOneWidget,
      );

      expect(find.text('View request'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      // The setup progress panel belongs to the no-fleet frame only.
      expect(find.text('Done'), findsNothing);
      expect(find.text('Not now'), findsNothing);
    });

    testWidgets(
      'declined frame shows the dispatcher reason when there is one',
      (tester) async {
        usePhoneSurface(tester);
        await pumpSheet(
          tester,
          reason: GoOnlineBlockedReason.declined,
          overview: overviewWith(
            status: FleetRequestStatus.declined,
            declineReason: 'Zone mismatch',
          ),
        );

        expect(
          find.text('Red Sea Express declined your request'),
          findsOneWidget,
        );
        expect(find.text('Reason from the dispatcher'), findsOneWidget);
        expect(find.text('Zone mismatch'), findsOneWidget);

        expect(find.text('Find another fleet'), findsOneWidget);
        expect(find.text('Update my vehicle'), findsOneWidget);
        expect(find.text('Not now'), findsOneWidget);
        expect(find.text('In review'), findsNothing);
      },
    );

    testWidgets('declined frame falls back to the localized default reason', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await pumpSheet(
        tester,
        reason: GoOnlineBlockedReason.declined,
        overview: overviewWith(status: FleetRequestStatus.declined),
      );

      expect(
        find.text(
          "Vehicle type isn't supported. This fleet takes bikes and cars only.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('Not now dismisses the sheet', (tester) async {
      usePhoneSurface(tester);
      await pumpSheet(tester, reason: GoOnlineBlockedReason.noFleet);

      expect(find.byType(GoOnlineSheet), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(find.byType(GoOnlineSheet), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}

void _noop(String _) {}
