// lib/features/home/data/datasources/mock_home_dashboard_remote_data_source.dart
import 'package:routex_mobile/features/home/data/datasources/home_dashboard_remote_data_source.dart';
import 'package:routex_mobile/features/home/data/models/driver_model.dart';
import 'package:routex_mobile/features/home/data/models/driver_status_model.dart';
import 'package:routex_mobile/features/home/data/models/home_stats_model.dart';
import 'package:routex_mobile/features/home/data/models/location_model.dart';
import 'package:routex_mobile/features/home/data/models/upcoming_ride_model.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';

/// In-memory stand-in for the dashboard endpoints.
///
/// Simulates network latency and returns realistic data so the dashboard can be
/// exercised end-to-end before the backend exists. Status is the one mutable
/// field, so an update is visible to a later [getCurrentStatus].
class MockHomeDashboardRemoteDataSource
    implements HomeDashboardRemoteDataSource {
  MockHomeDashboardRemoteDataSource();

  static const Duration _latency = Duration(milliseconds: 500);

  DriverStatusEntity _status = DriverStatusEntity(
    status: DriverStatus.online,
    lastUpdated: DateTime.now(),
    onlineForDuration: const Duration(hours: 3, minutes: 24),
  );

  @override
  Future<DriverModel> getDriverProfile() async {
    await Future<void>.delayed(_latency);
    return DriverModel(
      id: 'drv-20481',
      firstName: 'Hamza',
      lastName: 'Barakat',
      email: 'hamza.barakat@routex.app',
      phone: '+966591144453',
      profileImageUrl: 'https://i.pravatar.cc/300?img=12',
      vehicleType: 'Motorcycle',
      vehicleNumber: 'KSA-4821',
      licenseNumber: 'DL-99821-XZ',
      rating: 4.87,
      reviewCount: 1243,
      isVerified: true,
      joinDate: DateTime(2022, 3, 14),
      totalEarnings: 187500.0,
      weeklyEarnings: 3420.0,
      referralBonus: 250.0,
      yearsActive: 4,
    );
  }

  @override
  Future<HomeStatsModel> getHomeStats() async {
    await Future<void>.delayed(_latency);
    return const HomeStatsModel(
      todayRides: 12,
      todayEarnings: 486.5,
      totalDrivingTime: Duration(hours: 6, minutes: 15),
      averageRating: 4.87,
      completionRate: 96.4,
      averageSpeed: 42.3,
      completedRidesWeekly: 68,
      cancelledRidesWeekly: 4,
    );
  }

  @override
  Future<List<UpcomingRideModel>> getUpcomingRides() async {
    await Future<void>.delayed(_latency);
    final now = DateTime.now();
    return [
      UpcomingRideModel(
        id: 'ride-78321',
        passengerName: 'Layla Al-Harbi',
        passengerImageUrl: 'https://i.pravatar.cc/300?img=45',
        passengerRating: 4.9,
        pickupLocation: 'Al Hamra District, Jeddah',
        dropoffLocation: 'King Abdullah Financial District, Riyadh',
        scheduledTime: now.add(const Duration(minutes: 18)),
        distance: 8.4,
        duration: const Duration(minutes: 26),
        fare: 34.5,
      ),
      UpcomingRideModel(
        id: 'ride-78340',
        passengerName: 'Omar Siddiqui',
        passengerImageUrl: 'https://i.pravatar.cc/300?img=33',
        passengerRating: 4.7,
        pickupLocation: 'Al Rawdah, Jeddah',
        dropoffLocation: 'Red Sea Mall',
        scheduledTime: now.add(const Duration(hours: 1, minutes: 5)),
        distance: 5.1,
        duration: const Duration(minutes: 17),
        fare: 22.0,
      ),
    ];
  }

  @override
  Future<DriverStatusModel> updateDriverStatus({
    required DriverStatus status,
    Duration? onlineForDuration,
  }) async {
    await Future<void>.delayed(_latency);
    _status = DriverStatusEntity(
      status: status,
      lastUpdated: DateTime.now(),
      onlineForDuration: onlineForDuration ?? _status.onlineForDuration,
    );
    return DriverStatusModel(
      status: _status.status,
      lastUpdated: _status.lastUpdated,
      onlineForDuration: _status.onlineForDuration,
    );
  }

  @override
  Future<LocationModel> getCurrentLocation() async {
    await Future<void>.delayed(_latency);
    return const LocationModel(
      latitude: 21.4858,
      longitude: 39.1925,
      address: 'Al Hamra District, Jeddah, Saudi Arabia',
    );
  }

  @override
  Future<DriverStatusModel> getCurrentStatus() async {
    await Future<void>.delayed(_latency);
    return DriverStatusModel(
      status: _status.status,
      lastUpdated: _status.lastUpdated,
      onlineForDuration: _status.onlineForDuration,
    );
  }

  @override
  Future<void> refreshHomeData() async {
    await Future<void>.delayed(_latency);
  }
}
