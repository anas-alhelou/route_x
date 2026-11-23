// lib/features/home/domain/usecases/switch_delivery_scenario_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/home/domain/repositories/delivery_dashboard_repository.dart';

/// Transitions the delivery dashboard to a specific scenario (HM2, HM3, HM5, HM6).
class SwitchDeliveryScenarioUseCase {
  const SwitchDeliveryScenarioUseCase({required this.repository});

  final DeliveryDashboardRepository repository;

  Future<Either<Failure, DeliveryDashboard>> call(
    DeliveryScenario scenario,
  ) {
    return repository.switchScenario(scenario);
  }
}
