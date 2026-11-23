// lib/features/route_fleet/domain/entities/fleet_info.dart
import 'package:equatable/equatable.dart';
import 'route_stop.dart';

class DepotInfo extends Equatable {
  const DepotInfo({
    required this.name,
    required this.address,
    required this.distanceText,
    required this.etaText,
  });

  final String name;
  final String address;
  final String distanceText;
  final String etaText;

  @override
  List<Object?> get props => [name, address, distanceText, etaText];
}

class FleetInfo extends Equatable {
  const FleetInfo({
    required this.routeId,
    required this.routeName,
    required this.activeVehicleNumber,
    required this.totalDistance,
    required this.progressPercentage,
    required this.stops,
    required this.depotInfo,
  });

  final String routeId;
  final String routeName;
  final String activeVehicleNumber;
  final String totalDistance;
  final double progressPercentage;
  final List<RouteStop> stops;
  final DepotInfo depotInfo;

  @override
  List<Object?> get props => [
        routeId,
        routeName,
        activeVehicleNumber,
        totalDistance,
        progressPercentage,
        stops,
        depotInfo,
      ];
}
