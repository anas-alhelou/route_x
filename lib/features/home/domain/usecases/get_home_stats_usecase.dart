// lib/features/home/domain/usecases/get_home_stats_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_dashboard_repository.dart';

/// Gets home statistics.
class GetHomeStatsUseCase {
  const GetHomeStatsUseCase(this.repository);

  final HomeDashboardRepository repository;

  Future<Either<Failure, HomeStatsEntity>> call() {
    return repository.getHomeStats();
  }
}
