// lib/features/home/domain/usecases/get_delivery_dashboard_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/home/domain/repositories/delivery_dashboard_repository.dart';

/// Fetches the current delivery dashboard snapshot for the active or requested scenario.
class GetDeliveryDashboardUseCase {
  const GetDeliveryDashboardUseCase({required this.repository});

  final DeliveryDashboardRepository repository;

  Future<Either<Failure, DeliveryDashboard>> call({
    DeliveryScenario? scenario,
  }) {
    return repository.getDeliveryDashboard(scenario: scenario);
  }
}
