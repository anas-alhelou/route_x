// lib/features/home/domain/repositories/delivery_dashboard_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

/// Contract for fetching and transitioning delivery dashboard states.
abstract class DeliveryDashboardRepository {
  /// Fetches the delivery dashboard snapshot.
  ///
  /// If [scenario] is supplied, returns the mock/live snapshot for that specific
  /// state (e.g. [DeliveryScenario.onRoute], [DeliveryScenario.allCaughtUp],
  /// [DeliveryScenario.firstDay], [DeliveryScenario.noOrdersToday]).
  Future<Either<Failure, DeliveryDashboard>> getDeliveryDashboard({
    DeliveryScenario? scenario,
  });

  /// Switches active scenario and returns the updated dashboard.
  Future<Either<Failure, DeliveryDashboard>> switchScenario(
    DeliveryScenario scenario,
  );
}
