// lib/features/orders/presentation/controllers/order_offer_cubit.dart
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';

import '../../domain/entities/order_offer_entity.dart';
import '../../domain/entities/order_offer_failures.dart';
import '../../domain/usecases/order_offer_usecases.dart';

enum OrderOfferStatus {
  /// Waiting for an answer; the timer runs.
  open,
  accepting,
  declining,

  /// Terminal states — the timer stops.
  accepted,
  declined,
  expired,
  takenBack,
}

/// Why the last answer did not go through. The offer stays open.
enum OrderOfferError { none, acceptOffline, declineOffline, failed }

class OrderOfferState extends Equatable {
  const OrderOfferState({
    required this.offer,
    required this.remaining,
    this.status = OrderOfferStatus.open,
    this.skipped = const {},
    this.error = OrderOfferError.none,
    this.result,
  });

  final OrderOfferEntity offer;

  /// Time left to answer; zero once expired.
  final Duration remaining;

  final OrderOfferStatus status;

  /// Ids of orders the driver left out of a group.
  final Set<String> skipped;

  final OrderOfferError error;

  /// Set once accepted.
  final AcceptedOfferEntity? result;

  bool get isBusy =>
      status == OrderOfferStatus.accepting ||
      status == OrderOfferStatus.declining;

  /// Still answerable: open, or sending an answer.
  bool get isLive => status == OrderOfferStatus.open || isBusy;

  List<OfferOrderEntity> get acceptedOrders =>
      offer.orders.where((o) => !skipped.contains(o.id)).toList();

  OrderOfferState copyWith({
    Duration? remaining,
    OrderOfferStatus? status,
    Set<String>? skipped,
    OrderOfferError? error,
    AcceptedOfferEntity? result,
  }) =>
      OrderOfferState(
        offer: offer,
        remaining: remaining ?? this.remaining,
        status: status ?? this.status,
        skipped: skipped ?? this.skipped,
        error: error ?? this.error,
        result: result ?? this.result,
      );

  @override
  List<Object?> get props =>
      [offer, remaining, status, skipped, error, result];
}

class OrderOfferCubit extends Cubit<OrderOfferState> {
  OrderOfferCubit({
    required OrderOfferEntity offer,
    required AcceptOfferUseCase acceptOfferUseCase,
    required DeclineOfferUseCase declineOfferUseCase,
    DateTime Function()? clock,
    this.tick = const Duration(seconds: 1),
  })  : _accept = acceptOfferUseCase,
        _decline = declineOfferUseCase,
        _now = clock ?? DateTime.now,
        super(OrderOfferState(offer: offer, remaining: Duration.zero)) {
    _deadline = offer.expiresAt ??
        _now().add(_parseClock(offer.deadlineLabel) ?? offer.answerWindow);
    _update();
    if (state.status == OrderOfferStatus.open) {
      _timer = Timer.periodic(tick, (_) => _update());
    }
  }

  final AcceptOfferUseCase _accept;
  final DeclineOfferUseCase _decline;
  final DateTime Function() _now;
  final Duration tick;

  late final DateTime _deadline;
  Timer? _timer;

  /// The reason given with the last decline, for Try again.
  OfferDeclineReason? _lastReason;

  /// `09:42` → 9 min 42 s; null when the label is not a clock.
  static Duration? _parseClock(String label) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(label.trim());
    if (match == null) return null;
    return Duration(
      minutes: int.parse(match.group(1)!),
      seconds: int.parse(match.group(2)!),
    );
  }

  void _update() {
    if (isClosed) return;
    final left = _deadline.difference(_now());
    if (left <= Duration.zero) {
      _timer?.cancel();
      // An answer already on its way decides it; otherwise time is up.
      if (state.status == OrderOfferStatus.open) {
        emit(state.copyWith(
          remaining: Duration.zero,
          status: OrderOfferStatus.expired,
          error: OrderOfferError.none,
        ));
      } else {
        emit(state.copyWith(remaining: Duration.zero));
      }
      return;
    }
    emit(state.copyWith(remaining: left));
  }

  /// Leaves an order of a group out, or takes it back in.
  void toggleSkip(String orderId) {
    if (state.status != OrderOfferStatus.open || !state.offer.isGroup) return;
    final skipped = {...state.skipped};
    if (!skipped.remove(orderId)) skipped.add(orderId);
    emit(state.copyWith(skipped: skipped));
  }

  Future<void> accept() async {
    if (state.status != OrderOfferStatus.open) return;
    final ids = state.acceptedOrders.map((o) => o.id).toList();
    if (ids.isEmpty) return;
    emit(state.copyWith(
      status: OrderOfferStatus.accepting,
      error: OrderOfferError.none,
    ));
    try {
      final result = await _accept(state.offer.id, ids);
      if (isClosed) return;
      _timer?.cancel();
      emit(state.copyWith(status: OrderOfferStatus.accepted, result: result));
    } catch (error) {
      if (isClosed) return;
      _failed(error, OrderOfferError.acceptOffline);
    }
  }

  /// [reason] is null for "Decline all", where none is asked.
  Future<void> decline(OfferDeclineReason? reason) async {
    if (state.status != OrderOfferStatus.open) return;
    _lastReason = reason;
    emit(state.copyWith(
      status: OrderOfferStatus.declining,
      error: OrderOfferError.none,
    ));
    try {
      await _decline(state.offer.id, reason);
      if (isClosed) return;
      _timer?.cancel();
      emit(state.copyWith(status: OrderOfferStatus.declined));
    } catch (error) {
      if (isClosed) return;
      _failed(error, OrderOfferError.declineOffline);
    }
  }

  /// Sends the answer that did not go through again.
  Future<void> retry() => state.error == OrderOfferError.declineOffline
      ? decline(_lastReason)
      : accept();

  void _failed(Object error, OrderOfferError offline) {
    switch (error) {
      case OfferTakenBackFailure():
        _timer?.cancel();
        emit(state.copyWith(status: OrderOfferStatus.takenBack));
      case OfferExpiredFailure():
        _timer?.cancel();
        emit(state.copyWith(
          status: OrderOfferStatus.expired,
          remaining: Duration.zero,
        ));
      default:
        // Still answerable while the timer runs — unless it ran out while
        // the answer was failing.
        final expired = state.remaining <= Duration.zero;
        emit(state.copyWith(
          status: expired ? OrderOfferStatus.expired : OrderOfferStatus.open,
          error: expired
              ? OrderOfferError.none
              : error is NetworkFailure
                  ? offline
                  : OrderOfferError.failed,
        ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
