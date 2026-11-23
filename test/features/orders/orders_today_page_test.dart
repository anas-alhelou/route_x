import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'history_test_support.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_search_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/orders_today_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/models/orders_today_model.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_search_repository_impl.dart';
import 'package:routex_mobile/features/orders/data/repositories/orders_today_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/entities/orders_today_entity.dart';
import 'package:routex_mobile/features/orders/domain/entities/orders_today_snapshot.dart';
import 'package:routex_mobile/features/orders/domain/repositories/orders_today_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_orders_today_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/search_orders_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/orders_today_cubit.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/orders_today_state.dart';
import 'package:routex_mobile/features/orders/presentation/pages/orders_today_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/search_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_empty_state.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/cancellation_notice_banner.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/connection_lost_banner.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/new_orders_banner.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_arrival_toast.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_today_skeleton.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/today_stop_tile.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/upcoming_day_tile.dart';

import 'fake_network_info.dart';
import 'offers_test_support.dart';

const _designSize = Size(412, 917);

/// Serves a fixed day with no delay — for states the mock scenarios do not
/// cover, such as a driver with no fleet.
class _FixedRepository implements OrdersTodayRepository {
  const _FixedRepository(this.day);
  final OrdersTodayEntity day;

  @override
  Future<OrdersTodaySnapshot> getOrdersToday() async =>
      OrdersTodaySnapshot(data: day, updatedAt: DateTime(2025, 10, 11, 9, 42));
}

/// Pumps the Orders / Today screen with its real cubit and the mock data
/// source, so the 1500 ms skeleton window is the one the driver would see.
Future<OrdersTodayCubit> _pumpOrdersToday(
  WidgetTester tester, {
  OrdersTodayMockScenario scenario = OrdersTodayMockScenario.normal,
  OrdersTodayRepository? repository,
  FakeNetworkInfo? network,
  DateTime Function()? clock,
}) async {
  await tester.binding.setSurfaceSize(_designSize);
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final networkInfo = network ?? FakeNetworkInfo();
  addTearDown(networkInfo.dispose);

  final cubit = OrdersTodayCubit(
    getOrdersTodayUseCase: GetOrdersTodayUseCase(
      repository ??
          OrdersTodayRepositoryImpl(
            localDataSource:
                OrdersTodayLocalDataSourceImpl(scenario: scenario),
            networkInfo: networkInfo,
            clock: clock,
          ),
    ),
    networkInfo: networkInfo,
  );
  addTearDown(cubit.close);
  cubit.load();

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
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(create: (_) => noOffersCubit()),
          ],
          child: const OrdersTodayView(),
        ),
      ),
    ),
  );
  await tester.pump();
  return cubit;
}

void main() {
  // The History segment resolves its use case from getIt, as in the app.
  // No delay, so a test that switches segments is not left with a timer.
  setUp(registerHistory);
  tearDown(unregisterHistory);

  testWidgets('shows the skeleton first, then the day plan after 1500ms',
      (tester) async {
    await _pumpOrdersToday(tester);

    // The header is live from the first frame — it is actionable before the
    // data is.
    expect(find.text('Orders'), findsWidgets);
    expect(find.byType(OrdersTodaySkeleton), findsOneWidget);
    expect(find.text('Lina Fares'), findsNothing);

    // Still loading just shy of the specified window.
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(OrdersTodaySkeleton), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.byType(OrdersTodaySkeleton), findsNothing);
    expect(find.text('Lina Fares'), findsOneWidget);
    expect(find.text('2 new orders'), findsOneWidget);
    expect(find.text('3 left · done by 12:40'), findsOneWidget);
    expect(find.text('2 delivered today'), findsOneWidget);
  });

  testWidgets('renders every today stop and upcoming day exactly once',
      (tester) async {
    await _pumpOrdersToday(tester);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    expect(find.byType(TodayStopTile), findsNWidgets(3));
    expect(find.byType(UpcomingDayTile), findsNWidgets(2));

    // Only the current stop carries the pill; the rest get chevrons.
    expect(find.byType(OnTheWayPill), findsOneWidget);
    expect(find.text('On the way'), findsOneWidget);

    expect(find.text('Tomorrow · Mon 12 Oct'), findsOneWidget);
    expect(find.text('Tue 13 Oct'), findsOneWidget);
  });

  testWidgets('the search button opens search, empty, and Cancel returns',
      (tester) async {
    getIt.registerLazySingleton<SearchOrdersUseCase>(
      () => const SearchOrdersUseCase(
        OrderSearchRepositoryImpl(
          localDataSource: OrderSearchLocalDataSourceImpl(),
        ),
      ),
    );
    addTearDown(() => getIt.unregister<SearchOrdersUseCase>());

    await _pumpOrdersToday(tester);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    await tester.tap(find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Search orders',
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SearchView), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, isEmpty);
    expect(find.textContaining('last 4 digits of the phone'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchView), findsNothing);
    expect(find.byType(OrdersTodayView), findsOneWidget);
  });

  testWidgets('tapping History swaps the body and keeps the header',
      (tester) async {
    final cubit = await _pumpOrdersToday(tester);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(cubit.state.segment, OrdersTodaySegment.history);
    expect(find.byType(TodayStopTile), findsNothing);
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('lays out to the redlined gutters', (tester) async {
    await _pumpOrdersToday(tester);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    // Cards and the segmented control sit on the 26dp gutter.
    final stopTile = tester.getRect(find.byType(TodayStopTile).first);
    expect(stopTile.left, moreOrLessEquals(26, epsilon: 1.5));
    expect(stopTile.right, moreOrLessEquals(_designSize.width - 26,
        epsilon: 1.5));

    // Section labels sit 4dp further in, on the 30dp gutter.
    final todayLabel = tester.getTopLeft(find.text('TODAY'));
    expect(todayLabel.dx, moreOrLessEquals(30, epsilon: 1.5));

    // The title keeps its own 26dp gutter.
    final title = tester.getTopLeft(find.text('Orders').first);
    expect(title.dx, moreOrLessEquals(26, epsilon: 1.5));
  });

  group('when dispatch cancels a stop', () {
    Future<OrdersTodayCubit> pumpCancelled(WidgetTester tester) async {
      final cubit = await _pumpOrdersToday(
        tester,
        scenario: OrdersTodayMockScenario.withCancellation,
      );
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();
      return cubit;
    }

    testWidgets('the notice takes the banner slot', (tester) async {
      await pumpCancelled(tester);

      expect(find.byType(CancellationNoticeBanner), findsOneWidget);
      expect(
        find.text('Sara Mansour’s order was cancelled'),
        findsOneWidget,
      );
      expect(
        find.text('Dispatch cancelled #RX-1043 at 9:58. Keep the package in '
            'your van and hand it back at the depot.'),
        findsOneWidget,
      );
      // New orders wait behind it rather than stacking a second banner.
      expect(find.byType(NewOrdersBanner), findsNothing);
      expect(find.text('2 left · done by 12:10'), findsOneWidget);
    });

    testWidgets('the cancelled row is greyed, labelled, and inert',
        (tester) async {
      await pumpCancelled(tester);

      expect(find.byType(CancelledPill), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Al Salamah · return to depot'), findsOneWidget);
      // Its time window no longer applies.
      expect(find.textContaining('Al Salamah · 12:00'), findsNothing);

      final saraRow = find.ancestor(
        of: find.text('Sara Mansour'),
        matching: find.byType(InkWell),
      );
      expect(tester.widget<InkWell>(saraRow.first).onTap, isNull);
    });

    testWidgets('OK dismisses the notice and reveals the queued new orders',
        (tester) async {
      await pumpCancelled(tester);

      await tester.tap(find.text('OK'));
      await tester.pump();

      expect(find.byType(CancellationNoticeBanner), findsNothing);
      expect(find.byType(NewOrdersBanner), findsOneWidget);
      // The stop itself stays cancelled; only the notice is acknowledged.
      expect(find.byType(CancelledPill), findsOneWidget);
    });

    testWidgets('an acknowledged notice stays gone after a refresh',
        (tester) async {
      final cubit = await pumpCancelled(tester);

      await tester.tap(find.text('OK'));
      await tester.pump();

      cubit.load();
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      expect(find.byType(CancellationNoticeBanner), findsNothing);
      expect(find.byType(NewOrdersBanner), findsOneWidget);
    });
  });

  group('when nothing is assigned', () {
    const noFleetDay = OrdersTodayEntity(
      newOrdersCount: 0,
      todayStops: [],
      remainingCount: 0,
      estimatedFinishTime: '',
      deliveredTodayCount: 0,
      upcomingDays: [],
    );

    test('deliveries already made do not stop the day counting as empty',
        () {
      const delivered = OrdersTodayEntity(
        newOrdersCount: 0,
        todayStops: [],
        remainingCount: 0,
        estimatedFinishTime: '',
        deliveredTodayCount: 4,
        upcomingDays: [],
      );
      expect(delivered.isEmpty, isTrue);
    });

    test('an unread cancellation keeps the day from counting as empty', () {
      const cancelled = OrdersTodayEntity(
        newOrdersCount: 0,
        todayStops: [],
        remainingCount: 0,
        estimatedFinishTime: '',
        deliveredTodayCount: 0,
        upcomingDays: [],
        cancellationNotice: CancellationNoticeEntity(
          orderId: 'ORD-1',
          customerName: 'Sara Mansour',
          orderCode: 'RX-1043',
          cancelledAt: '9:58',
        ),
      );
      expect(cancelled.isEmpty, isFalse);
    });

    testWidgets('shows the empty state naming the fleet', (tester) async {
      await _pumpOrdersToday(
        tester,
        scenario: OrdersTodayMockScenario.empty,
      );
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      expect(find.byType(OrdersEmptyState), findsOneWidget);
      expect(find.text('No orders right now'), findsOneWidget);
      expect(
        find.text('When Red Sea Express assigns you orders, they’ll '
            'show up here and we’ll send you a notification.'),
        findsOneWidget,
      );
      expect(find.text('See past orders'), findsOneWidget);

      // Header and segmented control stay; the list scaffolding goes.
      expect(find.text('History'), findsOneWidget);
      expect(find.text('TODAY'), findsNothing);
      expect(find.byType(TodayStopTile), findsNothing);
      expect(find.byType(OrdersTodaySkeleton), findsNothing);
    });

    testWidgets('See past orders switches to History', (tester) async {
      final cubit = await _pumpOrdersToday(
        tester,
        scenario: OrdersTodayMockScenario.empty,
      );
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      await tester.tap(find.text('See past orders'));
      await tester.pumpAndSettle();

      expect(cubit.state.segment, OrdersTodaySegment.history);
      expect(find.byType(OrdersEmptyState), findsNothing);
    });

    testWidgets('without a fleet, the copy falls back to dispatch',
        (tester) async {
      await _pumpOrdersToday(
        tester,
        repository: const _FixedRepository(noFleetDay),
      );
      await tester.pump();

      expect(
        find.text('When dispatch assigns you orders, they’ll show up '
            'here and we’ll send you a notification.'),
        findsOneWidget,
      );
      expect(find.textContaining('Red Sea'), findsNothing);
    });
  });

  group('offline', () {
    final fetchedAt = DateTime(2025, 10, 11, 9, 42);
    DateTime clock() => fetchedAt;

    group('repository', () {
      test('online: serves the live day, stamped with the fetch time',
          () async {
        final repo = OrdersTodayRepositoryImpl(
          localDataSource:
              const OrdersTodayLocalDataSourceImpl(loadDelay: Duration.zero),
          networkInfo: FakeNetworkInfo(),
          clock: clock,
        );

        final snapshot = await repo.getOrdersToday();

        expect(snapshot.offlineReason, isNull);
        expect(snapshot.updatedAt, fetchedAt);
        expect(snapshot.data.todayStops, hasLength(3));
      });

      test('no network and nothing saved: fails with NetworkFailure', () {
        final repo = OrdersTodayRepositoryImpl(
          localDataSource:
              const OrdersTodayLocalDataSourceImpl(loadDelay: Duration.zero),
          networkInfo: FakeNetworkInfo(connected: false),
        );

        expect(repo.getOrdersToday(), throwsA(isA<NetworkFailure>()));
      });

      test('no network after a good fetch: the saved copy, flagged '
          'noConnection, with the original fetch time', () async {
        final network = FakeNetworkInfo();
        var now = fetchedAt;
        final repo = OrdersTodayRepositoryImpl(
          localDataSource:
              const OrdersTodayLocalDataSourceImpl(loadDelay: Duration.zero),
          networkInfo: network,
          clock: () => now,
        );
        await repo.getOrdersToday();

        network.connected = false;
        now = fetchedAt.add(const Duration(minutes: 20));
        final snapshot = await repo.getOrdersToday();

        expect(snapshot.offlineReason, OfflineReason.noConnection);
        expect(snapshot.updatedAt, fetchedAt);
        expect(snapshot.data.todayStops, hasLength(3));
      });

      test('a link that times out: the saved copy, flagged weakSignal',
          () async {
        final source = _FlakySource();
        final repo = OrdersTodayRepositoryImpl(
          localDataSource: source,
          networkInfo: FakeNetworkInfo(),
          clock: clock,
        );
        await repo.getOrdersToday();

        source.failWith = const NetworkFailure('errRequestTimeout');
        final snapshot = await repo.getOrdersToday();

        expect(snapshot.offlineReason, OfflineReason.weakSignal);
        expect(snapshot.updatedAt, fetchedAt);
      });
    });

    group('screen', () {
      const weakLine = 'Showing saved orders · Updated 9:42';
      const cardTitle = 'Couldn’t load new orders';

      Future<void> settleLoaded(WidgetTester tester) async {
        await tester.pump(const Duration(milliseconds: 1600));
        await tester.pump();
      }

      OrdersTodayCubit cubitOf(WidgetTester tester) => tester
          .element(find.byType(OrdersTodayView))
          .read<OrdersTodayCubit>();

      testWidgets('online: neither the line nor the card', (tester) async {
        await _pumpOrdersToday(tester, clock: clock);
        await settleLoaded(tester);

        expect(find.text(weakLine), findsNothing);
        expect(find.byType(ConnectionLostBanner), findsNothing);
        expect(find.byType(NewOrdersBanner), findsOneWidget);
      });

      group('no connection', () {
        testWidgets('losing it mid-use shows the card in the banner slot and '
            'keeps the list', (tester) async {
          final network = FakeNetworkInfo();
          await _pumpOrdersToday(tester, network: network, clock: clock);
          await settleLoaded(tester);

          network.connected = false;
          await tester.pumpAndSettle();

          expect(find.byType(ConnectionLostBanner), findsOneWidget);
          expect(find.text(cardTitle), findsOneWidget);
          expect(
            find.text('Showing what’s saved on this phone'),
            findsOneWidget,
          );
          expect(find.text('Try again'), findsOneWidget);
          // It takes the slot: Review could not load anyway.
          expect(find.byType(NewOrdersBanner), findsNothing);
          // And it says it louder than the line would; not both.
          expect(find.text(weakLine), findsNothing);
          expect(find.text('Lina Fares'), findsOneWidget);
          expect(find.byType(OrdersTodaySkeleton), findsNothing);
        });

        testWidgets('it coming back refreshes in place and clears the card',
            (tester) async {
          final network = FakeNetworkInfo();
          await _pumpOrdersToday(tester, network: network, clock: clock);
          await settleLoaded(tester);
          network.connected = false;
          await tester.pumpAndSettle();

          network.connected = true;
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          // Mid-refresh: still the list, never the skeleton.
          expect(find.byType(OrdersTodaySkeleton), findsNothing);
          expect(find.text('Lina Fares'), findsOneWidget);

          await tester.pump(const Duration(milliseconds: 1100));
          await tester.pumpAndSettle();
          expect(find.byType(ConnectionLostBanner), findsNothing);
          expect(find.byType(NewOrdersBanner), findsOneWidget);
        });

        testWidgets('Try again recovers when coverage returned unannounced',
            (tester) async {
          final network = FakeNetworkInfo();
          await _pumpOrdersToday(tester, network: network, clock: clock);
          await settleLoaded(tester);
          network.connected = false;
          await tester.pumpAndSettle();

          network.setSilently(true);
          await tester.tap(find.text('Try again'));
          await tester.pump(const Duration(milliseconds: 1600));
          await tester.pumpAndSettle();

          expect(find.byType(ConnectionLostBanner), findsNothing);
        });

        testWidgets('Try again with still no network keeps the card',
            (tester) async {
          final network = FakeNetworkInfo();
          await _pumpOrdersToday(tester, network: network, clock: clock);
          await settleLoaded(tester);
          network.connected = false;
          await tester.pumpAndSettle();

          await tester.tap(find.text('Try again'));
          await tester.pumpAndSettle();

          expect(find.byType(ConnectionLostBanner), findsOneWidget);
          expect(find.text('Lina Fares'), findsOneWidget);
        });

        testWidgets('opening the app with nothing saved shows the full-screen '
            'failure, and the list once the network returns', (tester) async {
          final network = FakeNetworkInfo(connected: false);
          await _pumpOrdersToday(tester, network: network, clock: clock);
          await tester.pump();

          expect(find.byType(OrdersEmptyState), findsOneWidget);
          expect(find.text('Couldn’t load your orders'), findsOneWidget);
          expect(
            find.text('Check your signal and try again. If it keeps '
                'happening, call dispatch.'),
            findsOneWidget,
          );
          expect(find.text('Try again'), findsOneWidget);
          // There is no list to qualify, so no card either.
          expect(find.byType(ConnectionLostBanner), findsNothing);
          // Header and segmented control stay.
          expect(find.text('History'), findsOneWidget);

          network.connected = true;
          await tester.pump();
          await settleLoaded(tester);

          expect(find.text('Lina Fares'), findsOneWidget);
          expect(find.byType(OrdersEmptyState), findsNothing);
        });

        testWidgets('its Try again reloads through the skeleton when coverage '
            'returned unannounced', (tester) async {
          final network = FakeNetworkInfo(connected: false);
          await _pumpOrdersToday(tester, network: network, clock: clock);
          await tester.pump();

          network.setSilently(true);
          await tester.tap(find.text('Try again'));
          await tester.pump();

          // The skeleton is the visible proof the tap did something.
          expect(find.byType(OrdersTodaySkeleton), findsOneWidget);

          await settleLoaded(tester);
          expect(find.text('Lina Fares'), findsOneWidget);
        });

        testWidgets('its Try again with still no network comes back to the '
            'same screen', (tester) async {
          final network = FakeNetworkInfo(connected: false);
          await _pumpOrdersToday(tester, network: network, clock: clock);
          await tester.pump();

          await tester.tap(find.text('Try again'));
          await tester.pump();
          await tester.pump();

          expect(find.text('Couldn’t load your orders'), findsOneWidget);
        });
      });

      group('weak signal', () {
        Future<(_FlakySource, FakeNetworkInfo)> pumpWeak(
          WidgetTester tester,
        ) async {
          final network = FakeNetworkInfo();
          final source = _FlakySource();
          await _pumpOrdersToday(
            tester,
            network: network,
            repository: OrdersTodayRepositoryImpl(
              localDataSource: source,
              networkInfo: network,
              clock: clock,
            ),
          );
          // The source's zero-length delay is still a timer: advance the fake
          // clock so the first load actually lands before the signal fades.
          await tester.pump(const Duration(milliseconds: 1));
          expect(cubitOf(tester).state, isA<OrdersTodayLoaded>());

          source.failWith = const NetworkFailure('errRequestTimeout');
          await cubitOf(tester).refresh();
          await tester.pumpAndSettle();
          return (source, network);
        }

        // Each test ends with no retry pending — live again, or upgraded to
        // no-connection — because the binding fails any test that leaves a
        // timer behind. That a close cancels a pending retry is covered at
        // the cubit level below, on real time.
        testWidgets('a failed refresh shows the quiet line, not the card, '
            'and it clears once a retry gets through', (tester) async {
          final (source, _) = await pumpWeak(tester);

          expect(find.text(weakLine), findsOneWidget);
          expect(find.byType(ConnectionLostBanner), findsNothing);
          // A weak signal does not take the banner slot.
          expect(find.byType(NewOrdersBanner), findsOneWidget);
          expect(find.text('Lina Fares'), findsOneWidget);

          source.failWith = null;
          await tester.pump(cubitOf(tester).weakSignalRetryInterval);
          await tester.pumpAndSettle();

          expect(find.text(weakLine), findsNothing);
        });

        testWidgets('losing the link outright upgrades the line to the card',
            (tester) async {
          final (_, network) = await pumpWeak(tester);

          network.connected = false;
          await tester.pumpAndSettle();

          expect(find.text(weakLine), findsNothing);
          expect(find.byType(ConnectionLostBanner), findsOneWidget);
        });
      });
    });
  });

  group('orders arriving', () {
    const toast = '2 orders added to tomorrow';

    /// Loads the day, then pulls to refresh into the one where dispatch has
    /// added two orders to tomorrow.
    Future<void> pumpArrival(WidgetTester tester) async {
      final network = FakeNetworkInfo();
      await _pumpOrdersToday(
        tester,
        network: network,
        repository: OrdersTodayRepositoryImpl(
          localDataSource: OrdersTodayArrivalMockDataSource(
            loadDelay: Duration.zero,
          ),
          networkInfo: network,
        ),
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text(toast), findsNothing,
          reason: 'the first load has nothing to compare against');

      // Start, then pump, then await: the mock's zero-length delay is a timer,
      // and a bare await would wait forever for a clock nothing advances.
      final refreshing = tester
          .element(find.byType(OrdersTodayView))
          .read<OrdersTodayCubit>()
          .refresh();
      await tester.pump(const Duration(milliseconds: 1));
      await refreshing;
      await tester.pump(const Duration(milliseconds: 300));
    }

    /// The toast leaves by itself; every test runs it out so no timer is
    /// left behind.
    Future<void> letToastExpire(WidgetTester tester) async {
      await tester.pump(OrdersArrivalToast.visibleFor);
      await tester.pumpAndSettle();
    }

    testWidgets('a refresh that brings orders shows the toast and marks the '
        'day', (tester) async {
      await pumpArrival(tester);

      expect(find.text(toast), findsOneWidget);
      expect(find.byType(NewCountPill), findsOneWidget);
      expect(find.text('2 new'), findsOneWidget);
      expect(
        find.text('6 orders · Al Rawdah, Al Zahra, Al Nahda'),
        findsOneWidget,
      );
      // As in the design: no review banner for these.
      expect(find.byType(NewOrdersBanner), findsNothing);

      await letToastExpire(tester);
    });

    testWidgets('the toast leaves by itself; the pill stays', (tester) async {
      await pumpArrival(tester);

      await letToastExpire(tester);

      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text(toast),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0);
      expect(find.text('2 new'), findsOneWidget);
    });

    testWidgets('a tap dismisses it early', (tester) async {
      await pumpArrival(tester);

      await tester.tap(find.text(toast));
      await tester.pumpAndSettle();

      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text(toast),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0);
    });
  });
}

/// Fetches normally until told to fail, like a signal that fades mid-route.
class _FlakySource implements OrdersTodayLocalDataSource {
  NetworkFailure? failWith;

  @override
  Future<OrdersTodayModel> getOrdersToday() async {
    final failure = failWith;
    if (failure != null) throw failure;
    return const OrdersTodayLocalDataSourceImpl(loadDelay: Duration.zero)
        .getOrdersToday();
  }
}
