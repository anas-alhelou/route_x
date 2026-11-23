// lib/features/settings/domain/repositories/settings_repository.dart
import '../entities/driver_profile_entity.dart';
import '../entities/nearby_fleet_entity.dart';

abstract class SettingsRepository {
  Future<DriverProfileEntity> getProfile();
  Future<DriverProfileEntity> updateProfile(DriverProfileEntity profile);
  Future<void> logout();
  Future<List<NearbyFleetEntity>> getNearbyFleets();
  Future<NearbyFleetEntity?> findFleetByCode(String code);
  Future<void> sendJoinRequest(String fleetId);
  Future<void> cancelJoinRequest(String fleetId);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> sendPasswordResetCode(String email);
  Future<bool> verifyPasswordResetCode({required String email, required String code});
  Future<void> resetPassword({required String email, required String newPassword});
  Future<String> sendProblemReport({
    required String category,
    required String description,
    required List<String> screenshotPaths,
    required bool includeDeviceDetails,
  });
}
