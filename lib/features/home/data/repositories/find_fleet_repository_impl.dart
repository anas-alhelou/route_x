// lib/features/home/data/repositories/find_fleet_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/data/datasources/find_fleet_local_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/domain/repositories/find_fleet_repository.dart';

/// Binds [FindFleetRepository] to [FindFleetLocalDataSource].
class FindFleetRepositoryImpl implements FindFleetRepository {
  const FindFleetRepositoryImpl({required this.localDataSource});

  final FindFleetLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<FleetSummary>>> getFleets({
    FleetFilter filter = FleetFilter.all,
    String query = '',
  }) {
    return localDataSource.getFleets(filter: filter, query: query);
  }

  @override
  Future<Either<Failure, List<FleetFilter>>> getAvailableFilters() {
    return localDataSource.getAvailableFilters();
  }

  @override
  Future<Either<Failure, void>> joinFleet({required String fleetId}) {
    return localDataSource.joinFleet(fleetId: fleetId);
  }
}
