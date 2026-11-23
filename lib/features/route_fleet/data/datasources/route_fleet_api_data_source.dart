import 'package:routex_mobile/features/orders/data/datasources/driver_orders_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/models/driver_order_dto.dart';

import '../../domain/entities/location_report.dart';
import '../models/fleet_info_model.dart';
import '../models/route_stop_model.dart';
import 'route_fleet_local_data_source.dart';

/// The active route, built from `GET /orders/mine`.
///
/// The backend has no route object yet, so the route is "the driver's open
/// orders" (ASSIGNED / IN_TRANSIT). Fields it does not send are left empty:
// TODO(backend): route id / name, vehicle, distance, stop order, ETAs, depot,
// time windows, gate code, company note, package type, door number.
class RouteFleetApiDataSource implements RouteFleetLocalDataSource {
  RouteFleetApiDataSource(this._orders);

  final DriverOrdersRemoteDataSource _orders;

  /// Stop order chosen on the device (the backend does not order stops).
  final List<String> _order = [];
  final Set<String> _done = {};

  @override
  Future<FleetInfoModel> getActiveRoute() async {
    final all = await _orders.getMine();
    final open = all.where((o) => o.isOpenStop).toList();
    return _build(open);
  }

  @override
  Future<FleetInfoModel> updateStopStatus(String stopId, bool isCompleted) async {
    if (isCompleted) {
      _done.add(stopId);
    } else {
      _done.remove(stopId);
    }
    return getActiveRoute();
  }

  @override
  Future<FleetInfoModel> reorderStopToLast(int stopIndex) async {
    final fleet = await getActiveRoute();
    if (stopIndex < 0 || stopIndex >= fleet.stops.length) return fleet;
    final ids = fleet.stops.map((s) => s.id).toList();
    final moved = ids.removeAt(stopIndex);
    ids.add(moved);
    _order
      ..clear()
      ..addAll(ids);
    return getActiveRoute();
  }

  @override
  Future<void> reportWrongLocation(LocationReport report) async {
    // TODO(backend): no endpoint for "wrong location" yet.
  }

  FleetInfoModel _build(List<DriverOrderDto> open) {
    final sorted = [...open];
    if (_order.isNotEmpty) {
      int rank(DriverOrderDto o) {
        final i = _order.indexOf(o.id);
        return i < 0 ? _order.length : i;
      }

      sorted.sort((a, b) => rank(a).compareTo(rank(b)));
    }
    final stops = [for (final o in sorted) _stop(o)];
    final doneCount = stops.where((s) => s.isCompleted).length;
    return FleetInfoModel(
      routeId: 'today',
      routeName: '', // TODO(backend)
      activeVehicleNumber: '', // TODO(backend)
      totalDistance: '', // TODO(backend)
      progressPercentage: stops.isEmpty ? 0 : doneCount / stops.length,
      depotInfo: const DepotInfoModel(
        name: '',
        address: '',
        distanceText: '',
        etaText: '',
      ), // TODO(backend)
      stops: stops,
    );
  }

  RouteStopModel _stop(DriverOrderDto o) {
    final done = _done.contains(o.id);
    final count = o.packagesCount;
    return RouteStopModel(
      id: o.id,
      title: o.customerName,
      address: o.address,
      eta: '', // TODO(backend)
      isCompleted: done,
      status: done ? 'Delivered' : 'Pending',
      phone: o.customerPhone,
      packagesText: count > 0 ? '$count · drop-off' : null,
      orderId: '#${o.code}',
      latitude: o.latitude,
      longitude: o.longitude,
    );
  }
}
