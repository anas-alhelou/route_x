// lib/features/settings/domain/usecases/logout_usecase.dart
import '../repositories/settings_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final SettingsRepository _repository;

  Future<void> call() => _repository.logout();
}
