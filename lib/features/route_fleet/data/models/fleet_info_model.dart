// lib/features/route_fleet/data/models/fleet_info_model.dart
import '../../domain/entities/fleet_info.dart';
import 'route_stop_model.dart';

class DepotInfoModel extends DepotInfo {
  const DepotInfoModel({
    required super.name,
    required super.address,
    required super.distanceText,
    required super.etaText,
  });

  factory DepotInfoModel.fromJson(Map<String, dynamic> json) {
    return DepotInfoModel(
      name: json['name'] as String? ?? 'Red Sea Express hub',
      address: json['address'] as String? ?? 'Al Rawdah',
      distanceText: json['distance_text'] as String? ?? '3.1 km',
      etaText: json['eta_text'] as String? ?? 'arrive 11:02',
    );
  }
}

class FleetInfoModel extends FleetInfo {
  const FleetInfoModel({
    required super.routeId,
    required super.routeName,
    required super.activeVehicleNumber,
    required super.totalDistance,
    required super.progressPercentage,
    required List<RouteStopModel> super.stops,
    required super.depotInfo,
  });

  factory FleetInfoModel.fromJson(Map<String, dynamic> json) {
    return FleetInfoModel(
      routeId: json['route_id'] as String,
      routeName: json['route_name'] as String,
      activeVehicleNumber: json['active_vehicle_number'] as String,
      totalDistance: json['total_distance'] as String,
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      stops: (json['stops'] as List<dynamic>)
          .map((e) => RouteStopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      depotInfo: json['depot_info'] != null
          ? DepotInfoModel.fromJson(json['depot_info'] as Map<String, dynamic>)
          : const DepotInfoModel(
              name: 'Red Sea Express hub',
              address: 'Al Rawdah',
              distanceText: '3.1 km',
              etaText: 'arrive 11:02',
            ),
    );
  }
}
