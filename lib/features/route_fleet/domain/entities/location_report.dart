// lib/features/route_fleet/domain/entities/location_report.dart
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class LocationReport extends Equatable {
  const LocationReport({
    required this.stopId,
    required this.reasonCode,
    required this.reasonText,
    this.correctedLatLng,
  });

  final String stopId;
  final String reasonCode;
  final String reasonText;
  final LatLng? correctedLatLng;

  @override
  List<Object?> get props => [stopId, reasonCode, reasonText, correctedLatLng];
}
