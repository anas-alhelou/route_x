// lib/features/route_fleet/domain/usecases/update_stop_status_usecase.dart
import '../entities/fleet_info.dart';
import '../repositories/route_fleet_repository.dart';

class UpdateStopStatusUseCase {
  const UpdateStopStatusUseCase(this._repository);
  final RouteFleetRepository _repository;

  Future<FleetInfo> call(String stopId, bool isCompleted) =>
      _repository.updateStopStatus(stopId, isCompleted);
}
