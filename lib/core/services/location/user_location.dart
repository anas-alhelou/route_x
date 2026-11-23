// lib/core/services/location/user_location.dart
import 'package:equatable/equatable.dart';

/// Represents a geographic coordinate and optional metadata for a user.
class UserLocation extends Equatable {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.altitude,
    this.accuracy,
    this.speed,
  });

  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final double? altitude;
  final double? accuracy;
  final double? speed;

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        timestamp,
        altitude,
        accuracy,
        speed,
      ];

  @override
  String toString() =>
      'UserLocation(lat: $latitude, lon: $longitude, time: $timestamp)';
}
