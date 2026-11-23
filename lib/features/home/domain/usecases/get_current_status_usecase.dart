// lib/features/home/domain/usecases/get_current_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_dashboard_repository.dart';

/// Gets current driver status.
class GetCurrentStatusUseCase {
  const GetCurrentStatusUseCase(this.repository);

  final HomeDashboardRepository repository;

  Future<Either<Failure, DriverStatusEntity>> call() {
    return repository.getCurrentStatus();
  }
}
