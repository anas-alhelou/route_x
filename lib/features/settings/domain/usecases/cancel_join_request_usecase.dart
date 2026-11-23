// lib/features/settings/domain/usecases/cancel_join_request_usecase.dart
import '../repositories/settings_repository.dart';

/// Withdraws a pending request to join the fleet with [fleetId].
class CancelJoinRequestUseCase {
  const CancelJoinRequestUseCase(this._repository);
  final SettingsRepository _repository;

  Future<void> call(String fleetId) => _repository.cancelJoinRequest(fleetId);
}
