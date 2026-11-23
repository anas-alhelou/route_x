// lib/features/settings/domain/usecases/get_profile_usecase.dart
import '../entities/driver_profile_entity.dart';
import '../repositories/settings_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);
  final SettingsRepository _repository;

  Future<DriverProfileEntity> call() => _repository.getProfile();
}
