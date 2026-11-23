import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_history_local_data_source.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_week_detail_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_rows.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_summary_card.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_row_tile.dart';

import 'fake_network_info.dart';
import 'history_test_support.dart';

const _designSize = Size(412, 917);

Future<void> _pumpHistory(WidgetTester tester) async {
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
        home: const Scaffold(body: HistoryPage()),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

void main() {
  late FakeNetworkInfo network;

  setUp(() {
    network = FakeNetworkInfo();
    registerHistory(
      network: network,
      repository: historyRepository(
        network: network,
        source: OrderHistorySummaryFailsOnceMockDataSource(
          inner: const OrderHistoryLocalDataSourceImpl(
            loadDelay: Duration.zero,
          ),
        ),
      ),
    );
  });
  tearDown(() async {
    unregisterHistory();
    await network.dispose();
  });

  testWidgets('the week without its summary matches the design',
      (tester) async {
    await _pumpHistory(tester);

    expect(find.byType(HistorySummaryErrorCard), findsOneWidget);
    expect(find.byType(HistorySummaryCard), findsNothing);
    expect(find.text('This week’s summary didn’t load'), findsOneWidget);
    expect(find.text('Your days below are up to date.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    // No figures shown as if they were real.
    expect(find.text('0'), findsNothing);
    expect(find.text('THIS WEEK'), findsNothing);

    // The failures and the days came through.
    expect(find.text('2 couldn’t deliver'), findsOneWidget);
    expect(find.text('DAYS'), findsOneWidget);
    expect(find.text('Today · Sun 11 Oct'), findsOneWidget);
    expect(find.text('1 in review'), findsOneWidget);
  });

  testWidgets('the failures row has no detail to open without a summary',
      (tester) async {
    await _pumpHistory(tester);

    final row = find.descendant(
      of: find.byType(HistoryFailuresCard),
      matching: find.byType(InkWell),
    );
    expect(tester.widget<InkWell>(row.first).onTap, isNull);
    expect(
      find.descendant(
        of: find.byType(HistoryFailuresCard),
        matching: find.byType(OrdersRowChevron),
      ),
      findsNothing,
    );

    await tester.tap(find.text('2 couldn’t deliver'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryWeekDetailPage), findsNothing);
  });

  testWidgets('Retry brings the summary back in place', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await _settle(tester);

    expect(find.byType(HistorySummaryErrorCard), findsNothing);
    expect(find.text('31'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    // And the failures row opens the detail again.
    expect(
      find.descendant(
        of: find.byType(HistoryFailuresCard),
        matching: find.byType(OrdersRowChevron),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a Retry that fails keeps the card, ready to try again',
      (tester) async {
    await _pumpHistory(tester);
    network.setSilently(false);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await _settle(tester);

    expect(find.byType(HistorySummaryErrorCard), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('DAYS'), findsOneWidget);
  });

  testWidgets('the month says weeks', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text('Month'));
    await _settle(tester);

    expect(find.text('This month’s summary didn’t load'), findsOneWidget);
    expect(find.text('Your weeks below are up to date.'), findsOneWidget);
    expect(find.text('WEEKS'), findsOneWidget);
    expect(find.text('Worth a look'), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await _settle(tester);
    expect(find.text('52'), findsOneWidget);
  });

  testWidgets('today is worded for the day', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text('Today'));
    await _settle(tester);

    expect(find.text('Today’s summary didn’t load'), findsOneWidget);
    expect(find.text('Your days below are up to date.'), findsOneWidget);
  });
}
