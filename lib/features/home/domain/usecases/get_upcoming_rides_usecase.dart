// lib/features/home/domain/usecases/get_upcoming_rides_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_dashboard_repository.dart';

/// Gets upcoming rides.
class GetUpcomingRidesUseCase {
  const GetUpcomingRidesUseCase(this.repository);

  final HomeDashboardRepository repository;

  Future<Either<Failure, List<UpcomingRideEntity>>> call() {
    return repository.getUpcomingRides();
  }
}
