// lib/features/settings/domain/usecases/change_password_usecase.dart
import '../repositories/settings_repository.dart';

/// Replaces the driver's password; the account email gets a confirmation.
class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);
  final SettingsRepository _repository;

  Future<void> call({required String currentPassword, required String newPassword}) =>
      _repository.changePassword(currentPassword: currentPassword, newPassword: newPassword);
}
