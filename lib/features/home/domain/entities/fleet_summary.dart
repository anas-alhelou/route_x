// lib/features/home/domain/entities/fleet_summary.dart
import 'package:equatable/equatable.dart';

/// Whether a fleet is currently taking new drivers.
enum FleetJoinStatus {
  /// Accepting join requests; the Join button is enabled.
  active,

  /// Not accepting; the Join button is disabled and the row is muted.
  paused,
}

/// A fleet as listed on Home and on the Find a fleet screen.
///
/// [accentColor] is the fleet's own brand colour, used for the avatar outline,
/// and [avatarFill] is the tint behind its logo — the design draws both, and
/// they are independent (three fleets use blue/black/brown outlines over three
/// unrelated near-whites), so neither can be derived from the other. Both are
/// carried as plain ARGB `int`s to keep the domain layer free of `dart:ui`;
/// the widget layer wraps them in `Color(...)`. [logoPath] follows the same
/// convention as `DriverProfile.avatarPath`.
class FleetSummary extends Equatable {
  const FleetSummary({
    required this.id,
    required this.name,
    required this.zone,
    required this.distanceKm,
    required this.logoPath,
    required this.accentColor,
    required this.avatarFill,
    required this.status,
    this.driverCount = 0,
  });

  /// Stable identifier used when requesting a join.
  final String id;

  /// Display name ("Red Sea Express").
  final String name;

  /// Delivery zone the fleet operates in ("Al Hamra").
  final String zone;

  /// Distance from the driver, in kilometres.
  final double distanceKm;

  /// Asset path or URL of the fleet logo.
  final String logoPath;

  /// ARGB value of the fleet's brand colour.
  final int accentColor;

  /// ARGB value painted behind the logo, inside the avatar's border.
  final int avatarFill;

  /// Whether the fleet is accepting drivers.
  final FleetJoinStatus status;

  /// Size of the fleet's driver pool; only the search screen shows it.
  final int driverCount;

  /// Whether a join request can be sent for this fleet.
  bool get canJoin => status == FleetJoinStatus.active;

  @override
  List<Object?> get props => [
    id,
    name,
    zone,
    distanceKm,
    logoPath,
    accentColor,
    avatarFill,
    status,
    driverCount,
  ];
}
