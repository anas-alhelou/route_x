// lib/features/home/domain/usecases/get_current_location_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/location_entity.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_dashboard_repository.dart';

/// Gets current location.
class GetCurrentLocationUseCase {
  const GetCurrentLocationUseCase(this.repository);

  final HomeDashboardRepository repository;

  Future<Either<Failure, LocationEntity>> call() {
    return repository.getCurrentLocation();
  }
}
