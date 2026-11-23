// lib/features/settings/domain/usecases/find_fleet_by_code_usecase.dart
import '../entities/nearby_fleet_entity.dart';
import '../repositories/settings_repository.dart';

/// Resolves a fleet join code; `null` when no fleet uses it.
class FindFleetByCodeUseCase {
  const FindFleetByCodeUseCase(this._repository);
  final SettingsRepository _repository;

  Future<NearbyFleetEntity?> call(String code) =>
      _repository.findFleetByCode(code.trim().toUpperCase());
}
