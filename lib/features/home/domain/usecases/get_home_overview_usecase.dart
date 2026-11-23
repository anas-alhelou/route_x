// lib/features/home/domain/usecases/get_home_overview_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_repository.dart';

/// Loads the whole Home dashboard in one call (Single Responsibility
/// Principle).
///
/// Takes no parameters: there is nothing for the caller to supply, so [NoParams]
/// keeps it on the same shape as every other use case in the project.
class GetHomeOverviewUseCase implements UseCase<HomeOverview, NoParams> {
  const GetHomeOverviewUseCase({required this.repository});

  final HomeRepository repository;

  @override
  Future<Either<Failure, HomeOverview>> call(NoParams params) {
    return repository.getHomeOverview();
  }
}
