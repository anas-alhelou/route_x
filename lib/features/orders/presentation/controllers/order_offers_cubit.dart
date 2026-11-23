// lib/features/orders/presentation/controllers/order_offers_cubit.dart
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_offer_entity.dart';
import '../../domain/usecases/order_offer_usecases.dart';

class OrderOffersState extends Equatable {
  const OrderOffersState({
    this.offers = const [],
    this.declined,
    this.declinedId = 0,
    this.undoing = false,
  });

  /// Waiting for an answer, soonest to expire first.
  final List<OrderOfferEntity> offers;

  /// Just declined — shown in a toast with Undo until it times out.
  final OrderOfferEntity? declined;

  /// Bumped on every decline, so declining twice in a row still shows the
  /// toast again.
  final int declinedId;

  final bool undoing;

  int get waitingOrders =>
      offers.fold(0, (sum, offer) => sum + offer.orders.length);

  /// When the soonest offer runs out; null when none has a deadline.
  DateTime? get firstDeadline {
    DateTime? first;
    for (final offer in offers) {
      final at = offer.expiresAt;
      if (at != null && (first == null || at.isBefore(first))) first = at;
    }
    return first;
  }

  OrderOffersState copyWith({
    List<OrderOfferEntity>? offers,
    OrderOfferEntity? Function()? declined,
    int? declinedId,
    bool? undoing,
  }) =>
      OrderOffersState(
        offers: offers ?? this.offers,
        declined: declined != null ? declined() : this.declined,
        declinedId: declinedId ?? this.declinedId,
        undoing: undoing ?? this.undoing,
      );

  @override
  List<Object?> get props => [offers, declined, declinedId, undoing];
}

/// The offers waiting on the Orders tab, and the toast after one is
/// declined.
class OrderOffersCubit extends Cubit<OrderOffersState> {
  OrderOffersCubit({
    required GetPendingOffersUseCase getPendingOffersUseCase,
    required UndoDeclineOfferUseCase undoDeclineOfferUseCase,
    this.toastFor = const Duration(seconds: 5),
  })  : _getPending = getPendingOffersUseCase,
        _undoDecline = undoDeclineOfferUseCase,
        super(const OrderOffersState());

  final GetPendingOffersUseCase _getPending;
  final UndoDeclineOfferUseCase _undoDecline;

  /// How long Undo stays on screen.
  final Duration toastFor;
  Timer? _toastTimer;

  Future<void> load() async {
    try {
      final offers = await _getPending();
      if (isClosed) return;
      emit(state.copyWith(offers: offers));
    } catch (_) {
      // No signal: keep what is on screen; the next load will catch up.
    }
  }

  /// An offer screen came back declined: drop it and offer Undo.
  void offerDeclined(OrderOfferEntity offer) {
    _toastTimer?.cancel();
    emit(state.copyWith(
      offers: state.offers.where((o) => o.id != offer.id).toList(),
      declined: () => offer,
      declinedId: state.declinedId + 1,
    ));
    _toastTimer = Timer(toastFor, dismissToast);
  }

  /// An offer screen came back accepted, or the offer ran out.
  void offerAnswered(OrderOfferEntity offer) {
    emit(state.copyWith(
      offers: state.offers.where((o) => o.id != offer.id).toList(),
    ));
  }

  Future<void> undo() async {
    final offer = state.declined;
    if (offer == null || state.undoing) return;
    _toastTimer?.cancel();
    emit(state.copyWith(undoing: true));
    try {
      await _undoDecline(offer.id);
    } catch (_) {
      // Too late or no signal — the decline stands.
    }
    if (isClosed) return;
    emit(state.copyWith(declined: () => null, undoing: false));
    await load();
  }

  void dismissToast() {
    _toastTimer?.cancel();
    if (isClosed || state.declined == null) return;
    emit(state.copyWith(declined: () => null));
  }

  @override
  Future<void> close() {
    _toastTimer?.cancel();
    return super.close();
  }
}
