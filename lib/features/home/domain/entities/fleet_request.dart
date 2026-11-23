// lib/features/home/domain/entities/fleet_request.dart
import 'package:equatable/equatable.dart';

/// The status of a driver's request to join a fleet.
enum FleetRequestStatus {
  /// No join request has been submitted yet.
  none,

  /// Request is submitted and awaiting dispatcher review.
  pending,

  /// Request was declined by the dispatcher.
  declined,

  /// Request was approved; driver can go online.
  approved,
}

/// A driver's application to join a fleet.
class FleetRequest extends Equatable {
  const FleetRequest({
    required this.fleetId,
    required this.fleetName,
    required this.fleetLogoPath,
    required this.requestedAt,
    required this.status,
    this.declineReason,
  });

  /// Identifier of the requested fleet.
  final String fleetId;

  /// Display name of the fleet.
  final String fleetName;

  /// Asset path to the fleet's logo.
  final String fleetLogoPath;

  /// Time when the request was initiated.
  final DateTime requestedAt;

  /// Current status of the request.
  final FleetRequestStatus status;

  /// Optional explanation from the dispatcher if declined.
  final String? declineReason;

  @override
  List<Object?> get props => [
    fleetId,
    fleetName,
    fleetLogoPath,
    requestedAt,
    status,
    declineReason,
  ];
}
