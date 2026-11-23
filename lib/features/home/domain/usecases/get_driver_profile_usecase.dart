// lib/features/home/domain/usecases/get_driver_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_dashboard_repository.dart';

/// Gets the driver profile.
class GetDriverProfileUseCase {
  const GetDriverProfileUseCase(this.repository);

  final HomeDashboardRepository repository;

  Future<Either<Failure, DriverEntity>> call() {
    return repository.getDriverProfile();
  }
}
