// lib/features/home/presentation/bloc/home_dashboard_state.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';

/// Stage of the dashboard load.
enum HomeDashboardStatus { initial, loading, success, failure }

/// State for the dashboard block.
class HomeDashboardState extends Equatable {
  const HomeDashboardState({
    this.status = HomeDashboardStatus.initial,
    this.driver,
    this.stats,
    this.rides = const [],
    this.isRefreshing = false,
    this.errorMessage,
  });

  final HomeDashboardStatus status;
  final DriverEntity? driver;
  final HomeStatsEntity? stats;
  final List<UpcomingRideEntity> rides;
  final bool isRefreshing;
  final String? errorMessage;

  bool get hasContent => driver != null && stats != null;

  HomeDashboardState copyWith({
    HomeDashboardStatus? status,
    DriverEntity? driver,
    HomeStatsEntity? stats,
    List<UpcomingRideEntity>? rides,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return HomeDashboardState(
      status: status ?? this.status,
      driver: driver ?? this.driver,
      stats: stats ?? this.stats,
      rides: rides ?? this.rides,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, driver, stats, rides, isRefreshing, errorMessage];
}
