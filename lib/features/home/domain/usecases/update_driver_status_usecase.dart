// lib/features/home/domain/usecases/update_driver_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_dashboard_repository.dart';

/// Updates driver status.
class UpdateDriverStatusUseCase {
  const UpdateDriverStatusUseCase(this.repository);

  final HomeDashboardRepository repository;

  Future<Either<Failure, DriverStatusEntity>> call({
    required DriverStatus status,
    Duration? onlineForDuration,
  }) {
    return repository.updateDriverStatus(
      status: status,
      onlineForDuration: onlineForDuration,
    );
  }
}
