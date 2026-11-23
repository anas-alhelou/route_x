// lib/features/settings/data/repositories/settings_repository_impl.dart
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/nearby_fleet_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({required this.localDataSource});

  final SettingsLocalDataSource localDataSource;

  @override
  Future<DriverProfileEntity> getProfile() => localDataSource.getProfile();

  @override
  Future<DriverProfileEntity> updateProfile(DriverProfileEntity profile) =>
      localDataSource.updateProfile(profile);

  @override
  Future<void> logout() => localDataSource.logout();

  @override
  Future<List<NearbyFleetEntity>> getNearbyFleets() =>
      localDataSource.getNearbyFleets();

  @override
  Future<NearbyFleetEntity?> findFleetByCode(String code) =>
      localDataSource.findFleetByCode(code);

  @override
  Future<void> sendJoinRequest(String fleetId) =>
      localDataSource.sendJoinRequest(fleetId);

  @override
  Future<void> cancelJoinRequest(String fleetId) =>
      localDataSource.cancelJoinRequest(fleetId);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      localDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> sendPasswordResetCode(String email) =>
      localDataSource.sendPasswordResetCode(email);

  @override
  Future<bool> verifyPasswordResetCode({required String email, required String code}) =>
      localDataSource.verifyPasswordResetCode(email: email, code: code);

  @override
  Future<void> resetPassword({required String email, required String newPassword}) =>
      localDataSource.resetPassword(email: email, newPassword: newPassword);

  @override
  Future<String> sendProblemReport({
    required String category,
    required String description,
    required List<String> screenshotPaths,
    required bool includeDeviceDetails,
  }) =>
      localDataSource.sendProblemReport(
        category: category,
        description: description,
        screenshotPaths: screenshotPaths,
        includeDeviceDetails: includeDeviceDetails,
      );
}
