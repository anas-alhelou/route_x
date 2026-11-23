// lib/features/home/domain/repositories/home_dashboard_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/location_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';

/// Abstract contract for dashboard/home data operations as specified in Part 3.
///
/// Coexists with the existing [HomeRepository] which serves the current UI.
/// Nothing in existing code depends on this yet.
abstract class HomeDashboardRepository {
  Future<Either<Failure, DriverEntity>> getDriverProfile();
  Future<Either<Failure, HomeStatsEntity>> getHomeStats();
  Future<Either<Failure, List<UpcomingRideEntity>>> getUpcomingRides();
  Future<Either<Failure, DriverStatusEntity>> updateDriverStatus({
    required DriverStatus status,
    Duration? onlineForDuration,
  });
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
  Future<Either<Failure, DriverStatusEntity>> getCurrentStatus();
  Future<Either<Failure, void>> refreshHomeData();
}
