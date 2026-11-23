// lib/features/route_fleet/domain/usecases/get_active_route_usecase.dart
import '../entities/fleet_info.dart';
import '../repositories/route_fleet_repository.dart';

class GetActiveRouteUseCase {
  const GetActiveRouteUseCase(this._repository);
  final RouteFleetRepository _repository;

  Future<FleetInfo> call() => _repository.getActiveRoute();
}
