// lib/features/home/presentation/bloc/delivery_dashboard_event.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/services/location/user_location.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

/// Base class for every [DeliveryDashboardBloc] event.
sealed class DeliveryDashboardEvent extends Equatable {
  const DeliveryDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the page mounts, triggers the initial data load.
class DeliveryDashboardInitialized extends DeliveryDashboardEvent {
  const DeliveryDashboardInitialized({this.initialScenario});

  final DeliveryScenario? initialScenario;

  @override
  List<Object?> get props => [initialScenario];
}

/// Fired by pull-to-refresh — performs a quiet reload while keeping content on screen.
class DeliveryDashboardRefreshed extends DeliveryDashboardEvent {
  const DeliveryDashboardRefreshed();
}

/// Explicitly transitions to a target scenario (e.g. HM2, HM3, HM5, HM6).
class DeliveryDashboardScenarioChanged extends DeliveryDashboardEvent {
  const DeliveryDashboardScenarioChanged(this.scenario);

  final DeliveryScenario scenario;

  @override
  List<Object?> get props => [scenario];
}

/// Cycles to the next mock scenario for design review purposes.
class DeliveryDashboardScenarioCycled extends DeliveryDashboardEvent {
  const DeliveryDashboardScenarioCycled();
}

/// Fired when user location is detected or changes.
class DeliveryDashboardLocationUpdated extends DeliveryDashboardEvent {
  const DeliveryDashboardLocationUpdated(this.location);

  final UserLocation location;

  @override
  List<Object?> get props => [location];
}

