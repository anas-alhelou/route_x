// lib/features/home/domain/entities/upcoming_ride_entity.dart
import 'package:equatable/equatable.dart';

/// Represents an upcoming ride with passenger and route details.
class UpcomingRideEntity extends Equatable {
  const UpcomingRideEntity({
    required this.id,
    required this.passengerName,
    this.passengerImageUrl,
    required this.passengerRating,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.scheduledTime,
    required this.distance,
    required this.duration,
    required this.fare,
  });

  final String id;
  final String passengerName;
  final String? passengerImageUrl;
  final double passengerRating;

  final String pickupLocation;
  final String dropoffLocation;
  final DateTime scheduledTime;

  final double distance;
  final Duration duration;
  final double fare;

  /// Whether the ride is upcoming.
  bool get isUpcoming => scheduledTime.isAfter(DateTime.now());

  /// Time until pickup as duration.
  Duration get timeUntilPickup => scheduledTime.difference(DateTime.now());

  /// Formatted scheduled time string.
  String get formattedTime {
    final hour = scheduledTime.hour.toString().padLeft(2, '0');
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => [
        id,
        passengerName,
        passengerImageUrl,
        passengerRating,
        pickupLocation,
        dropoffLocation,
        scheduledTime,
        distance,
        duration,
        fare,
      ];
}
