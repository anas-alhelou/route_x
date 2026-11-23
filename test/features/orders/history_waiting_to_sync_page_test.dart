import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/sync_queue_local_data_source.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_waiting_to_sync_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_rows.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/sync_widgets.dart';

import 'fake_network_info.dart';
import 'history_test_support.dart';

const _designSize = Size(412, 917);

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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump();
}

void main() {
  late FakeNetworkInfo network;
  late SyncQueueMockDataSource queue;

  void register({int pending = 2, bool connected = true}) {
    network = FakeNetworkInfo(connected: connected);
    queue = SyncQueueMockDataSource(
      pending: pending,
      uploadDelay: const Duration(milliseconds: 100),
    );
    registerHistory(network: network, syncQueue: queue);
  }

  tearDown(() async {
    unregisterHistory();
    await network.dispose();
  });

  testWidgets('two updates match the design', (tester) async {
    register();
    await _pumpApp(tester, const HistoryWaitingToSyncPage());

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Waiting to sync'), findsOneWidget);
    expect(
      find.text('These are saved on your phone and will upload by '
          'themselves when you have signal.'),
      findsOneWidget,
    );

    expect(find.text('Sari St, Al Zahra'), findsOneWidget);
    expect(
      find.text('#RX-1039 · Delivered 10:05 · photo and status'),
      findsOneWidget,
    );
    expect(find.text('Tahlia St, Al Nahda'), findsOneWidget);
    expect(
      find.text('#RX-1040 · Couldn’t deliver 10:24 · status'),
      findsOneWidget,
    );
    expect(find.byType(HistoryDeliveredBadge), findsOneWidget);
    expect(find.byType(HistoryFailureBadge), findsOneWidget);
    expect(find.byType(SyncWaitingPill), findsNWidgets(2));
    expect(find.text('Waiting'), findsNWidgets(2));

    expect(
      find.text('Don’t sign out or delete the app until these are synced, '
          'or they’ll be lost.'),
      findsOneWidget,
    );
    expect(find.text('Sync now'), findsOneWidget);
  });

  testWidgets('three parts read as a list', (tester) async {
    register(pending: 3);
    await _pumpApp(tester, const HistoryWaitingToSyncPage());

    expect(
      find.text('#RX-1041 · Delivered 10:48 · photo, signature and status'),
      findsOneWidget,
    );
  });

  testWidgets('Sync now with no signal says so and keeps the list',
      (tester) async {
    register(connected: false);
    await _pumpApp(tester, const HistoryWaitingToSyncPage());

    await tester.tap(find.text('Sync now'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('No signal yet. They’ll upload once you’re back online.'),
      findsOneWidget,
    );
    expect(find.byType(SyncWaitingPill), findsNWidgets(2));
    expect(await queue.pendingCount(), 2);
  });

  testWidgets('an upload that drops says so too, and a retry clears it',
      (tester) async {
    register();
    queue.uploadFails = true;
    await _pumpApp(tester, const HistoryWaitingToSyncPage());

    await tester.tap(find.text('Sync now'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.textContaining('No signal yet'), findsOneWidget);

    queue.uploadFails = false;
    await tester.tap(find.text('Sync now'));
    await tester.pump();
    expect(find.textContaining('No signal yet'), findsNothing);
    await tester.pump(const Duration(milliseconds: 150));
  });

  testWidgets('nothing left to upload', (tester) async {
    register(pending: 0);
    await _pumpApp(tester, const HistoryWaitingToSyncPage());

    expect(find.text('Everything is uploaded.'), findsOneWidget);
    expect(find.text('Sync now'), findsNothing);
    expect(find.byType(SyncKeepAppWarning), findsNothing);
  });

  group('from History', () {
    Future<void> openFromHistory(WidgetTester tester) async {
      await _pumpApp(tester, const Scaffold(body: HistoryPage()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('2 updates waiting to sync'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryWaitingToSyncPage), findsOneWidget);
    }

    testWidgets('Sync now uploads, returns to History, and the card is gone',
        (tester) async {
      register();
      await openFromHistory(tester);

      await tester.tap(find.text('Sync now'));
      await tester.pump();
      // Uploading: the label gives way to a spinner.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sync now'), findsNothing);

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryWaitingToSyncPage), findsNothing);
      expect(find.text('31'), findsOneWidget);
      expect(find.byType(HistorySyncCard), findsNothing);
      expect(find.textContaining('not synced yet'), findsNothing);
    });

    testWidgets('Back returns to History unchanged', (tester) async {
      register();
      await openFromHistory(tester);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryWaitingToSyncPage), findsNothing);
      expect(find.text('2 updates waiting to sync'), findsOneWidget);
    });
  });
}
