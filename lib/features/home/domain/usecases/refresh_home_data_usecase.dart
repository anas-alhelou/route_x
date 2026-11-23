// lib/features/home/domain/usecases/refresh_home_data_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_dashboard_repository.dart';

/// Refreshes home data.
class RefreshHomeDataUseCase {
  const RefreshHomeDataUseCase(this.repository);

  final HomeDashboardRepository repository;

  Future<Either<Failure, void>> call() {
    return repository.refreshHomeData();
  }
}
