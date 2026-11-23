// lib/features/route_fleet/data/repositories/route_fleet_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import '../../domain/entities/fleet_company.dart';
import '../../domain/entities/fleet_info.dart';
import '../../domain/entities/location_report.dart';
import '../../domain/repositories/route_fleet_repository.dart';
import '../datasources/route_fleet_local_data_source.dart';
import '../datasources/route_fleet_remote_data_source.dart';

class RouteFleetRepositoryImpl implements RouteFleetRepository {
  const RouteFleetRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    ExceptionMapper exceptionMapper = const ExceptionMapper(),
  }) : _exceptionMapper = exceptionMapper;

  final RouteFleetLocalDataSource localDataSource;
  final RouteFleetRemoteDataSource remoteDataSource;
  final ExceptionMapper _exceptionMapper;

  @override
  Future<FleetInfo> getActiveRoute() => localDataSource.getActiveRoute();

  @override
  Future<FleetInfo> updateStopStatus(String stopId, bool isCompleted) =>
      localDataSource.updateStopStatus(stopId, isCompleted);

  @override
  Future<FleetInfo> reorderStopToLast(int stopIndex) =>
      localDataSource.reorderStopToLast(stopIndex);

  @override
  Future<void> reportWrongLocation(LocationReport report) =>
      localDataSource.reportWrongLocation(report);

  @override
  Future<Either<Failure, List<FleetCompany>>> searchFleets(String query) async {
    try {
      final models = await remoteDataSource.searchFleets(query);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e, st) {
      return Left(_exceptionMapper.map(e, st));
    }
  }

  @override
  Future<Either<Failure, String?>> joinFleet(String companyId) async {
    try {
      final companyName = await remoteDataSource.joinFleet(companyId);
      return Right(companyName);
    } catch (e, st) {
      return Left(_exceptionMapper.map(e, st));
    }
  }

  @override
  Future<Either<Failure, String?>> joinFleetByCode(String code) async {
    try {
      final companyName = await remoteDataSource.joinFleetByCode(code);
      return Right(companyName);
    } catch (e, st) {
      return Left(_exceptionMapper.map(e, st));
    }
  }
}
