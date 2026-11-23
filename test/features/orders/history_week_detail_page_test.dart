import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'history_test_support.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_history_local_data_source.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_history_entity.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_week_detail_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_breakdown_card.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_rows.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_summary_card.dart';

const _designSize = Size(412, 917);
const _source = OrderHistoryLocalDataSourceImpl(loadDelay: Duration.zero);

Future<void> _pumpApp(WidgetTester tester, Widget home) async {
  await tester.binding.setSurfaceSize(_designSize);
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pump();
}

/// Reads the mock on real time: its zero-length delay is still a timer,
/// which the widget test's fake clock would never fire on its own.
Future<OrderHistoryEntity> _history(
  WidgetTester tester,
  HistoryPeriod period,
) async =>
    (await tester.runAsync(() => _source.getHistory(period)))!;

Finder _bar(String semanticsLabel) => find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == semanticsLabel,
    );

void main() {
  testWidgets('the week matches the design', (tester) async {
    final week = await _history(tester, HistoryPeriod.week);
    await _pumpApp(tester, HistoryWeekDetailPage(history: week));

    expect(find.text('History'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(
      find.text('You delivered 31 orders, 4 more than your usual week.'),
      findsOneWidget,
    );
    expect(find.text('Your usual day: 4.4'), findsOneWidget);

    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('94%'), findsOneWidget);
    expect(
      find.text('31 of 33 orders. Cancelled orders don’t count.'),
      findsOneWidget,
    );
    expect(find.text('On the road'), findsOneWidget);
    expect(find.text('21h 40m'), findsOneWidget);
    expect(
      find.text('15h 10m driving · 6h 30m at stops'),
      findsOneWidget,
    );
    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('186 km'), findsOneWidget);
    expect(find.text('About 37 km a day you worked'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Address not found'), 200);
    expect(find.text('Couldn’t deliver'), findsOneWidget);
    expect(find.text('Customer not answering'), findsOneWidget);
    expect(find.text('Address not found'), findsOneWidget);
    expect(
      find.text('Only you and Red Sea Express dispatch can see these '
          'numbers.'),
      findsOneWidget,
    );
  });

  testWidgets('opens on the current day, and a tapped bar takes the heading',
      (tester) async {
    final week = await _history(tester, HistoryPeriod.week);
    await _pumpApp(tester, HistoryWeekDetailPage(history: week));

    expect(find.text('SUNDAY, 11 OCT'), findsOneWidget);
    expect(find.text('2'), findsWidgets);

    await tester.tap(_bar('Wednesday, 7 Oct: 7'));
    await tester.pumpAndSettle();

    expect(find.text('WEDNESDAY, 7 OCT'), findsOneWidget);
    expect(find.text('SUNDAY, 11 OCT'), findsNothing);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('the time split draws both segments, in proportion',
      (tester) async {
    final week = await _history(tester, HistoryPeriod.week);
    await _pumpApp(tester, HistoryWeekDetailPage(history: week));

    Size segment(Color color) => tester.getSize(
          find.descendant(
            of: find.byType(HistoryTimeSplit),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is DecoratedBox &&
                  (w.decoration as BoxDecoration).color == color,
            ),
          ),
        );

    final driving = segment(AppColors.brandMain);
    final stops = segment(AppColors.borderDeactivated);

    expect(driving.height, greaterThan(0), reason: 'the bar must be visible');
    expect(stops.height, greaterThan(0));
    // 910 driving to 390 at stops.
    expect(driving.width / stops.width, closeTo(910 / 390, 0.1));
  });

  testWidgets('a zero day is still tappable', (tester) async {
    final week = await _history(tester, HistoryPeriod.week);
    await _pumpApp(tester, HistoryWeekDetailPage(history: week));

    await tester.tap(_bar('Friday, 9 Oct: 0'));
    await tester.pumpAndSettle();

    expect(find.text('FRIDAY, 9 OCT'), findsOneWidget);
  });

  testWidgets('worded for the period it is given', (tester) async {
    final today = await _history(tester, HistoryPeriod.today);
    await _pumpApp(tester, HistoryWeekDetailPage(history: today));

    expect(find.text('Today'), findsOneWidget);
    expect(
      find.text('You delivered 2 orders, 3 fewer than your usual day.'),
      findsOneWidget,
    );
    // Nothing failed today: no row for it.
    expect(find.text('Couldn’t deliver'), findsNothing);
  });

  testWidgets('a period that matches the usual says so', (tester) async {
    // The month tab draws its own screen now; this only needs a period
    // that lands on the usual, with week-sized bars.
    const month = OrderHistoryEntity(
      period: HistoryPeriod.month,
      rangeLabel: '1 — 11 Oct',
      deliveries: 52,
      comparison: HistoryComparison.usual,
      bars: [
        HistoryBarEntity(label: 'W1', deliveries: 21),
        HistoryBarEntity(label: 'W2', deliveries: 31, isCurrent: true),
      ],
      deliveredPercent: 92,
      distanceKm: 312,
      minutesOnRoad: 2175,
      failedCount: 0,
      days: [],
      assignedCount: 56,
      usualPerBar: 26,
      usualTotal: 52,
      drivingMinutes: 1550,
      stopMinutes: 625,
      workedDays: 8,
    );
    await _pumpApp(tester, const HistoryWeekDetailPage(history: month));

    expect(find.text('This month'), findsOneWidget);
    expect(
      find.text('You delivered 52 orders, the same as your usual month.'),
      findsOneWidget,
    );
  });

  group('opened from the History tab', () {
    setUp(registerHistory);
    tearDown(unregisterHistory);

    Future<void> pumpTab(WidgetTester tester) async {
      await _pumpApp(tester, const Scaffold(body: HistoryPage()));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
    }

    testWidgets('by the summary card, and back', (tester) async {
      await pumpTab(tester);

      await tester.tap(find.byType(HistorySummaryCard));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryWeekDetailPage), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryWeekDetailPage), findsNothing);
    });

    testWidgets('by the couldn’t-deliver card', (tester) async {
      await pumpTab(tester);

      await tester.tap(find.byType(HistoryFailuresCard));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryWeekDetailPage), findsOneWidget);
    });
  });
}
