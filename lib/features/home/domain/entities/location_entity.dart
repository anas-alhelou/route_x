// lib/features/home/domain/entities/location_entity.dart
import 'package:equatable/equatable.dart';

/// Represents a geographical location with coordinates and address.
class LocationEntity extends Equatable {
  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;

  @override
  List<Object?> get props => [latitude, longitude, address];
}
