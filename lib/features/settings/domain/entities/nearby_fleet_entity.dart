// lib/features/settings/domain/entities/nearby_fleet_entity.dart
import 'package:equatable/equatable.dart';

/// A fleet the driver can ask to join, close to their current location.
class NearbyFleetEntity extends Equatable {
  const NearbyFleetEntity({
    required this.id,
    required this.name,
    required this.area,
    required this.distanceKm,
    this.logoUrl,
  });

  final String id;
  final String name;

  /// Neighbourhood the fleet operates from, e.g. "Al Hamra".
  final String area;
  final double distanceKm;
  final String? logoUrl;

  @override
  List<Object?> get props => [id, name, area, distanceKm, logoUrl];
}
