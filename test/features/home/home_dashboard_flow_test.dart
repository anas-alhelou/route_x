import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/data/datasources/home_dashboard_remote_data_source.dart';
import 'package:routex_mobile/features/home/data/datasources/mock_home_dashboard_local_data_source.dart';
import 'package:routex_mobile/features/home/data/models/driver_model.dart';
import 'package:routex_mobile/features/home/data/models/driver_status_model.dart';
import 'package:routex_mobile/features/home/data/models/home_stats_model.dart';
import 'package:routex_mobile/features/home/data/models/location_model.dart';
import 'package:routex_mobile/features/home/data/models/upcoming_ride_model.dart';
import 'package:routex_mobile/features/home/data/repositories/home_dashboard_repository_impl.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_current_status_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_driver_profile_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_home_stats_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_upcoming_rides_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/update_driver_status_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/driver_status_cubit.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_dashboard_bloc.dart';

/// Deterministic fake remote with counters so cache hits and refresh cycles can
/// be observed without a network.
class _FakeRemote implements HomeDashboardRemoteDataSource {
  _FakeRemote({
    this.delay = Duration.zero,
    this.failStats = false,
    this.emptyRides = false,
    this.status = DriverStatus.offline,
  });

  final Duration delay;
  final bool failStats;
  final bool emptyRides;
  DriverStatus status;

  int profileCalls = 0;
  int statsCalls = 0;
  int ridesCalls = 0;

  Future<void> _wait() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
  }

  @override
  Future<DriverModel> getDriverProfile() async {
    profileCalls++;
    await _wait();
    return DriverModel(
      id: '1',
      firstName: 'Hamza',
      lastName: 'Barakat',
      email: 'a@b.c',
      phone: '1',
      profileImageUrl: null,
      vehicleType: 'Motorcycle',
      vehicleNumber: 'KSA-1',
      licenseNumber: 'L',
      rating: 4.7,
      reviewCount: 10,
      isVerified: true,
      joinDate: DateTime(2022),
      totalEarnings: 100,
      weeklyEarnings: 10,
      referralBonus: 250,
      yearsActive: 2,
    );
  }

  @override
  Future<HomeStatsModel> getHomeStats() async {
    statsCalls++;
    await _wait();
    if (failStats) throw const ServerFailure('stats failed');
    return const HomeStatsModel(
      todayRides: 12,
      todayEarnings: 480,
      totalDrivingTime: Duration(hours: 6),
      averageRating: 4.7,
      completionRate: 96,
      averageSpeed: 42,
      completedRidesWeekly: 68,
      cancelledRidesWeekly: 4,
    );
  }

  @override
  Future<List<UpcomingRideModel>> getUpcomingRides() async {
    ridesCalls++;
    await _wait();
    if (emptyRides) return const [];
    final now = DateTime.now();
    return [
      UpcomingRideModel(
        id: 'r1',
        passengerName: 'Passenger',
        passengerImageUrl: null,
        passengerRating: 4.8,
        pickupLocation: 'A',
        dropoffLocation: 'B',
        scheduledTime: now.add(const Duration(minutes: 20)),
        distance: 3,
        duration: const Duration(minutes: 10),
        fare: 25,
      ),
    ];
  }

  @override
  Future<DriverStatusModel> updateDriverStatus({
    required DriverStatus status,
    Duration? onlineForDuration,
  }) async {
    await _wait();
    this.status = status;
    return DriverStatusModel(status: status, lastUpdated: DateTime.now());
  }

  @override
  Future<LocationModel> getCurrentLocation() async {
    await _wait();
    return const LocationModel(latitude: 1, longitude: 1, address: 'Al Hamra');
  }

  @override
  Future<DriverStatusModel> getCurrentStatus() async {
    await _wait();
    return DriverStatusModel(status: status, lastUpdated: DateTime.now());
  }

  @override
  Future<void> refreshHomeData() async => _wait();
}

HomeDashboardBloc _bloc(
  _FakeRemote remote, {
  Duration refreshInterval = const Duration(seconds: 30),
}) {
  final repo = HomeDashboardRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: MockHomeDashboardLocalDataSource(),
  );
  return HomeDashboardBloc(
    getDriverProfile: GetDriverProfileUseCase(repo),
    getHomeStats: GetHomeStatsUseCase(repo),
    getUpcomingRides: GetUpcomingRidesUseCase(repo),
    refreshInterval: refreshInterval,
  );
}

void main() {
  test('1. happy path — all data loads into a success state', () async {
    final bloc = _bloc(_FakeRemote());
    bloc.add(const HomeDashboardInitialized());
    final success = await bloc.stream.firstWhere(
      (s) => s.status == HomeDashboardStatus.success,
    );
    expect(success.driver, isNotNull);
    expect(success.stats, isNotNull);
    expect(success.rides, isNotEmpty);
    await bloc.close();
  });

  test('2. network delay — loading is emitted before success', () async {
    final bloc = _bloc(_FakeRemote(delay: const Duration(milliseconds: 80)));
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<HomeDashboardState>()
            .having((s) => s.status, 'loading', HomeDashboardStatus.loading)
            .having((s) => s.driver, 'no driver yet', isNull),
        isA<HomeDashboardState>()
            .having((s) => s.status, 'success', HomeDashboardStatus.success),
      ]),
    );
    bloc.add(const HomeDashboardInitialized());
    await expectation;
    await bloc.close();
  });

  test('3. partial failure — one endpoint failing fails the whole load', () async {
    final bloc = _bloc(_FakeRemote(failStats: true));
    bloc.add(const HomeDashboardInitialized());
    final failure = await bloc.stream.firstWhere(
      (s) => s.status == HomeDashboardStatus.failure,
    );
    expect(failure.driver, isNull);
    expect(failure.errorMessage, 'stats failed');
    await bloc.close();
  });

  test('4. cache hit — a populated cache skips the network', () async {
    final remote = _FakeRemote();
    final local = MockHomeDashboardLocalDataSource();
    final repo = HomeDashboardRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );

    final first = await repo.getDriverProfile();
    expect(first.isRight(), isTrue);
    expect(remote.profileCalls, 1);

    final second = await repo.getDriverProfile();
    expect(second.isRight(), isTrue);
    expect(remote.profileCalls, 1, reason: 'served from cache');
  });

  test('5. empty state — no rides is still a success', () async {
    final bloc = _bloc(_FakeRemote(emptyRides: true));
    bloc.add(const HomeDashboardInitialized());
    final success = await bloc.stream.firstWhere(
      (s) => s.status == HomeDashboardStatus.success,
    );
    expect(success.rides, isEmpty);
    await bloc.close();
  });

  test('6. status change — toggle is optimistic and revertible', () async {
    final remote = _FakeRemote(status: DriverStatus.offline);
    final repo = HomeDashboardRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: MockHomeDashboardLocalDataSource(),
    );
    final cubit = DriverStatusCubit(
      getCurrentStatus: GetCurrentStatusUseCase(repo),
      updateDriverStatus: UpdateDriverStatusUseCase(repo),
    );

    await cubit.load();
    expect(cubit.state.status?.status, DriverStatus.offline);

    await cubit.update(DriverStatus.online);
    expect(cubit.state.status?.status, DriverStatus.online);
    expect(cubit.state.isUpdating, isFalse);
    expect(cubit.state.errorMessage, isNull);

    await cubit.close();
  });

  test('7. refresh cycle — periodic timer re-fetches until closed', () async {
    final remote = _FakeRemote();
    final bloc = _bloc(remote, refreshInterval: const Duration(milliseconds: 40));

    var refreshes = 0;
    final sub = bloc.stream.listen((s) {
      if (s.isRefreshing) refreshes++;
    });

    bloc.add(const HomeDashboardInitialized());
    await bloc.stream.firstWhere(
      (s) => s.status == HomeDashboardStatus.success,
    );

    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(refreshes, greaterThan(0), reason: 'timer triggered refreshes');

    await bloc.close();
    final seen = refreshes;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(refreshes, seen, reason: 'timer cancelled on close');
    await sub.cancel();
  });
}
