import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'history_test_support.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_history_entity.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_this_month_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_week_detail_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_month_widgets.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_rows.dart';

const _designSize = Size(412, 917);

Future<void> _pumpMonth(WidgetTester tester) async {
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

  await tester.tap(find.text('Month'));
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

/// Days with nothing delivered — a day off, or still to come.
final _dashes = find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.constraints == const BoxConstraints.tightFor(width: 6, height: 3),
);

void main() {
  setUp(registerHistory);
  tearDown(unregisterHistory);

  testWidgets('the month matches the design', (tester) async {
    await _pumpMonth(tester);

    expect(find.byType(HistoryThisMonthPage), findsOneWidget);
    expect(find.text('THIS MONTH'), findsOneWidget);
    expect(find.text('1 — 11 Oct'), findsOneWidget);
    expect(find.text('52'), findsOneWidget);
    expect(find.text('deliveries'), findsOneWidget);
    expect(
      find.text('About the same as your usual month so far.'),
      findsOneWidget,
    );

    // A bar a day; only the first of each week is labelled.
    expect(find.byType(HistoryMonthChart), findsOneWidget);
    for (final day in ['1', '8', '15', '22', '29']) {
      expect(find.text(day), findsOneWidget);
    }
    expect(find.text('11'), findsNothing);
    // 2, 3 and 9 had nothing; 12 to 31 are still to come.
    expect(_dashes, findsNWidgets(3 + 20));

    expect(find.text('92%'), findsOneWidget);
    expect(find.text('312 km'), findsOneWidget);
    expect(find.text('36h 15m'), findsOneWidget);

    expect(find.text('Worth a look'), findsOneWidget);
    expect(
      find.text('Delivered is at 92%, a little under your usual 96%. Most '
          'misses this month: customer not answering (3). Calling before '
          'you arrive can help.'),
      findsOneWidget,
    );

    expect(find.text('WEEKS'), findsOneWidget);
    expect(find.text('This week · 5 — 11 Oct'), findsOneWidget);
    expect(find.text('31 delivered · 2 couldn’t deliver'), findsOneWidget);
    expect(find.text('28 Sep – 4 Oct'), findsOneWidget);
    expect(find.text('21 delivered · 2 couldn’t deliver'), findsOneWidget);
  });

  testWidgets('no failures card and no day list on the month',
      (tester) async {
    await _pumpMonth(tester);

    expect(find.byType(HistoryFailuresCard), findsNothing);
    expect(find.text('DAYS'), findsNothing);
  });

  testWidgets('the summary card opens nothing on the month', (tester) async {
    await _pumpMonth(tester);

    await tester.tap(find.text('52'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryWeekDetailPage), findsNothing);
  });

  testWidgets('This week opens the Week tab; a past week is inert',
      (tester) async {
    await _pumpMonth(tester);

    final past = find.ancestor(
      of: find.text('28 Sep – 4 Oct'),
      matching: find.byType(InkWell),
    );
    expect(tester.widget<InkWell>(past.first).onTap, isNull);

    await tester.ensureVisible(find.text('This week · 5 — 11 Oct'));
    await tester.tap(find.text('This week · 5 — 11 Oct'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.byType(HistoryThisMonthPage), findsNothing);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
  });

  group('Worth a look', () {
    OrderHistoryEntity month({
      required int delivered,
      required int usual,
      DeliveryFailureReason? reason =
          DeliveryFailureReason.customerNotAnswering,
    }) =>
        OrderHistoryEntity(
          period: HistoryPeriod.month,
          rangeLabel: '1 — 11 Oct',
          deliveries: 40,
          comparison: HistoryComparison.usual,
          bars: const [HistoryBarEntity(label: '1', deliveries: 40)],
          deliveredPercent: delivered,
          usualDeliveredPercent: usual,
          distanceKm: 1,
          minutesOnRoad: 1,
          failedCount: 2,
          mostCommonFailure: reason,
          failures: [
            if (reason != null)
              HistoryFailureCountEntity(reason: reason, count: 2),
          ],
          days: const [],
        );

    test('shows only when delivered is under the usual', () {
      expect(month(delivered: 92, usual: 96).deliveredBelowUsual, isTrue);
      expect(month(delivered: 96, usual: 96).deliveredBelowUsual, isFalse);
      expect(month(delivered: 98, usual: 96).deliveredBelowUsual, isFalse);
      // No norm yet for a new driver.
      expect(month(delivered: 80, usual: 0).deliveredBelowUsual, isFalse);
      // Nothing to point at.
      expect(
        month(delivered: 92, usual: 96, reason: null).deliveredBelowUsual,
        isFalse,
      );
    });

    testWidgets('the tip follows the reason', (tester) async {
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: HistoryThisMonthPage(
                  data: month(
                    delivered: 90,
                    usual: 95,
                    reason: DeliveryFailureReason.addressNotFound,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Delivered is at 90%, a little under your usual 95%. Most '
            'misses this month: address not found (2). Checking the pin '
            'before you set off can help.'),
        findsOneWidget,
      );
      // No weeks given: no list.
      expect(find.text('WEEKS'), findsNothing);
    });
  });
}
