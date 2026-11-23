// lib/features/home/data/datasources/mock_home_dashboard_local_data_source.dart
import 'package:routex_mobile/features/home/data/datasources/home_dashboard_local_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/location_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';

/// In-memory implementation of the dashboard cache.
///
/// Holds whatever was last written for the lifetime of the process. There is no
/// disk backing: a restart is a cold cache, which is exactly what the
/// repository's cache-first path expects to fall through from.
class MockHomeDashboardLocalDataSource
    implements HomeDashboardLocalDataSource {
  MockHomeDashboardLocalDataSource();

  DriverEntity? _driver;
  HomeStatsEntity? _homeStats;
  List<UpcomingRideEntity>? _upcomingRides;
  DriverStatusEntity? _driverStatus;
  LocationEntity? _location;

  @override
  Future<DriverEntity?> getCachedDriver() async => _driver;

  @override
  Future<void> cacheDriver(DriverEntity driver) async => _driver = driver;

  @override
  Future<HomeStatsEntity?> getCachedHomeStats() async => _homeStats;

  @override
  Future<void> cacheHomeStats(HomeStatsEntity stats) async => _homeStats = stats;

  @override
  Future<List<UpcomingRideEntity>?> getCachedUpcomingRides() async =>
      _upcomingRides;

  @override
  Future<void> cacheUpcomingRides(List<UpcomingRideEntity> rides) async =>
      _upcomingRides = rides;

  @override
  Future<DriverStatusEntity?> getCachedDriverStatus() async => _driverStatus;

  @override
  Future<void> cacheDriverStatus(DriverStatusEntity status) async =>
      _driverStatus = status;

  @override
  Future<LocationEntity?> getCachedLocation() async => _location;

  @override
  Future<void> cacheLocation(LocationEntity location) async =>
      _location = location;

  @override
  Future<void> clearCache() async {
    _driver = null;
    _homeStats = null;
    _upcomingRides = null;
    _driverStatus = null;
    _location = null;
  }
}
