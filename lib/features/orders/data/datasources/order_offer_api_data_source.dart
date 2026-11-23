import 'package:dio/dio.dart';

import '../../domain/entities/order_offer_entity.dart';
import '../../domain/entities/order_offer_failures.dart';
import '../models/driver_order_dto.dart';
import 'driver_orders_remote_data_source.dart';
import 'order_offer_remote_data_source.dart';

/// Offers from the real backend.
///
/// The backend has no "offer group": every PENDING order of
/// `GET /orders/mine` is an offer of one order, and its id is the order id.
/// Declining is `PATCH /orders/reject`; the backend has no way to undo it.
// TODO(backend): offer deadline, grouping, distance / time added to the route.
class OrderOfferApiDataSource implements OrderOfferRemoteDataSource {
  OrderOfferApiDataSource(this._orders);

  final DriverOrdersRemoteDataSource _orders;

  @override
  Future<List<OrderOfferEntity>> getPendingOffers() async {
    final all = await _orders.getMine();
    return [
      for (final o in all.where((o) => o.isOffer))
        OrderOfferEntity(
          id: o.id,
          fleetName: '', // TODO(backend): company name on the order
          deadlineLabel: '',
          stopsCount: 1,
          distanceLabel: '',
          timeLabel: '',
          orders: [_toOfferOrder(o)],
        ),
    ];
  }

  @override
  Future<AcceptedOfferEntity> accept(
    String offerId,
    List<String> orderIds,
  ) async {
    final ids = orderIds.isEmpty ? [offerId] : orderIds;
    String? firstName;
    try {
      for (final id in ids) {
        await _orders.accept(id);
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      // TODO(backend): confirm the codes for "taken back" and "expired".
      if (code == 404 || code == 409) throw const OfferTakenBackFailure();
      if (code == 410) throw const OfferExpiredFailure();
      rethrow;
    }

    final mine = await _orders.getMine();
    final open = mine.where((o) => o.isOpenStop).toList();
    for (final o in open) {
      if (ids.contains(o.id)) firstName ??= o.customerName;
    }
    final firstIndex = open.indexWhere((o) => ids.contains(o.id));
    return AcceptedOfferEntity(
      acceptedCount: ids.length,
      firstStopNumber: firstIndex < 0 ? open.length : firstIndex + 1,
      totalStops: open.length,
      distanceKm: 0, // TODO(backend)
      doneBy: '', // TODO(backend)
      customerName: ids.length == 1 ? firstName : null,
    );
  }

  @override
  Future<void> decline(String offerId, OfferDeclineReason? reason) =>
      _orders.reject(offerId, _reasonText(reason));

  @override
  Future<void> undoDecline(String offerId) async {
    // The backend cannot take a rejection back.
    throw const OfferExpiredFailure();
  }

  static String _reasonText(OfferDeclineReason? r) => switch (r) {
    OfferDeclineReason.vanFull => 'Vehicle is full',
    OfferDeclineReason.outsideArea => 'Outside my area',
    OfferDeclineReason.shiftEnds => 'My shift ends before then',
    OfferDeclineReason.other => 'Other',
    null => 'Declined by driver',
  };

  static OfferOrderEntity _toOfferOrder(DriverOrderDto o) => OfferOrderEntity(
    id: o.id,
    customerName: o.customerName,
    orderCode: o.code,
    area: (o.region != null && o.region!.isNotEmpty) ? o.region! : o.address,
    addressLine: o.address,
    timeWindow: '', // TODO(backend)
    distanceKm: '', // TODO(backend)
    packagesCount: o.packagesCount,
  );
}
