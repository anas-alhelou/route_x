// lib/features/home/presentation/bloc/find_fleet_event.dart
// Convention: events, states and the bloc live in separate files, all exported
// through find_fleet_bloc.dart.
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';

/// Base class for every [FindFleetBloc] event.
sealed class FindFleetEvent extends Equatable {
  const FindFleetEvent();

  @override
  List<Object?> get props => [];
}

/// Loads fleets and available filters for the first time.
class FindFleetStarted extends FindFleetEvent {
  const FindFleetStarted();
}

/// Pull-to-refresh. Keeps current content visible while reloading.
class FindFleetRefreshed extends FindFleetEvent {
  const FindFleetRefreshed();
}

/// The driver typed in the search field.
class FindFleetQueryChanged extends FindFleetEvent {
  const FindFleetQueryChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// The driver tapped a filter chip.
class FindFleetFilterSelected extends FindFleetEvent {
  const FindFleetFilterSelected({required this.filter});

  final FleetFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// The driver tapped Join on a fleet row.
class FindFleetJoinRequested extends FindFleetEvent {
  const FindFleetJoinRequested({required this.fleetId});

  final String fleetId;

  @override
  List<Object?> get props => [fleetId];
}

/// The driver dismissed the error surface after a failed action.
class FindFleetErrorDismissed extends FindFleetEvent {
  const FindFleetErrorDismissed();
}
