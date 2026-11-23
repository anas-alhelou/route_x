import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'history_test_support.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_history_local_data_source.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_first_week_empty_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_this_month_page.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_history_entity.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_rows.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_summary_card.dart';

const _designSize = Size(412, 917);

Future<void> _pumpEmptyHistory(WidgetTester tester) async {
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
        home: const Scaffold(body: HistoryPage()),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

/// The flat bars: the chart's slots at their minimum height.
final _dashes = find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.constraints == const BoxConstraints.tightFor(width: 28, height: 4),
);

void main() {
  setUp(
    () => registerHistory(
      repository: historyRepository(
        source: const OrderHistoryLocalDataSourceImpl(
          loadDelay: Duration.zero,
          scenario: OrderHistoryMockScenario.empty,
        ),
      ),
    ),
  );
  tearDown(unregisterHistory);

  testWidgets('a week with nothing delivered matches the design',
      (tester) async {
    await _pumpEmptyHistory(tester);

    expect(find.byType(HistoryFirstWeekEmptyPage), findsOneWidget);

    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('5 — 11 Oct'), findsOneWidget);
    expect(find.text('Not enough data yet'), findsOneWidget);
    expect(
      find.text('After your first few deliveries you’ll see your week here, '
          'compared with your usual week.'),
      findsOneWidget,
    );
    expect(_dashes, findsNWidgets(7));

    expect(find.text('Your finished stops will show up here'), findsOneWidget);
    expect(
      find.text('Each day gets its own record you can open later.'),
      findsOneWidget,
    );
  });

  testWidgets('no figures, failures, days or button — nothing to open',
      (tester) async {
    await _pumpEmptyHistory(tester);

    expect(find.byType(HistorySummaryCard), findsNothing);
    expect(find.byType(HistoryFailuresCard), findsNothing);
    expect(find.text('DAYS'), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(
      find.ancestor(
        of: find.text('Not enough data yet'),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });

  testWidgets('Today is worded for a day', (tester) async {
    await _pumpEmptyHistory(tester);

    await tester.tap(find.text('Today'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('TODAY'), findsOneWidget);
    expect(
      find.text('After your first few deliveries you’ll see your day here, '
          'compared with your usual day.'),
      findsOneWidget,
    );
    expect(_dashes, findsNWidgets(6));
  });

  testWidgets('Month still has the weeks before, so it opens the month',
      (tester) async {
    await _pumpEmptyHistory(tester);

    await tester.tap(find.text('Month'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.byType(HistoryFirstWeekEmptyPage), findsNothing);
    expect(find.byType(HistoryThisMonthPage), findsOneWidget);
    expect(find.text('52'), findsOneWidget);
  });

  test('a month with nothing in it is still the empty state', () {
    const empty = OrderHistoryEntity(
      period: HistoryPeriod.month,
      rangeLabel: '1 — 1 Oct',
      deliveries: 0,
      comparison: HistoryComparison.usual,
      bars: [],
      deliveredPercent: 0,
      distanceKm: 0,
      minutesOnRoad: 0,
      failedCount: 0,
      days: [],
    );
    expect(empty.hasNoDeliveries, isTrue);
  });
}
