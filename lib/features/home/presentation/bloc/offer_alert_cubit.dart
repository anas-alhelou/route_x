// lib/features/home/presentation/bloc/offer_alert_cubit.dart
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/notifications/app_shell_bus.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';
import 'package:routex_mobile/features/orders/domain/usecases/order_offer_usecases.dart';

class OfferAlertState extends Equatable {
  const OfferAlertState({
    this.offers = const [],
    this.overlayVisible = false,
  });

  /// Offers waiting for an answer, soonest first.
  final List<OrderOfferEntity> offers;

  /// The single-order card (Figma HM8 / HM9) stays up for a few seconds after
  /// an order arrives, then gives way to the "needs your attention" row.
  final bool overlayVisible;

  bool get hasOffers => offers.isNotEmpty;

  int get orderCount =>
      offers.fold(0, (sum, offer) => sum + offer.orders.length);

  /// One order waiting: HM8 / HM9. More than one: the NF3 banner.
  bool get isSingle => orderCount == 1;

  OrderOfferEntity? get first => offers.isEmpty ? null : offers.first;

  /// When the soonest offer runs out; null when none has a deadline.
  DateTime? get firstDeadline {
    DateTime? soonest;
    for (final offer in offers) {
      final at = offer.expiresAt;
      if (at != null && (soonest == null || at.isBefore(soonest))) soonest = at;
    }
    return soonest;
  }

  OfferAlertState copyWith({
    List<OrderOfferEntity>? offers,
    bool? overlayVisible,
  }) =>
      OfferAlertState(
        offers: offers ?? this.offers,
        overlayVisible: overlayVisible ?? this.overlayVisible,
      );

  @override
  List<Object?> get props => [offers, overlayVisible];
}

/// The offers Home tells the driver about: the in-app card when one order
/// arrives (HM8 / HM9) and the "N new orders" banner (NF3).
class OfferAlertCubit extends Cubit<OfferAlertState> {
  OfferAlertCubit({
    required GetPendingOffersUseCase getPendingOffers,
    this.overlayFor = const Duration(seconds: 5),
  })  : _getPending = getPendingOffers,
        super(const OfferAlertState()) {
    // Answering an offer anywhere (Orders tab, a notification) refreshes this.
    AppShellBus.instance.offersRevision.addListener(load);
  }

  final GetPendingOffersUseCase _getPending;

  /// How long the single-order card stays on screen (Figma: 5 s).
  final Duration overlayFor;

  final Set<String> _announced = <String>{};
  Timer? _overlayTimer;

  Future<void> load() async {
    try {
      final all = await _getPending();
      if (isClosed) return;
      final now = DateTime.now();
      final live = all.where((offer) {
        final at = offer.expiresAt;
        return at == null || at.isAfter(now);
      }).toList()
        ..sort((a, b) {
          final x = a.expiresAt;
          final y = b.expiresAt;
          if (x == null || y == null) return 0;
          return x.compareTo(y);
        });

      var arrived = false;
      for (final offer in live) {
        if (_announced.add(offer.id)) arrived = true;
      }

      final next = OfferAlertState(offers: live);
      final show = live.isNotEmpty &&
          (arrived && next.isSingle || state.overlayVisible && next.isSingle);
      emit(next.copyWith(overlayVisible: show));
      if (arrived && next.isSingle) {
        _overlayTimer?.cancel();
        _overlayTimer = Timer(overlayFor, dismissOverlay);
      }
    } catch (_) {
      // No signal: keep what is on screen; the next load catches up.
    }
  }

  void dismissOverlay() {
    _overlayTimer?.cancel();
    if (isClosed || !state.overlayVisible) return;
    emit(state.copyWith(overlayVisible: false));
  }

  @override
  Future<void> close() {
    AppShellBus.instance.offersRevision.removeListener(load);
    _overlayTimer?.cancel();
    return super.close();
  }
}
