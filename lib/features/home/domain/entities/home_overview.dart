// lib/features/home/domain/entities/home_overview.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_profile.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/domain/entities/setup_progress.dart';
import 'package:routex_mobile/features/home/domain/entities/shift_stats.dart';

/// Everything the Home screen renders, in one value.
class HomeOverview extends Equatable {
  const HomeOverview({
    required this.profile,
    required this.availability,
    required this.stats,
    required this.setup,
    required this.nearbyFleets,
    this.fleetRequest,
  });

  /// Header: avatar and greeting.
  final DriverProfile profile;

  /// Header switch: on-shift state and fleet lock.
  final DriverAvailability availability;

  /// "Today's overview" tiles.
  final ShiftStats stats;

  /// "Get started" checklist.
  final SetupProgress setup;

  /// "Fleets near you" list.
  final List<FleetSummary> nearbyFleets;

  /// Active or previous request to join a fleet.
  final FleetRequest? fleetRequest;

  /// Whether the setup checklist is finished, which is what unlocks the header
  /// switch in the design.
  bool get isSetupComplete => setup.completedCount == setup.steps.length;

  @override
  List<Object?> get props => [
    profile,
    availability,
    stats,
    setup,
    nearbyFleets,
    fleetRequest,
  ];
}
