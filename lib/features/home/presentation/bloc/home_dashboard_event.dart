// lib/features/home/presentation/bloc/home_dashboard_event.dart
import 'package:equatable/equatable.dart';

/// Base class for every [HomeDashboardBloc] event.
sealed class HomeDashboardEvent extends Equatable {
  const HomeDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the dashboard for the first time and starts the periodic refresh.
class HomeDashboardInitialized extends HomeDashboardEvent {
  const HomeDashboardInitialized();
}

/// Reloads profile, stats and rides. Dispatched by pull-to-refresh and by the
/// 30-second periodic timer.
class HomeDashboardRefreshRequested extends HomeDashboardEvent {
  const HomeDashboardRefreshRequested();
}
