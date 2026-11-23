// lib/features/settings/domain/usecases/update_profile_usecase.dart
import '../entities/driver_profile_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final SettingsRepository _repository;

  Future<DriverProfileEntity> call(DriverProfileEntity profile) =>
      _repository.updateProfile(profile);
}
