import '../../domain/entities/order_search_result_entity.dart';
import '../../domain/entities/orders_today_entity.dart';
import '../models/driver_order_dto.dart';
import '../models/orders_today_model.dart';
import 'driver_orders_remote_data_source.dart';
import 'order_search_local_data_source.dart';

/// Search over the driver's own orders (`GET /orders/mine`), filtered on the
/// device: there is no search endpoint.
///
/// "Today" = orders assigned to the driver; "Upcoming" = offered orders still
/// waiting for an answer (the backend has no dates yet).
// TODO(backend): a search endpoint and per-day scheduling.
class OrderSearchApiDataSource implements OrderSearchLocalDataSource {
  OrderSearchApiDataSource(this._orders);

  final DriverOrdersRemoteDataSource _orders;

  @override
  Future<List<OrderSearchResultEntity>> search(
    String query,
    OrderSearchScope scope,
  ) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final all = await _orders.getMine();
    final open = all.where((o) => o.isOpenStop).toList();
    final offers = all.where((o) => o.isOffer).toList();

    final results = <OrderSearchResultEntity>[];

    if (scope != OrderSearchScope.upcoming) {
      var seq = 0;
      for (final o in open) {
        seq++;
        if (!_matches(o, q)) continue;
        results.add(
          OrderSearchResultEntity(
            id: o.id,
            customerName: o.customerName,
            orderCode: o.code,
            areaLabel: o.address,
            todayStop: TodayStopModel(
              id: o.id,
              sequence: seq,
              customerName: o.customerName,
              area: _area(o),
              timeWindow: '',
              status: o.status == 'IN_TRANSIT'
                  ? TodayStopStatus.onTheWay
                  : TodayStopStatus.upNext,
            ),
          ),
        );
      }
    }

    if (scope != OrderSearchScope.today) {
      for (final o in offers) {
        if (!_matches(o, q)) continue;
        results.add(
          OrderSearchResultEntity(
            id: o.id,
            customerName: o.customerName,
            orderCode: o.code,
            areaLabel: _area(o),
            isNew: true,
          ),
        );
      }
    }
    return results;
  }

  static String _area(DriverOrderDto o) =>
      (o.region != null && o.region!.isNotEmpty) ? o.region! : o.address;

  static bool _matches(DriverOrderDto o, String q) {
    bool has(String? v) => v != null && v.toLowerCase().contains(q);
    return has(o.customerName) ||
        has(o.code) ||
        has(o.address) ||
        has(o.region) ||
        has(o.customerPhone);
  }
}
