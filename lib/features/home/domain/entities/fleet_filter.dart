// lib/features/home/domain/entities/fleet_filter.dart
import 'package:equatable/equatable.dart';

/// Filter chips shown on the Find a Fleet screen (Figma 5237:3435).
///
/// The Figma node `Filter Chips` is a horizontal row with `itemSpacing: 8`.
/// Each chip maps to one value of this enum; the UI renders the label via
/// `l10n` and the bloc filters the fleet list by this value.
enum FleetFilter {
  /// Show all fleets (default, no filtering).
  all,

  /// Only fleets within a short distance.
  nearby,

  /// Only fleets that are currently accepting drivers.
  active,

  /// Only fleets that are paused / not accepting.
  paused,
}

/// Extension to expose display helpers without polluting the enum itself.
extension FleetFilterX on FleetFilter {
  /// Stable key used for `l10n` lookup and for analytics.
  String get key => switch (this) {
    FleetFilter.all => 'all',
    FleetFilter.nearby => 'nearby',
    FleetFilter.active => 'active',
    FleetFilter.paused => 'paused',
  };
}

/// A single filter chip as rendered on the Find a Fleet screen.
class FleetFilterChip extends Equatable {
  const FleetFilterChip({required this.filter, required this.isSelected});

  final FleetFilter filter;
  final bool isSelected;

  FleetFilterChip copyWith({bool? isSelected}) {
    return FleetFilterChip(
      filter: filter,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [filter, isSelected];
}
