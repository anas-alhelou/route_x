// lib/features/settings/domain/usecases/reset_forgotten_password_usecase.dart
import '../repositories/settings_repository.dart';

/// Sets [newPassword] once the reset code for [email] has been verified.
class ResetForgottenPasswordUseCase {
  const ResetForgottenPasswordUseCase(this._repository);
  final SettingsRepository _repository;

  Future<void> call({required String email, required String newPassword}) =>
      _repository.resetPassword(email: email, newPassword: newPassword);
}
