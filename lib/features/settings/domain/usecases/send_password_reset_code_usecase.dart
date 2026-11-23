// lib/features/settings/domain/usecases/send_password_reset_code_usecase.dart
import '../repositories/settings_repository.dart';

/// Emails a 6-digit password reset code to [email].
class SendPasswordResetCodeUseCase {
  const SendPasswordResetCodeUseCase(this._repository);
  final SettingsRepository _repository;

  Future<void> call(String email) => _repository.sendPasswordResetCode(email.trim());
}
