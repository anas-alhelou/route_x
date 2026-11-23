// lib/features/home/data/repositories/home_debug_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/data/datasources/home_debug_local_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_debug_repository.dart';

/// Passes the Home debug transitions through to [HomeDebugLocalDataSource].
///
/// No mapping and no error translation: the local source already speaks
/// `Either<Failure, T>`, so re-wrapping its result would add a layer that can only
/// lose information.
class HomeDebugRepositoryImpl implements HomeDebugRepository {
  const HomeDebugRepositoryImpl({required HomeDebugLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final HomeDebugLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, HomeOverview>> resolveRequest({
    required FleetRequestStatus status,
    String? reason,
  }) {
    return _localDataSource.resolveRequest(status: status, reason: reason);
  }
}
