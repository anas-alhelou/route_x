// lib/features/settings/data/datasources/settings_local_data_source.dart
import '../models/driver_profile_model.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/nearby_fleet_entity.dart';
import '../../domain/entities/profile_update_exception.dart';

abstract class SettingsLocalDataSource {
  Future<DriverProfileModel> getProfile();
  Future<DriverProfileModel> updateProfile(DriverProfileEntity profile);
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

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl();

  DriverProfileModel _profile = DriverProfileModel(
    name: 'Hamza Barakat',
    email: 'hamza.barakat@gmail.com',
    phone: '+966 55 000 0000',
    vehicleType: 'van',
    vehicleNumber: 'PAL-99488',
    rating: 4.92,
    isNotificationsEnabled: true,
    loadCapacityKg: 400,
    companyName: 'Red Sea Express',
    companyJoinedAt: DateTime(2026, 10, 6),
    companyCode: 'RSX482',
    companyPhone: '+966 12 600 4400',
    companyEmail: 'drivers@redsea.express',
    vehicleModel: 'Toyota Hiace',
    vehicleColour: 'White',
    avoidTolls: true,
    avoidUnpaved: true,
    quietHoursEnabled: true,
  );

  @override
  Future<DriverProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _profile;
  }

  /// Emails that belong to other accounts in this mock, so the "already used"
  /// path of the edit screen can be exercised until the real API is wired.
  static const _takenEmails = {'hamza.barakat@mail.com', 'driver@routex.com'};

  @override
  Future<DriverProfileModel> updateProfile(DriverProfileEntity profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final email = profile.email.trim().toLowerCase();
    if (email != _profile.email.toLowerCase() && _takenEmails.contains(email)) {
      throw const ProfileUpdateException(
        fieldErrors: {ProfileField.email: 'errEmailTaken'},
      );
    }
    _profile = DriverProfileModel.fromEntity(profile);
    return _profile;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulated logout clear
  }

  static const _fleets = [
    NearbyFleetEntity(id: 'red-sea-express', name: 'Red Sea Express', area: 'Al Hamra', distanceKm: 1.2),
    NearbyFleetEntity(id: 'ktn-wears', name: 'KTN Wears', area: 'Al Rawdah', distanceKm: 2.6),
    NearbyFleetEntity(id: 'dridies', name: 'Dridies Dry Fruits', area: 'Al Kaakah', distanceKm: 3.9),
  ];

  /// Mock join codes until the API provides them.
  static const _fleetIdByCode = {
    'RSX482': 'red-sea-express',
    'KTN260': 'ktn-wears',
    'DRF390': 'dridies',
  };

  @override
  Future<List<NearbyFleetEntity>> getNearbyFleets() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _fleets;
  }

  @override
  Future<NearbyFleetEntity?> findFleetByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = _fleetIdByCode[code];
    if (id == null) return null;
    return _fleets.firstWhere((fleet) => fleet.id == id);
  }

  @override
  Future<void> sendJoinRequest(String fleetId) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> cancelJoinRequest(String fleetId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Mock: accepted as-is until the API exposes a change-password endpoint.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// The only code the mock accepts, so the wrong-code screen can be tried
  /// with anything else.
  static const mockResetCode = '123456';

  @override
  Future<void> sendPasswordResetCode(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return code == mockResetCode;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<String> sendProblemReport({
    required String category,
    required String description,
    required List<String> screenshotPaths,
    required bool includeDeviceDetails,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Mock reference; the API will return the real one.
    final number = DateTime.now().millisecondsSinceEpoch % 9000 + 1000;
    return 'RPT-$number';
  }
}
