import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/orders/data/datasources/orders_today_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/models/orders_today_model.dart';
import 'package:routex_mobile/features/orders/data/repositories/orders_today_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/entities/orders_today_snapshot.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_orders_today_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/orders_today_cubit.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/orders_today_state.dart';

import 'fake_network_info.dart';

/// A day told apart from others by its new-orders count alone.
OrdersTodayModel _day(int newOrders) => OrdersTodayModel(
      newOrdersCount: newOrders,
      todayStops: const [],
      remainingCount: 0,
      estimatedFinishTime: '',
      deliveredTodayCount: 0,
      upcomingDays: const [],
    );

/// Each fetch waits on a completer the test resolves — so the test decides
/// the order in which overlapping fetches finish.
class _ScriptedSource implements OrdersTodayLocalDataSource {
  final List<Completer<OrdersTodayModel>> pending = [];
  int calls = 0;

  @override
  Future<OrdersTodayModel> getOrdersToday() {
    calls++;
    final completer = Completer<OrdersTodayModel>();
    pending.add(completer);
    return completer.future;
  }
}

/// Answers at once, or fails like a timed-out request when told to.
class _FlakySource implements OrdersTodayLocalDataSource {
  NetworkFailure? failWith;
  int calls = 0;

  @override
  Future<OrdersTodayModel> getOrdersToday() async {
    calls++;
    final failure = failWith;
    if (failure != null) throw failure;
    return _day(0);
  }
}

/// Lets queued microtasks and the cubit's awaits run.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeNetworkInfo network;

  setUp(() => network = FakeNetworkInfo());
  tearDown(() => network.dispose());

  OrdersTodayCubit cubitOver(
    OrdersTodayLocalDataSource source, {
    Duration retry = const Duration(seconds: 30),
  }) {
    return OrdersTodayCubit(
      getOrdersTodayUseCase: GetOrdersTodayUseCase(
        OrdersTodayRepositoryImpl(localDataSource: source, networkInfo: network),
      ),
      networkInfo: network,
      weakSignalRetryInterval: retry,
    );
  }

  group('overlapping fetches', () {
    test('the newest request wins, even when an older one finishes last',
        () async {
      final source = _ScriptedSource();
      final cubit = cubitOver(source);
      addTearDown(cubit.close);

      // First load lands: the list is on screen.
      final first = cubit.load();
      await _settle();
      source.pending[0].complete(_day(1));
      await first;

      // The driver taps Try again (slow), then pulls to refresh (fast).
      final slow = cubit.refresh();
      await _settle();
      final fast = cubit.refresh();
      await _settle();
      expect(source.calls, 3);

      source.pending[2].complete(_day(3)); // newest answers first
      await fast;
      source.pending[1].complete(_day(2)); // the stale answer arrives last
      await slow;

      final state = cubit.state as OrdersTodayLoaded;
      expect(state.data.newOrdersCount, 3,
          reason: 'a superseded fetch must not overwrite a newer one');
    });
  });

  group('weak-signal retry, on real time', () {
    const retry = Duration(milliseconds: 50);
    const pastRetry = Duration(milliseconds: 150);

    test('retries by itself and goes live once a retry gets through',
        () async {
      final source = _FlakySource();
      final cubit = cubitOver(source, retry: retry);
      addTearDown(cubit.close);
      await cubit.load();

      source.failWith = const NetworkFailure('errRequestTimeout');
      await cubit.refresh();
      expect((cubit.state as OrdersTodayLoaded).offline,
          OfflineReason.weakSignal);

      source.failWith = null;
      await Future<void>.delayed(pastRetry);

      expect((cubit.state as OrdersTodayLoaded).offline, isNull);
    });

    test('closing the cubit cancels a pending retry', () async {
      final source = _FlakySource();
      final cubit = cubitOver(source, retry: retry);
      await cubit.load();
      source.failWith = const NetworkFailure('errRequestTimeout');
      await cubit.refresh();
      final callsAtClose = source.calls;

      await cubit.close();
      await Future<void>.delayed(pastRetry);

      expect(source.calls, callsAtClose,
          reason: 'no fetch may run after the page is gone');
    });

    test('no connection at all schedules no retry — the network event does '
        'that job', () async {
      final source = _FlakySource();
      final cubit = cubitOver(source, retry: retry);
      addTearDown(cubit.close);
      await cubit.load();
      final callsBefore = source.calls;

      network.connected = false;
      await _settle();
      await Future<void>.delayed(pastRetry);

      expect((cubit.state as OrdersTodayLoaded).offline,
          OfflineReason.noConnection);
      expect(source.calls, callsBefore);
    });
  });

  group('orders arriving', () {
    UpcomingDayModel upcoming(String id, String label, int newOrders) =>
        UpcomingDayModel(
          id: id,
          dayLabel: label,
          dateLabel: id,
          ordersCount: 4 + newOrders,
          areas: const [],
          newOrdersCount: newOrders,
        );

    OrdersTodayModel dayWith(List<UpcomingDayModel> upcomingDays) =>
        OrdersTodayModel(
          newOrdersCount: 0,
          todayStops: const [],
          remainingCount: 0,
          estimatedFinishTime: '',
          deliveredTodayCount: 0,
          upcomingDays: upcomingDays,
        );

    Future<OrdersTodayCubit> loaded(
      _ScriptedSource source,
      OrdersTodayModel first,
    ) async {
      final cubit = cubitOver(source);
      addTearDown(cubit.close);
      final loading = cubit.load();
      await _settle();
      source.pending.last.complete(first);
      await loading;
      return cubit;
    }

    Future<void> refreshTo(
      OrdersTodayCubit cubit,
      _ScriptedSource source,
      OrdersTodayModel next,
    ) async {
      final refreshing = cubit.refresh();
      await _settle();
      source.pending.last.complete(next);
      await refreshing;
    }

    OrdersArrival? arrivalOf(OrdersTodayCubit cubit) =>
        (cubit.state as OrdersTodayLoaded).arrival;

    test('the first load announces nothing — there is no "before"', () async {
      final source = _ScriptedSource();
      final cubit = await loaded(
        source,
        dayWith([upcoming('mon', 'Tomorrow', 2)]),
      );

      expect(arrivalOf(cubit), isNull);
    });

    test('a refresh that adds orders to one day names that day', () async {
      final source = _ScriptedSource();
      final cubit = await loaded(
        source,
        dayWith([upcoming('mon', 'Tomorrow', 0)]),
      );

      await refreshTo(cubit, source, dayWith([upcoming('mon', 'Tomorrow', 2)]));

      final arrival = arrivalOf(cubit);
      expect(arrival?.count, 2);
      expect(arrival?.dayName, 'tomorrow');
    });

    test('orders landing on several days are counted together, unnamed',
        () async {
      final source = _ScriptedSource();
      final cubit = await loaded(
        source,
        dayWith([upcoming('mon', 'Tomorrow', 0), upcoming('tue', '', 0)]),
      );

      await refreshTo(
        cubit,
        source,
        dayWith([upcoming('mon', 'Tomorrow', 1), upcoming('tue', '', 2)]),
      );

      final arrival = arrivalOf(cubit);
      expect(arrival?.count, 3);
      expect(arrival?.dayName, isNull);
    });

    test('a later refresh with nothing new keeps the same arrival, so the '
        'toast is not shown twice', () async {
      final source = _ScriptedSource();
      final cubit = await loaded(
        source,
        dayWith([upcoming('mon', 'Tomorrow', 0)]),
      );
      final withTwo = dayWith([upcoming('mon', 'Tomorrow', 2)]);
      await refreshTo(cubit, source, withTwo);
      final first = arrivalOf(cubit);

      await refreshTo(cubit, source, withTwo);

      expect(arrivalOf(cubit)?.id, first?.id);
    });

    test('only the increase counts, not the total already marked new',
        () async {
      final source = _ScriptedSource();
      final cubit = await loaded(
        source,
        dayWith([upcoming('mon', 'Tomorrow', 2)]),
      );

      await refreshTo(cubit, source, dayWith([upcoming('mon', 'Tomorrow', 3)]));

      expect(arrivalOf(cubit)?.count, 1);
    });
  });
}
