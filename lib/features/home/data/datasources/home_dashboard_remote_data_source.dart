// lib/features/home/data/datasources/home_dashboard_remote_data_source.dart
import 'package:routex_mobile/features/home/data/models/driver_model.dart';
import 'package:routex_mobile/features/home/data/models/driver_status_model.dart';
import 'package:routex_mobile/features/home/data/models/home_stats_model.dart';
import 'package:routex_mobile/features/home/data/models/location_model.dart';
import 'package:routex_mobile/features/home/data/models/upcoming_ride_model.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';

/// Contract for the dashboard endpoints backing [HomeDashboardRepository].
///
/// Returns data-layer [models], never entities: converting to an entity is the
/// repository's job, so a change to the wire shape stops here. No backend path
/// exists for these yet — `ApiEndpoints` registers only auth and orders — so the
/// only implementation today is [MockHomeDashboardRemoteDataSource].
abstract interface class HomeDashboardRemoteDataSource {
  Future<DriverModel> getDriverProfile();

  Future<HomeStatsModel> getHomeStats();

  Future<List<UpcomingRideModel>> getUpcomingRides();

  Future<DriverStatusModel> updateDriverStatus({
    required DriverStatus status,
    Duration? onlineForDuration,
  });

  Future<LocationModel> getCurrentLocation();

  Future<DriverStatusModel> getCurrentStatus();

  Future<void> refreshHomeData();
}
