// lib/features/home/data/repositories/home_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/data/datasources/home_local_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_repository.dart';

/// Binds [HomeRepository] to [HomeLocalDataSource].
///
/// Implements Dependency Inversion: the domain declares what it needs, the data
/// layer supplies it, and neither imports the other upwards. A remote
/// implementation can be added later without a single change above this line.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.localDataSource});

  final HomeLocalDataSource localDataSource;

  @override
  Future<Either<Failure, HomeOverview>> getHomeOverview() {
    return localDataSource.getHomeOverview();
  }

  @override
  Future<Either<Failure, DriverAvailability>> setOnlineStatus({
    required bool isOnline,
  }) {
    return localDataSource.setOnlineStatus(isOnline: isOnline);
  }

  @override
  Future<Either<Failure, HomeOverview>> joinFleet({required String fleetId}) {
    return localDataSource.joinFleet(fleetId: fleetId);
  }
}
