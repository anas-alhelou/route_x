// lib/features/home/domain/usecases/get_fleets_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/domain/repositories/find_fleet_repository.dart';

/// Loads fleets for the Find a Fleet screen, with optional filtering.
///
/// Thin wrapper over [FindFleetRepository.getFleets] so the bloc depends on a
/// use case rather than a repository directly, matching the auth pattern.
class GetFleetsUseCase implements UseCase<List<FleetSummary>, GetFleetsParams> {
  const GetFleetsUseCase({required this.repository});

  final FindFleetRepository repository;

  @override
  Future<Either<Failure, List<FleetSummary>>> call(GetFleetsParams params) {
    return repository.getFleets(filter: params.filter, query: params.query);
  }
}

/// Parameters for [GetFleetsUseCase].
class GetFleetsParams extends Equatable {
  const GetFleetsParams({this.filter = FleetFilter.all, this.query = ''});

  final FleetFilter filter;
  final String query;

  @override
  List<Object?> get props => [filter, query];
}
