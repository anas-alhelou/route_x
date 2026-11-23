// lib/features/route_fleet/domain/entities/route_stop.dart
import 'package:equatable/equatable.dart';

class RouteStop extends Equatable {
  const RouteStop({
    required this.id,
    required this.title,
    required this.address,
    required this.eta,
    required this.isCompleted,
    required this.status,
    this.phone,
    this.gateCode,
    this.timeWindow,
    this.packagesText,
    this.companyNote,
    this.orderId,
    this.packageType,
    this.doorNumber,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String address;
  final String eta;
  final bool isCompleted;
  final String status;
  final String? phone;
  final String? gateCode;
  final String? timeWindow;
  final String? packagesText;
  final String? companyNote;
  final String? orderId;
  final String? packageType;
  final String? doorNumber;

  /// Where the stop is on the map, when the backend knows it.
  final double? latitude;
  final double? longitude;

  /// Whether [latitude] / [longitude] are a usable position (not missing and
  /// not the `0,0` placeholder).
  bool get hasCoordinates {
    final lat = latitude;
    final lng = longitude;
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    return !(lat == 0 && lng == 0);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        address,
        eta,
        isCompleted,
        status,
        phone,
        gateCode,
        timeWindow,
        packagesText,
        companyNote,
        orderId,
        packageType,
        doorNumber,
        latitude,
        longitude,
      ];
}
