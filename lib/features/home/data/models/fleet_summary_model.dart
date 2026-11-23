// lib/features/home/data/models/fleet_summary_model.dart
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';

/// Data-layer shape of a [FleetSummary].
class FleetSummaryModel extends FleetSummary {
  const FleetSummaryModel({
    required super.id,
    required super.name,
    required super.zone,
    required super.distanceKm,
    required super.logoPath,
    required super.accentColor,
    required super.avatarFill,
    required super.status,
    super.driverCount,
  });

  factory FleetSummaryModel.fromJson(Map<String, dynamic> json) {
    return FleetSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      zone: json['zone'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      logoPath: json['logoPath'] as String,
      accentColor: (json['accentColor'] as num).toInt(),
      avatarFill: (json['avatarFill'] as num).toInt(),
      status: FleetJoinStatus.values.byName(json['status'] as String),
      driverCount: (json['driverCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'zone': zone,
    'distanceKm': distanceKm,
    'logoPath': logoPath,
    'accentColor': accentColor,
    'avatarFill': avatarFill,
    'status': status.name,
    'driverCount': driverCount,
  };
}
