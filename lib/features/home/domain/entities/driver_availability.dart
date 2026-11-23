// lib/features/home/domain/entities/driver_availability.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';

/// Whether the driver is on shift, and their fleet membership status.
class DriverAvailability extends Equatable {
  const DriverAvailability({
    required this.isOnline,
    this.fleetId,
    this.requestStatus = FleetRequestStatus.none,
  });

  /// Whether the driver is currently on shift.
  final bool isOnline;

  /// Id of the fleet the driver belongs to, or null when they have not joined
  /// one yet.
  final String? fleetId;

  /// Status of the driver's fleet membership request.
  final FleetRequestStatus requestStatus;

  /// DriverAvailability.canToggle is true only when status == approved.
  bool get canToggle => requestStatus == FleetRequestStatus.approved;

  @override
  List<Object?> get props => [isOnline, fleetId, requestStatus];
}
