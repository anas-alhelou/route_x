// lib/features/home/data/models/upcoming_ride_model.dart
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';

/// Data-layer shape of an [UpcomingRideEntity].
class UpcomingRideModel extends UpcomingRideEntity {
  const UpcomingRideModel({
    required super.id,
    required super.passengerName,
    super.passengerImageUrl,
    required super.passengerRating,
    required super.pickupLocation,
    required super.dropoffLocation,
    required super.scheduledTime,
    required super.distance,
    required super.duration,
    required super.fare,
  });

  factory UpcomingRideModel.fromJson(Map<String, dynamic> json) {
    return UpcomingRideModel(
      id: json['id'] as String? ?? '',
      passengerName:
          json['passengerName'] as String? ?? json['passenger_name'] as String? ?? '',
      passengerImageUrl: json['passengerImageUrl'] as String? ??
          json['passenger_image_url'] as String?,
      passengerRating: (json['passengerRating'] as num?)?.toDouble() ??
          (json['passenger_rating'] as num?)?.toDouble() ??
          0.0,
      pickupLocation:
          json['pickupLocation'] as String? ?? json['pickup_location'] as String? ?? '',
      dropoffLocation:
          json['dropoffLocation'] as String? ?? json['dropoff_location'] as String? ?? '',
      scheduledTime: DateTime.tryParse(
            json['scheduledTime'] as String? ?? json['scheduled_time'] as String? ?? '',
          ) ??
          DateTime.now(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: Duration(
        seconds: (json['duration'] as num?)?.toInt() ?? 0,
      ),
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerName': passengerName,
      'passengerImageUrl': passengerImageUrl,
      'passengerRating': passengerRating,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'scheduledTime': scheduledTime.toIso8601String(),
      'distance': distance,
      'duration': duration.inSeconds,
      'fare': fare,
    };
  }

  UpcomingRideEntity toEntity() {
    return UpcomingRideEntity(
      id: id,
      passengerName: passengerName,
      passengerImageUrl: passengerImageUrl,
      passengerRating: passengerRating,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      scheduledTime: scheduledTime,
      distance: distance,
      duration: duration,
      fare: fare,
    );
  }
}
