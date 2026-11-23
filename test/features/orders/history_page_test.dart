import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'history_test_support.dart';
import 'fake_network_info.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_waiting_to_sync_page.dart';
import 'package:routex_mobile/features/orders/data/datasources/sync_queue_local_data_source.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_history_local_data_source.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_history_entity.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_history_snapshot.dart';
import 'package:routex_mobile/features/orders/domain/repositories/order_history_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_order_history_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/order_history_cubit.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/order_history_state.dart';
import 'package:routex_mobile/features/orders/presentation/pages/history_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_rows.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/history/history_skeleton.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_empty_state.dart';

const _designSize = Size(412, 917);

void _register(
  OrderHistoryRepository repository, {
  FakeNetworkInfo? network,
}) =>
    registerHistory(repository: repository, network: network);

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
  await tester.pump();
}

/// Fails until told otherwise, then serves the real mock.
class _FailingOnceRepository implements OrderHistoryRepository {
  bool fail = true;

  @override
  Future<OrderHistorySnapshot> getHistory(HistoryPeriod period) async {
    if (fail) throw Exception('offline');
    return historyRepository().getHistory(period);
  }
}

/// Each request waits on a completer, so the test picks the finish order.
class _ScriptedRepository implements OrderHistoryRepository {
  final Map<HistoryPeriod, Completer<OrderHistorySnapshot>> pending = {};

  @override
  Future<OrderHistorySnapshot> getHistory(HistoryPeriod period) =>
      (pending[period] = Completer<OrderHistorySnapshot>()).future;
}

void main() {
  tearDown(unregisterHistory);

  group('screen', () {
    setUp(
      () => _register(
        historyRepository(source: const OrderHistoryLocalDataSourceImpl()),
      ),
    );

    testWidgets('shows the skeleton first, then the week after 1500ms',
        (tester) async {
      await _pumpHistory(tester);

      // The chips are live from the first frame.
      expect(find.text('Week'), findsOneWidget);
      expect(find.byType(HistorySkeleton), findsOneWidget);
      expect(find.text('31'), findsNothing);

      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.byType(HistorySkeleton), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(find.byType(HistorySkeleton), findsNothing);
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('the week matches the design', (tester) async {
      await _pumpHistory(tester);
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text('5 — 11 Oct'), findsOneWidget);
      expect(find.text('deliveries'), findsOneWidget);
      expect(find.text('A bit busier than your usual week.'), findsOneWidget);
      for (final day in ['M', 'W', 'F']) {
        expect(find.text(day), findsOneWidget);
      }
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('186 km'), findsOneWidget);
      expect(find.text('21h 40m'), findsOneWidget);

      expect(find.text('2 couldn’t deliver'), findsOneWidget);
      expect(
        find.text('Most common: customer not answering'),
        findsOneWidget,
      );

      expect(find.text('DAYS'), findsOneWidget);
      expect(find.text('Today · Sun 11 Oct'), findsOneWidget);
      expect(find.text('2 delivered so far · 18 km'), findsOneWidget);
      expect(
        find.text('7 of 8 delivered · 4h 05m · 38 km'),
        findsOneWidget,
      );
      expect(find.text('1 in review'), findsOneWidget);
      expect(find.text('Day off'), findsOneWidget);
      expect(
        find.text('4 of 4 delivered · 2h 30m · 24 km'),
        findsOneWidget,
      );
    });

    testWidgets('a day off is inert and shows no chevron', (tester) async {
      await _pumpHistory(tester);
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      final dayOff = find.ancestor(
        of: find.text('Fri 9 Oct'),
        matching: find.byType(InkWell),
      );
      expect(tester.widget<InkWell>(dayOff.first).onTap, isNull);
    });

    testWidgets('switching to Today reloads through the skeleton and words '
        'the summary for a day', (tester) async {
      await _pumpHistory(tester);
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      await tester.tap(find.text('Today'));
      await tester.pump();
      expect(find.byType(HistorySkeleton), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('Quieter than your usual day.'), findsOneWidget);
      // Nothing failed today, so no failures card.
      expect(find.byType(HistoryFailuresCard), findsNothing);
    });
  });

  testWidgets('a failed load shows the error, and Try again recovers',
      (tester) async {
    final repository = _FailingOnceRepository();
    _register(repository);
    await _pumpHistory(tester);
    await tester.pump();

    expect(find.byType(OrdersEmptyState), findsOneWidget);
    expect(find.text('Couldn’t load your orders'), findsOneWidget);

    repository.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.byType(OrdersEmptyState), findsNothing);
    expect(find.text('31'), findsOneWidget);
  });

  test('switching period quickly ends on the last one picked, whatever '
      'order the answers arrive in', () async {
    final repository = _ScriptedRepository();
    final cubit = OrderHistoryCubit(
      getOrderHistoryUseCase: GetOrderHistoryUseCase(repository),
      networkInfo: FakeNetworkInfo(),
    );
    addTearDown(cubit.close);
    final source = historyRepository();

    cubit.load(); // week
    cubit.selectPeriod(HistoryPeriod.month);
    await Future<void>.delayed(Duration.zero);

    // Month answers first, the stale week answer last.
    repository.pending[HistoryPeriod.month]!
        .complete(await source.getHistory(HistoryPeriod.month));
    await Future<void>.delayed(Duration.zero);
    repository.pending[HistoryPeriod.week]!
        .complete(await source.getHistory(HistoryPeriod.week));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.period, HistoryPeriod.month);
    expect(cubit.state.status, OrderHistoryStatus.loaded);
    expect(cubit.state.data?.period, HistoryPeriod.month);
  });

  group('offline, waiting to sync', () {
    late FakeNetworkInfo network;

    setUp(() => network = FakeNetworkInfo());
    tearDown(() => network.dispose());

    /// Loads the week once online so the repository has it saved, then
    /// drops the link and opens the tab.
    Future<void> pumpSaved(
      WidgetTester tester, {
      int pendingSync = 2,
    }) async {
      final queue = SyncQueueMockDataSource(
        pending: pendingSync,
        uploadDelay: Duration.zero,
      );
      final repository = historyRepository(
        network: network,
        syncQueue: queue,
        clock: () => DateTime(2025, 10, 11, 9, 42),
      );
      await tester.runAsync(() => repository.getHistory(HistoryPeriod.week));
      network.setSilently(false);
      registerHistory(
        repository: repository,
        network: network,
        syncQueue: queue,
      );

      await _pumpHistory(tester);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
    }

    testWidgets('the saved week matches the design', (tester) async {
      await pumpSaved(tester);

      expect(
        find.text('Showing saved history · Updated 9:42'),
        findsOneWidget,
      );
      expect(find.text('31'), findsOneWidget);
      expect(find.text('A bit busier than your usual week.'), findsOneWidget);
      expect(find.text('Includes 2 stops not synced yet'), findsOneWidget);

      expect(find.text('2 updates waiting to sync'), findsOneWidget);
      expect(
        find.text('Saved on this phone. They’ll upload on their own.'),
        findsOneWidget,
      );
      expect(find.text('2 couldn’t deliver'), findsOneWidget);
      // Sync first, then failures.
      expect(
        tester.getTopLeft(find.byType(HistorySyncCard)).dy,
        lessThan(tester.getTopLeft(find.byType(HistoryFailuresCard)).dy),
      );

      expect(find.text('DAYS'), findsOneWidget);
    });

    testWidgets('one update reads in the singular', (tester) async {
      await pumpSaved(tester, pendingSync: 1);

      expect(find.text('Includes 1 stop not synced yet'), findsOneWidget);
      expect(find.text('1 update waiting to sync'), findsOneWidget);
      expect(
        find.text('Saved on this phone. It’ll upload on its own.'),
        findsOneWidget,
      );
    });

    testWidgets('the sync card opens the updates waiting to sync',
        (tester) async {
      await pumpSaved(tester);

      await tester.tap(find.text('2 updates waiting to sync'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryWaitingToSyncPage), findsOneWidget);
      expect(find.text('Sari St, Al Zahra'), findsOneWidget);
    });

    testWidgets('back online, the live week replaces it without a skeleton',
        (tester) async {
      await pumpSaved(tester, pendingSync: 0);
      expect(find.textContaining('Showing saved history'), findsOneWidget);

      network.connected = true;
      await tester.pump();
      expect(find.byType(HistorySkeleton), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Showing saved history'), findsNothing);
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('a period never loaded has nothing saved: the error, as '
        'before', (tester) async {
      await pumpSaved(tester);

      await tester.tap(find.text('Today'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(find.text('Couldn’t load your orders'), findsOneWidget);
      expect(find.textContaining('Showing saved history'), findsNothing);
    });

    testWidgets('online with updates still queued: the note and card, no '
        'offline line', (tester) async {
      _register(
        historyRepository(network: network, pendingSync: 2),
        network: network,
      );
      await _pumpHistory(tester);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(find.textContaining('Showing saved history'), findsNothing);
      expect(find.text('Includes 2 stops not synced yet'), findsOneWidget);
      expect(find.text('2 updates waiting to sync'), findsOneWidget);
    });

    testWidgets('nothing waiting: no note, no card', (tester) async {
      await pumpSaved(tester, pendingSync: 0);

      expect(find.textContaining('not synced yet'), findsNothing);
      expect(find.byType(HistorySyncCard), findsNothing);
    });
  });

  group('repository', () {
    test('offline serves the saved copy, stamped with its own fetch time',
        () async {
      final network = FakeNetworkInfo();
      var now = DateTime(2025, 10, 11, 9, 42);
      final repository = historyRepository(
        network: network,
        pendingSync: 3,
        clock: () => now,
      );

      final live = await repository.getHistory(HistoryPeriod.week);
      expect(live.isFromCache, isFalse);

      now = DateTime(2025, 10, 11, 10, 15);
      network.setSilently(false);
      final saved = await repository.getHistory(HistoryPeriod.week);

      expect(saved.isFromCache, isTrue);
      expect(saved.data, live.data);
      expect(saved.updatedAt, DateTime(2025, 10, 11, 9, 42));
      expect(saved.pendingSyncCount, 3);
    });

    test('offline with nothing saved for the period fails', () async {
      final network = FakeNetworkInfo();
      final repository = historyRepository(network: network);
      await repository.getHistory(HistoryPeriod.week);
      network.setSilently(false);

      expect(
        () => repository.getHistory(HistoryPeriod.month),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('a request that times out on a live link falls back too', () async {
      final source = _FlakyHistorySource();
      final repository = historyRepository(source: source);

      await repository.getHistory(HistoryPeriod.week);
      source.fail = true;
      final saved = await repository.getHistory(HistoryPeriod.week);

      expect(saved.isFromCache, isTrue);
    });
  });
}

/// Answers until told to fail with a [NetworkFailure], as a weak signal
/// would.
class _FlakyHistorySource implements OrderHistoryLocalDataSource {
  bool fail = false;

  @override
  Future<OrderHistoryEntity> getHistory(HistoryPeriod period) async {
    if (fail) throw const NetworkFailure();
    return const OrderHistoryLocalDataSourceImpl(loadDelay: Duration.zero)
        .getHistory(period);
  }
}
