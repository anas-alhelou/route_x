// lib/features/route_fleet/data/datasources/route_fleet_local_data_source.dart
import '../../domain/entities/location_report.dart';
import '../models/fleet_info_model.dart';
import '../models/route_stop_model.dart';

abstract class RouteFleetLocalDataSource {
  Future<FleetInfoModel> getActiveRoute();
  Future<FleetInfoModel> updateStopStatus(String stopId, bool isCompleted);
  Future<FleetInfoModel> reorderStopToLast(int stopIndex);
  Future<void> reportWrongLocation(LocationReport report);
}

class RouteFleetLocalDataSourceImpl implements RouteFleetLocalDataSource {
  RouteFleetLocalDataSourceImpl();

  FleetInfoModel _cachedFleet = const FleetInfoModel(
    routeId: 'rt-spec-001',
    routeName: 'Route #3',
    activeVehicleNumber: 'RX-VAN-882',
    totalDistance: '6.8 km',
    progressPercentage: 0.0,
    depotInfo: DepotInfoModel(
      name: 'Red Sea Express hub',
      address: 'Al Rawdah',
      distanceText: '3.1 km',
      etaText: 'arrive 11:02',
    ),
    stops: [
      RouteStopModel(
        id: 'stop-1',
        title: 'Omar Haddad',
        address: 'Sari St, Al Zahra',
        eta: '10:05',
        isCompleted: false,
        status: 'Pending',
        // TEMP mock metadata
        phone: '+966501234567',
        gateCode: '4417#',
        timeWindow: '10:00 – 10:30',
        packagesText: '2 · drop-off',
        companyNote: 'Call when you arrive. Building 12, 3rd floor.',
        orderId: '#RX-1039',
        packageType: 'Medium box',
        doorNumber: '12',
      ),
      RouteStopModel(
        id: 'stop-2',
        title: 'Lina Fares',
        address: 'Tahlia St, Al Nahda',
        eta: '10:24',
        isCompleted: false,
        status: 'Pending',
        // TEMP mock metadata
        phone: '+966502345678',
        gateCode: '8821#',
        timeWindow: '10:30 – 11:00',
        packagesText: '1 · drop-off',
        companyNote: 'Leave at reception desk.',
        orderId: '#RX-1040',
        packageType: 'Small envelope',
        doorNumber: '7',
      ),
      RouteStopModel(
        id: 'stop-3',
        title: 'Ahmed Ali',
        address: 'Prince Sultan St, Al Rawdah',
        eta: '10:41',
        isCompleted: false,
        status: 'Pending',
        // TEMP mock metadata
        phone: '+966503456789',
        gateCode: null,
        timeWindow: '11:00 – 11:30',
        packagesText: '1 · pick-up',
        companyNote: null,
        orderId: '#RX-1041',
        packageType: 'Large box',
        doorNumber: '22',
      ),
    ],
  );

  @override
  Future<FleetInfoModel> getActiveRoute() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _cachedFleet;
  }

  @override
  Future<FleetInfoModel> updateStopStatus(String stopId, bool isCompleted) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updatedStops = _cachedFleet.stops.map((stop) {
      if (stop.id == stopId) {
        return RouteStopModel(
          id: stop.id,
          title: stop.title,
          address: stop.address,
          eta: stop.eta,
          isCompleted: isCompleted,
          status: isCompleted ? 'Delivered' : 'Pending',
          phone: stop.phone,
          gateCode: stop.gateCode,
          timeWindow: stop.timeWindow,
          packagesText: stop.packagesText,
          companyNote: stop.companyNote,
          orderId: stop.orderId,
          packageType: stop.packageType,
        );
      }
      return RouteStopModel(
        id: stop.id,
        title: stop.title,
        address: stop.address,
        eta: stop.eta,
        isCompleted: stop.isCompleted,
        status: stop.status,
        phone: stop.phone,
        gateCode: stop.gateCode,
        timeWindow: stop.timeWindow,
        packagesText: stop.packagesText,
        companyNote: stop.companyNote,
        orderId: stop.orderId,
        packageType: stop.packageType,
      );
    }).toList();

    final completedCount = updatedStops.where((s) => s.isCompleted).length;
    final progress = completedCount / updatedStops.length;

    _cachedFleet = FleetInfoModel(
      routeId: _cachedFleet.routeId,
      routeName: _cachedFleet.routeName,
      activeVehicleNumber: _cachedFleet.activeVehicleNumber,
      totalDistance: _cachedFleet.totalDistance,
      progressPercentage: progress,
      depotInfo: _cachedFleet.depotInfo,
      stops: updatedStops,
    );

    return _cachedFleet;
  }

  @override
  Future<FleetInfoModel> reorderStopToLast(int stopIndex) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final stops = List<RouteStopModel>.from(_cachedFleet.stops);
    if (stopIndex < 0 || stopIndex >= stops.length) return _cachedFleet;

    final movedStop = stops.removeAt(stopIndex);
    stops.add(movedStop);

    _cachedFleet = FleetInfoModel(
      routeId: _cachedFleet.routeId,
      routeName: _cachedFleet.routeName,
      activeVehicleNumber: _cachedFleet.activeVehicleNumber,
      totalDistance: _cachedFleet.totalDistance,
      progressPercentage: _cachedFleet.progressPercentage,
      depotInfo: _cachedFleet.depotInfo,
      stops: stops,
    );

    return _cachedFleet;
  }

  @override
  Future<void> reportWrongLocation(LocationReport report) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
