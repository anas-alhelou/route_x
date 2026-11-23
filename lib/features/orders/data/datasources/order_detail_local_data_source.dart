// lib/features/orders/data/datasources/order_detail_local_data_source.dart
import '../../domain/entities/order_detail_entity.dart';
import '../models/order_detail_model.dart';

abstract class OrderDetailLocalDataSource {
  /// Throws a [StateError] when [orderId] is unknown.
  Future<OrderDetailModel> getOrderDetail(String orderId);
}

/// Stand-in for `GET /orders/{id}` until dispatch ships it. Keyed by the
/// same ids [OrdersTodayLocalDataSourceImpl] hands out, so every row on the
/// Today list opens a real detail screen.
class OrderDetailLocalDataSourceImpl implements OrderDetailLocalDataSource {
  const OrderDetailLocalDataSourceImpl();

  static const Map<String, OrderDetailModel> _mock = {
    'ORD-10031': OrderDetailModel(
      id: 'ORD-10031',
      orderCode: 'RX-1040',
      totalStops: 5,
      customerPhone: '+966501112233',
      addressLine: 'Tahlia St 14, Al Nahda',
      addressDetails: 'Villa 7, blue gate',
      gateCode: '2290',
      // Six minutes out at 9:30. The design's 12:25 would fall after the
      // 10:00 — 12:00 window, which this app reports as late, not on time.
      eta: '9:36',
      isOnTime: true,
      packagesCount: 1,
      scannedCount: 1,
      requirements: [DeliveryRequirement.photo],
      dispatchNote: 'Fragile: glass items. '
          'Please don’t leave it at the gate.',
      latitude: 24.7652,
      longitude: 46.6611,
      minutesAway: 6,
    ),
    'ORD-10032': OrderDetailModel(
      id: 'ORD-10032',
      orderCode: 'RX-1041',
      totalStops: 5,
      customerPhone: '+966502223344',
      addressLine: 'Prince Sultan St 22, Al Rawdah',
      addressDetails: 'Building 7, 3rd floor, flat 12',
      gateCode: '4471',
      eta: '12:25',
      isOnTime: true,
      packagesCount: 2,
      scannedCount: 0,
      requirements: [DeliveryRequirement.signature, DeliveryRequirement.photo],
      dispatchNote: 'Customer asked you to call when you arrive. '
          'The guard can take it if nobody answers.',
      latitude: 24.7311,
      longitude: 46.7663,
    ),
    'ORD-10033': OrderDetailModel(
      id: 'ORD-10033',
      orderCode: 'RX-1043',
      totalStops: 5,
      customerPhone: '+966503334455',
      addressLine: 'Al Salamah St 14, Al Salamah',
      addressDetails: '',
      gateCode: null,
      eta: '14:20',
      isOnTime: false,
      packagesCount: 3,
      scannedCount: 0,
      requirements: [DeliveryRequirement.photo],
      dispatchNote: 'Leave with the reception desk.',
      latitude: 21.5806,
      longitude: 39.1528,
    ),
  };

  @override
  Future<OrderDetailModel> getOrderDetail(String orderId) async {
    final detail = _mock[orderId];
    if (detail == null) throw StateError('Unknown order $orderId');
    return detail;
  }
}
