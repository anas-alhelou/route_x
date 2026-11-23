// lib/features/home/data/datasources/home_dashboard_local_data_source.dart
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/location_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';

/// Contract for the dashboard's cache layer.
///
/// Stores domain entities, not models: the repository converts on the way in,
/// so what comes back out of the cache is immediately usable above the data
/// layer. Every getter returns `null` on a miss; none of them throw for a miss.
abstract interface class HomeDashboardLocalDataSource {
  Future<DriverEntity?> getCachedDriver();

  Future<void> cacheDriver(DriverEntity driver);

  Future<HomeStatsEntity?> getCachedHomeStats();

  Future<void> cacheHomeStats(HomeStatsEntity stats);

  Future<List<UpcomingRideEntity>?> getCachedUpcomingRides();

  Future<void> cacheUpcomingRides(List<UpcomingRideEntity> rides);

  Future<DriverStatusEntity?> getCachedDriverStatus();

  Future<void> cacheDriverStatus(DriverStatusEntity status);

  Future<LocationEntity?> getCachedLocation();

  Future<void> cacheLocation(LocationEntity location);

  Future<void> clearCache();
}
