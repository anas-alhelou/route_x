// lib/features/home/domain/usecases/join_find_fleet_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/repositories/find_fleet_repository.dart';

/// Joins a fleet from the Find a Fleet screen.
///
/// Thin wrapper over [FindFleetRepository.joinFleet] so the bloc depends on a
/// use case rather than a repository directly, matching the auth/home pattern.
class JoinFindFleetUseCase implements UseCase<void, JoinFindFleetParams> {
  const JoinFindFleetUseCase({required this.repository});

  final FindFleetRepository repository;

  @override
  Future<Either<Failure, void>> call(JoinFindFleetParams params) {
    return repository.joinFleet(fleetId: params.fleetId);
  }
}

/// Parameters for [JoinFindFleetUseCase].
class JoinFindFleetParams extends Equatable {
  const JoinFindFleetParams({required this.fleetId});

  final String fleetId;

  @override
  List<Object?> get props => [fleetId];
}
