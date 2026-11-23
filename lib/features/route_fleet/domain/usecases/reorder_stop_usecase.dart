// lib/features/route_fleet/domain/usecases/reorder_stop_usecase.dart
import '../entities/fleet_info.dart';
import '../repositories/route_fleet_repository.dart';

class ReorderStopUseCase {
  const ReorderStopUseCase(this.repository);

  final RouteFleetRepository repository;

  Future<FleetInfo> call(int stopIndex) {
    return repository.reorderStopToLast(stopIndex);
  }
}
