// lib/features/home/domain/usecases/get_available_filters_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';
import 'package:routex_mobile/features/home/domain/repositories/find_fleet_repository.dart';

/// Returns the filter chips available on the Find a Fleet screen.
///
/// No parameters — the set of chips is static for now, but the use case keeps
/// the bloc from depending on the repository directly.
class GetAvailableFiltersUseCase
    implements UseCase<List<FleetFilter>, NoParams> {
  const GetAvailableFiltersUseCase({required this.repository});

  final FindFleetRepository repository;

  @override
  Future<Either<Failure, List<FleetFilter>>> call(NoParams params) {
    return repository.getAvailableFilters();
  }
}
