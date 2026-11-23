// lib/features/home/domain/entities/shift_stats.dart
import 'package:equatable/equatable.dart';

/// The "Today's overview" figures for the current shift.
///
/// Holds raw numbers rather than the strings the tiles render: the unit lines
/// ("of 0", "km", "on shift") are localized copy, so formatting and
/// translation belong to the presentation layer and must not be frozen into a
/// value the data layer produces.
class ShiftStats extends Equatable {
  const ShiftStats({
    required this.deliveries,
    required this.deliveriesTarget,
    required this.distanceKm,
    required this.shiftDuration,
  });

  /// Deliveries completed so far.
  final int deliveries;

  /// Deliveries the driver is working towards today.
  final int deliveriesTarget;

  /// Distance covered today, in kilometres.
  final double distanceKm;

  /// Time spent on shift so far.
  final Duration shiftDuration;

  @override
  List<Object?> get props => [
    deliveries,
    deliveriesTarget,
    distanceKm,
    shiftDuration,
  ];
}
