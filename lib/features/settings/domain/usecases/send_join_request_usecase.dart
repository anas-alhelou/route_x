// lib/features/settings/domain/usecases/send_join_request_usecase.dart
import '../repositories/settings_repository.dart';

/// Asks the fleet with [fleetId] to accept the driver. The fleet reviews the
/// request before any route is assigned.
class SendJoinRequestUseCase {
  const SendJoinRequestUseCase(this._repository);
  final SettingsRepository _repository;

  Future<void> call(String fleetId) => _repository.sendJoinRequest(fleetId);
}
