// lib/features/settings/domain/usecases/verify_password_reset_code_usecase.dart
import '../repositories/settings_repository.dart';

/// Checks the reset [code] sent to [email]; `false` when it is wrong.
class VerifyPasswordResetCodeUseCase {
  const VerifyPasswordResetCodeUseCase(this._repository);
  final SettingsRepository _repository;

  Future<bool> call({required String email, required String code}) =>
      _repository.verifyPasswordResetCode(email: email, code: code);
}
