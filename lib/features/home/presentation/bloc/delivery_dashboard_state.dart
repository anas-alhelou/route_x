// lib/features/home/presentation/bloc/delivery_dashboard_state.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

/// Load status of the delivery dashboard.
enum DeliveryDashboardStatus {
  /// Initial frame — skeleton loaders are visible.
  loading,

  /// Data is on screen (may still background-refresh).
  success,

  /// Load failed and nothing can be shown.
  failure,
}

/// Immutable state held by [DeliveryDashboardBloc].
///
/// A single flat state (rather than separate sealed subclasses) keeps the
/// widget tree simple: every [BlocBuilder] reads one snapshot and switches on
/// [status] and [dashboard.scenario] without cascading casts.
class DeliveryDashboardState extends Equatable {
  const DeliveryDashboardState({
    this.status = DeliveryDashboardStatus.loading,
    this.dashboard,
    this.isRefreshing = false,
    this.errorMessage,
  });

  /// Whether data is loading, on screen, or failed.
  final DeliveryDashboardStatus status;

  /// The dashboard snapshot — null while first loading.
  final DeliveryDashboard? dashboard;

  /// A background refresh is in flight (pull-to-refresh).
  final bool isRefreshing;

  /// Set only when [status] is [DeliveryDashboardStatus.failure].
  final String? errorMessage;

  DeliveryDashboardState copyWith({
    DeliveryDashboardStatus? status,
    DeliveryDashboard? dashboard,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return DeliveryDashboardState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dashboard, isRefreshing, errorMessage];
}
