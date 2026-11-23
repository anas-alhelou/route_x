// lib/features/orders/domain/entities/order_offer_entity.dart
import 'package:equatable/equatable.dart';

/// The state of a single order inside an offer the driver can accept.
enum OfferOrderStatus { accepting, skipping, offered }

/// A single order offered to the driver as part of a dispatch offer.
class OfferOrderEntity extends Equatable {
  const OfferOrderEntity({
    required this.id,
    required this.customerName,
    required this.orderCode,
    required this.area,
    required this.timeWindow,
    required this.distanceKm,
    required this.packagesCount,
    this.status = OfferOrderStatus.offered,
    this.addressDetails,
    this.instructions,
    this.deliveryDateLabel,
    this.routePosition,
    this.addedMinutes,
    this.addressLine,
  });

  final String id;
  final String customerName;

  /// Printed reference without the `#`, e.g. `RX-1052`.
  final String orderCode;

  /// Street/district plus the window, e.g. `Al Rawdah · 09:00 — 11:00`.
  final String area;
  final String timeWindow;

  /// Extra distance this order adds to the driver's route, e.g. `+2.4 km`.
  final String distanceKm;

  final int packagesCount;

  /// Whether this order is still accepting, being skipped (grayed out), or
  /// offered (the default).
  final OfferOrderStatus status;

  /// `Building 7, 3rd floor, flat 12`; null when there is none.
  final String? addressDetails;

  /// What the stop needs at the door, e.g. `Signature needed at the door`.
  final String? instructions;

  /// `Tomorrow, Mon 12 Oct`.
  final String? deliveryDateLabel;

  /// The stop on the route this order would follow.
  final int? routePosition;

  /// The full street address, `Prince Sultan St 22, Al Rawdah`; [area] is
  /// the district alone. Null falls back to [area].
  final String? addressLine;

  /// Driving time this order alone adds to the route; null when unknown.
  final int? addedMinutes;

  /// The number in [distanceKm] (`+2.4 km` → 2.4), for adding orders up.
  double get addedKm =>
      double.tryParse(distanceKm.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  bool get isSkipping => status == OfferOrderStatus.skipping;

  OfferOrderEntity copyWith({OfferOrderStatus? status}) {
    return OfferOrderEntity(
      id: id,
      customerName: customerName,
      orderCode: orderCode,
      area: area,
      timeWindow: timeWindow,
      distanceKm: distanceKm,
      packagesCount: packagesCount,
      status: status ?? this.status,
      addressDetails: addressDetails,
      instructions: instructions,
      deliveryDateLabel: deliveryDateLabel,
      routePosition: routePosition,
      addedMinutes: addedMinutes,
      addressLine: addressLine,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        orderCode,
        area,
        timeWindow,
        distanceKm,
        packagesCount,
        status,
        addressDetails,
        instructions,
        deliveryDateLabel,
        routePosition,
        addedMinutes,
        addressLine,
      ];
}

/// A group offer: one or more orders offered together.
class OrderOfferEntity extends Equatable {
  const OrderOfferEntity({
    required this.id,
    required this.fleetName,
    required this.deadlineLabel,
    required this.stopsCount,
    required this.distanceLabel,
    required this.timeLabel,
    required this.orders,
    this.note,
    this.expiresAt,
    this.answerWindow = const Duration(minutes: 10),
  });

  final String id;

  /// Fleet that is offering these orders, e.g. `Red Sea Express`.
  final String fleetName;

  /// Countdown text shown in the pill, e.g. `09:42 left`.
  final String deadlineLabel;

  /// Number of stops the accepted orders add, e.g. `3`.
  final int stopsCount;

  /// Extra distance for accepted orders, e.g. `+6.8 km`.
  final String distanceLabel;

  /// Extra driving time for accepted orders, e.g. `+36 min`.
  final String timeLabel;

  final List<OfferOrderEntity> orders;

  /// Optional extra copy shown above the offer list, e.g.
  /// `For tomorrow, Mon 12 Oct. Pick the ones you can take.`
  final String? note;

  /// When the offer goes back to the fleet. Null on previews built from a
  /// fixed [deadlineLabel]; the screen then counts down from that label.
  final DateTime? expiresAt;

  /// How long the driver had to answer — "you didn't answer in 10 minutes".
  final Duration answerWindow;

  bool get isGroup => orders.length > 1;

  int get acceptedCount => orders.where((o) => !o.isSkipping).length;
  int get skippedCount => orders.length - acceptedCount;

  /// The "Accept all 3" / "Accept 2, skip 1" label changes with selection.
  String get acceptLabelKey => skippedCount == 0
      ? 'orderOfferAcceptAll'
      : 'orderOfferAcceptSkip';

  @override
  List<Object?> get props => [
        id,
        fleetName,
        deadlineLabel,
        stopsCount,
        distanceLabel,
        timeLabel,
        orders,
        note,
        expiresAt,
        answerWindow,
      ];
}
/// Why a driver turned an offer down. The fleet sees it, so it can stop
/// offering what will never be taken.
enum OfferDeclineReason { vanFull, outsideArea, shiftEnds, other }

/// The route once an offer is taken — what the "Added to your route" screen
/// reports back.
class AcceptedOfferEntity extends Equatable {
  const AcceptedOfferEntity({
    required this.acceptedCount,
    required this.firstStopNumber,
    required this.totalStops,
    required this.distanceKm,
    required this.doneBy,
    this.customerName,
  });

  final int acceptedCount;

  /// Where the (first) new order landed on the route.
  final int firstStopNumber;
  final int totalStops;
  final double distanceKm;

  /// `13:10`.
  final String doneBy;

  /// Set when one order was accepted: "Ahmed Ali is now stop 4 of 5".
  final String? customerName;

  @override
  List<Object?> get props => [
        acceptedCount,
        firstStopNumber,
        totalStops,
        distanceKm,
        doneBy,
        customerName,
      ];
}
