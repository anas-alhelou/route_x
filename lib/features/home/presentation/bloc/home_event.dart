// lib/features/home/presentation/bloc/home_event.dart
// Convention: events, states and the bloc live in separate files, all exported
// through home_bloc.dart.
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';

/// Base class for every [HomeBloc] event.
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the dashboard for the first time, or whenever Home is re-entered.
///
/// Distinct from [HomeRefreshed] so the page can tell "show me the spinner"
/// from "refresh quietly behind the content" — on re-entry the old snapshot is
/// still on screen and covering it would be a flash of nothing.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Pull-to-refresh. Keeps the current content visible while reloading.
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

/// The driver asked to go on or off shift.
class HomeOnlineToggled extends HomeEvent {
  const HomeOnlineToggled({required this.isOnline});

  /// The state the switch was moved to, not the state it was left in.
  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}

/// The driver tapped Join on a fleet row.
class HomeFleetJoinRequested extends HomeEvent {
  const HomeFleetJoinRequested({required this.fleetId});

  final String fleetId;

  @override
  List<Object?> get props => [fleetId];
}

/// The driver dismissed the error surface after a failed action.
class HomeErrorDismissed extends HomeEvent {
  const HomeErrorDismissed();
}

/// The driver tapped the locked switch to go online.
class HomeOnlineBlockedTapped extends HomeEvent {
  const HomeOnlineBlockedTapped();
}

/// The UI dismissed the blocked sheet.
class HomeBlockedReasonDismissed extends HomeEvent {
  const HomeBlockedReasonDismissed();
}

/// Debug event to resolve or toggle the fleet request status for testing UI frames.
class HomeDebugRequestStatusChanged extends HomeEvent {
  const HomeDebugRequestStatusChanged({required this.status, this.reason});

  final FleetRequestStatus status;
  final String? reason;

  @override
  List<Object?> get props => [status, reason];
}
