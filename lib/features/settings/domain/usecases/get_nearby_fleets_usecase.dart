// lib/features/settings/domain/usecases/get_nearby_fleets_usecase.dart
import '../entities/nearby_fleet_entity.dart';
import '../repositories/settings_repository.dart';

class GetNearbyFleetsUseCase {
  const GetNearbyFleetsUseCase(this._repository);
  final SettingsRepository _repository;

  Future<List<NearbyFleetEntity>> call() => _repository.getNearbyFleets();
}
