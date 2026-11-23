// lib/features/orders/presentation/controllers/orders_today_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/network_info.dart';

import '../../domain/entities/orders_today_entity.dart';
import '../../domain/entities/orders_today_snapshot.dart';
import '../../domain/usecases/get_orders_today_usecase.dart';
import 'orders_today_state.dart';

class OrdersTodayCubit extends Cubit<OrdersTodayState> {
  OrdersTodayCubit({
    required GetOrdersTodayUseCase getOrdersTodayUseCase,
    required NetworkInfo networkInfo,
    this.weakSignalRetryInterval = const Duration(seconds: 30),
  })  : _getOrdersTodayUseCase = getOrdersTodayUseCase,
        _networkInfo = networkInfo,
        super(const OrdersTodayInitial()) {
    _networkSubscription =
        networkInfo.onStatusChange.listen(_onNetworkChanged);
  }

  final GetOrdersTodayUseCase _getOrdersTodayUseCase;
  final NetworkInfo _networkInfo;
  late final StreamSubscription<bool> _networkSubscription;

  /// How long to wait before trying again on a weak signal. There is no
  /// event that says "the signal got better", so the cubit polls — slowly,
  /// to spare a battery that is already working hard to hold the link.
  final Duration weakSignalRetryInterval;
  Timer? _retryTimer;

  /// Held here rather than only in the state, because [load] passes through
  /// a loading state that carries no data — the acknowledgement must outlive
  /// it, or a pull-to-refresh would resurface a notice already dismissed.
  final Set<String> _acknowledgedNoticeIds = {};

  /// Bumped on every fetch. Only the newest fetch may change the state, so a
  /// slow Try again that finishes after a quick pull-to-refresh cannot put
  /// older data — or a stale failure — back on screen.
  int _generation = 0;

  /// First load: the skeleton, then the day.
  Future<void> load() async {
    emit(OrdersTodayLoading(segment: state.segment));
    await _fetch();
  }

  /// Fetch again without leaving the list. Used by pull-to-refresh, the
  /// Try again button and the network coming back, where blanking the screen
  /// to a skeleton would take the driver's stops away mid-glance.
  Future<void> refresh() async {
    if (state is! OrdersTodayLoaded) return load();
    await _fetch();
  }

  Future<void> _fetch() async {
    _retryTimer?.cancel();
    final generation = ++_generation;
    bool superseded() => isClosed || generation != _generation;

    try {
      final snapshot = await _getOrdersTodayUseCase();
      if (superseded()) return;
      emit(_loadedFrom(snapshot));
    } catch (error) {
      if (superseded()) return;
      final current = state;
      // A failed refresh keeps what is already on screen, marked stale.
      if (current is OrdersTodayLoaded) {
        if (error is NetworkFailure) {
          final reason = await _networkInfo.isConnected
              ? OfflineReason.weakSignal
              : OfflineReason.noConnection;
          if (superseded()) return;
          emit(current.copyWith(offline: () => reason));
        }
        _scheduleWeakSignalRetry();
        return;
      }
      emit(
        OrdersTodayError(
          error is NetworkFailure ? error.message : 'errOrdersLoadFailed',
          segment: state.segment,
        ),
      );
      return;
    }
    _scheduleWeakSignalRetry();
  }

  /// On a weak signal, try again later by itself; on any other state, stop.
  /// No connection at all needs no timer — [_onNetworkChanged] hears when a
  /// link returns.
  void _scheduleWeakSignalRetry() {
    _retryTimer?.cancel();
    final current = state;
    if (current is OrdersTodayLoaded &&
        current.offline == OfflineReason.weakSignal) {
      _retryTimer = Timer(weakSignalRetryInterval, refresh);
    }
  }

  OrdersTodayLoaded _loadedFrom(OrdersTodaySnapshot snapshot) {
    final previous = state;
    return OrdersTodayLoaded(
      data: snapshot.data,
      updatedAt: snapshot.updatedAt,
      segment: state.segment,
      acknowledgedNoticeIds: Set.unmodifiable(_acknowledgedNoticeIds),
      offline: snapshot.offlineReason,
      arrival: previous is OrdersTodayLoaded && !snapshot.isFromCache
          ? _arrivalBetween(previous.data, snapshot.data) ?? previous.arrival
          : null,
    );
  }

  int _arrivalId = 0;

  /// New orders that are in [next] but were not in [previous], counted per
  /// day by each day's new-orders figure. Null when nothing came in.
  ///
  /// Only ever compares two live fetches: the first load has nothing to
  /// compare against — its "N new" pills say it instead — and a saved copy
  /// is by definition nothing new.
  OrdersArrival? _arrivalBetween(
    OrdersTodayEntity previous,
    OrdersTodayEntity next,
  ) {
    final before = {
      for (final day in previous.upcomingDays) day.id: day.newOrdersCount,
    };

    var count = 0;
    final days = <UpcomingDayEntity>[];
    for (final day in next.upcomingDays) {
      final added = day.newOrdersCount - (before[day.id] ?? 0);
      if (added > 0) {
        count += added;
        days.add(day);
      }
    }

    if (count == 0) return null;
    return OrdersArrival(
      id: ++_arrivalId,
      count: count,
      dayName: days.length == 1 ? days.single.nameInSentence : null,
    );
  }

  void _onNetworkChanged(bool connected) {
    if (isClosed) return;
    final current = state;

    if (!connected) {
      // The list stays; it just stops being live. A total loss outranks a
      // weak signal, so it replaces one.
      _retryTimer?.cancel();
      if (current is OrdersTodayLoaded && !current.isDisconnected) {
        emit(current.copyWith(offline: () => OfflineReason.noConnection));
      }
      return;
    }

    // Back online: replace the saved copy, or retry a load that never had
    // anything to fall back on.
    if (current is OrdersTodayLoaded && current.isOffline) {
      refresh();
    } else if (current is OrdersTodayError) {
      load();
    }
  }

  /// The driver tapped OK on a cancellation notice.
  void acknowledgeNotice(String orderId) {
    final current = state;
    if (current is! OrdersTodayLoaded) return;
    if (!_acknowledgedNoticeIds.add(orderId)) return;
    emit(
      current.copyWith(
        acknowledgedNoticeIds: Set.unmodifiable(_acknowledgedNoticeIds),
      ),
    );
  }

  void changeSegment(OrdersTodaySegment segment) {
    if (segment == state.segment) return;
    final current = state;
    if (current is OrdersTodayLoaded) {
      emit(current.copyWith(segment: segment));
    } else if (current is OrdersTodayLoading) {
      emit(OrdersTodayLoading(segment: segment));
    } else if (current is OrdersTodayError) {
      emit(OrdersTodayError(current.messageKey, segment: segment));
    } else {
      emit(OrdersTodayInitial(segment: segment));
    }
  }

  @override
  Future<void> close() async {
    _retryTimer?.cancel();
    await _networkSubscription.cancel();
    return super.close();
  }
}
