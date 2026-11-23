import '../../domain/entities/order_detail_entity.dart';
import '../models/driver_order_dto.dart';
import '../models/order_detail_model.dart';
import 'driver_orders_remote_data_source.dart';
import 'order_detail_local_data_source.dart';

/// Order detail built from `GET /orders/mine` (there is no `GET /orders/{id}`
/// for drivers). Throws a [StateError] when the order is not in the list.
// TODO(backend): door details, gate code, ETA / on-time flag, scanned count,
// dispatch note and delivery requirements are not in the order payload.
class OrderDetailApiDataSource implements OrderDetailLocalDataSource {
  OrderDetailApiDataSource(this._orders);

  final DriverOrdersRemoteDataSource _orders;

  @override
  Future<OrderDetailModel> getOrderDetail(String orderId) async {
    final all = await _orders.getMine();
    final open = all.where((o) => o.isOpenStop).length;
    DriverOrderDto? order;
    for (final o in all) {
      if (o.id == orderId) order = o;
    }
    if (order == null) throw StateError('Unknown order $orderId');

    return OrderDetailModel(
      id: order.id,
      orderCode: order.code,
      totalStops: open,
      customerPhone: order.customerPhone ?? '',
      addressLine: order.address,
      addressDetails: '',
      gateCode: null,
      eta: '',
      isOnTime: true,
      packagesCount: order.packagesCount,
      scannedCount: 0,
      // Delivery is confirmed with a photo (POST /orders/deliver).
      requirements: const [DeliveryRequirement.photo],
      dispatchNote: null,
      latitude: order.latitude ?? 0,
      longitude: order.longitude ?? 0,
    );
  }
}
