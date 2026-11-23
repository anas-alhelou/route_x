// lib/features/home/data/repositories/enter_fleet_code_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/data/datasources/enter_fleet_code_local_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/repositories/enter_fleet_code_repository.dart';

/// Local-data implementation of [EnterFleetCodeRepository].
///
/// A pass-through rather than a place for logic, and deliberately so: the whole
/// job of this screen is one lookup, and the seed already owns the rules (which
/// code is valid, what request it creates, where the pending request is stored).
/// Adding translation here would only give the seed a second place to be wrong.
///
/// Const-constructible so DI can hold it as a singleton — it holds no mutable
/// state of its own, and all shared state lives in the injected data source's
/// store.
class EnterFleetCodeRepositoryImpl implements EnterFleetCodeRepository {
  /// Creates the repository over [localDataSource].
  const EnterFleetCodeRepositoryImpl({required this.localDataSource});

  /// The seed backing this flow.
  final EnterFleetCodeLocalDataSource localDataSource;

  @override
  Future<Either<Failure, FleetRequest>> verifyFleetCode(String code) {
    return localDataSource.verifyFleetCode(code);
  }
}