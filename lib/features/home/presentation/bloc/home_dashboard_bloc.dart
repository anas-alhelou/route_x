// lib/features/home/presentation/bloc/home_dashboard_bloc.dart
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_driver_profile_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_home_stats_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_upcoming_rides_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_dashboard_event.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_dashboard_state.dart';

export 'home_dashboard_event.dart';
export 'home_dashboard_state.dart';

/// Owns the dashboard block: the driver, the stats and the upcoming rides.
///
/// Loads the three in parallel and fails the whole load if any of them fail —
/// a half-populated dashboard is worse than none, so the three are treated as
/// one unit. Re-arms a 30-second refresh on [HomeDashboardInitialized] and
/// cancels it in [close].
class HomeDashboardBloc extends Bloc<HomeDashboardEvent, HomeDashboardState> {
  HomeDashboardBloc({
    required GetDriverProfileUseCase getDriverProfile,
    required GetHomeStatsUseCase getHomeStats,
    required GetUpcomingRidesUseCase getUpcomingRides,
    Duration refreshInterval = const Duration(seconds: 30),
  })  : _getDriverProfile = getDriverProfile,
        _getHomeStats = getHomeStats,
        _getUpcomingRides = getUpcomingRides,
        _refreshInterval = refreshInterval,
        super(const HomeDashboardState()) {
    on<HomeDashboardInitialized>(_onInitialized);
    on<HomeDashboardRefreshRequested>(_onRefreshRequested);
  }

  final GetDriverProfileUseCase _getDriverProfile;
  final GetHomeStatsUseCase _getHomeStats;
  final GetUpcomingRidesUseCase _getUpcomingRides;

  final Duration _refreshInterval;

  Timer? _refreshTimer;

  Future<void> _onInitialized(
    HomeDashboardInitialized event,
    Emitter<HomeDashboardState> emit,
  ) async {
    emit(state.copyWith(status: HomeDashboardStatus.loading));
    await _load(emit);
    _startPeriodicRefresh();
  }

  Future<void> _onRefreshRequested(
    HomeDashboardRefreshRequested event,
    Emitter<HomeDashboardState> emit,
  ) async {
    // Quiet refresh: keep whatever is on screen while the new data lands.
    emit(state.copyWith(status: HomeDashboardStatus.success, isRefreshing: true));
    await _load(emit);
  }

  Future<void> _load(Emitter<HomeDashboardState> emit) async {
    final results = await Future.wait<Either<Failure, Object>>([
      _getDriverProfile(),
      _getHomeStats(),
      _getUpcomingRides(),
    ]);

    Failure? failure;
    for (final result in results) {
      final f = result.fold<Failure?>((l) => l, (_) => null);
      if (f != null) {
        failure = f;
        break;
      }
    }

    if (failure != null) {
      emit(
        state.copyWith(
          status: state.hasContent
              ? HomeDashboardStatus.success
              : HomeDashboardStatus.failure,
          isRefreshing: false,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    final driver = _unwrap<DriverEntity>(results[0]);
    final stats = _unwrap<HomeStatsEntity>(results[1]);
    final rides = _unwrap<List<UpcomingRideEntity>>(results[2]);

    emit(
      state.copyWith(
        status: HomeDashboardStatus.success,
        driver: driver,
        stats: stats,
        rides: rides,
        isRefreshing: false,
      ),
    );
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!isClosed) add(const HomeDashboardRefreshRequested());
    });
  }

  T _unwrap<T>(Either<Failure, Object> result) =>
      result.fold((_) => throw StateError('called after success check'), (v) => v as T);

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
