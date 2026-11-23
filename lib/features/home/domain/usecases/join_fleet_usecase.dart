// lib/features/home/domain/usecases/join_fleet_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_repository.dart';

/// Input for [JoinFleetUseCase].
class JoinFleetParams {
  const JoinFleetParams({required this.fleetId});

  /// Id of the fleet the driver asked to join.
  final String fleetId;
}

/// Records a join request for a fleet shown on Home.
///
/// Returns the whole refreshed [HomeOverview] rather than the fleet alone
/// because joining advances the setup checklist and the header switch lock in
/// the same operation; handing back only the fleet would leave the caller with
/// no way to render that without a second fetch.
class JoinFleetUseCase implements UseCase<HomeOverview, JoinFleetParams> {
  const JoinFleetUseCase({required this.repository});

  final HomeRepository repository;

  @override
  Future<Either<Failure, HomeOverview>> call(JoinFleetParams params) {
    return repository.joinFleet(fleetId: params.fleetId);
  }
}
