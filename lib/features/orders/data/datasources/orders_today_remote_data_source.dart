import '../../domain/entities/orders_today_entity.dart';
import '../models/driver_order_dto.dart';
import '../models/orders_today_model.dart';
import 'driver_orders_remote_data_source.dart';
import 'orders_today_local_data_source.dart';

/// Builds the "Orders today" screen from `GET /orders/mine`.
///
/// What the backend does not send yet is left empty and marked TODO:
/// time windows, the estimated finish time, upcoming days and the count of
/// orders already delivered today (the endpoint lists only open orders).
class OrdersTodayRemoteDataSource implements OrdersTodayLocalDataSource {
  OrdersTodayRemoteDataSource(this._orders);

  final DriverOrdersRemoteDataSource _orders;

  @override
  Future<OrdersTodayModel> getOrdersToday() async {
    final all = await _orders.getMine();
    final stops = all.where((o) => o.isOpenStop).toList();
    final offers = all.where((o) => o.isOffer).length;

    var seq = 0;
    final todayStops = [
      for (final o in stops)
        TodayStopModel(
          id: o.id,
          sequence: ++seq, // TODO(backend): real stop order
          customerName: o.customerName,
          area: _area(o),
          timeWindow: '', // TODO(backend): delivery time window
          status: o.status == 'IN_TRANSIT'
              ? TodayStopStatus.onTheWay
              : TodayStopStatus.upNext,
        ),
    ];

    return OrdersTodayModel(
      newOrdersCount: offers,
      todayStops: todayStops,
      remainingCount: todayStops.length,
      estimatedFinishTime: '', // TODO(backend): ETA of the last stop
      deliveredTodayCount: 0, // TODO(backend): delivered orders of today
      upcomingDays: const <UpcomingDayEntity>[],
    );
  }

  static String _area(DriverOrderDto o) =>
      (o.region != null && o.region!.isNotEmpty) ? o.region! : o.address;
}
