// lib/features/home/data/models/location_model.dart
import 'package:routex_mobile/features/home/domain/entities/location_entity.dart';

/// Data-layer shape of a [LocationEntity].
class LocationModel extends LocationEntity {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    required super.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  LocationEntity toEntity() {
    return LocationEntity(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}
