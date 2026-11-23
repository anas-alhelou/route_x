// lib/features/settings/domain/entities/driver_profile_entity.dart
import 'package:equatable/equatable.dart';

class DriverProfileEntity extends Equatable {
  const DriverProfileEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.rating,
    required this.isNotificationsEnabled,
    this.photoPath,
    this.loadCapacityKg,
    this.companyName,
    this.companyJoinedAt,
    this.companyCode,
    this.companyLogoUrl,
    this.companyPhone,
    this.companyEmail,
    this.vehicleModel,
    this.vehicleColour,
    this.navigationApp = 'google_maps',
    this.avoidTolls = false,
    this.avoidHighways = false,
    this.avoidUnpaved = false,
    this.notifyNewRoutes = true,
    this.notifyOrderChanges = true,
    this.notifyDispatchMessages = true,
    this.notificationSound = true,
    this.notificationVibrate = true,
    this.quietHoursEnabled = false,
    this.quietHoursStartMinutes = 23 * 60,
    this.quietHoursEndMinutes = 7 * 60,
    this.quietHoursDays = const [1, 2, 3, 4, 5, 6, 7],
    this.locationAccess = 'always',
  });

  final String name;
  final String email;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;
  final double rating;
  final bool isNotificationsEnabled;

  /// Local path of the profile photo picked on this device, if any.
  final String? photoPath;

  /// How much the vehicle can carry, in kilograms, if the driver has set it.
  final int? loadCapacityKg;

  /// The delivery company the driver works for; it manages the vehicle.
  final String? companyName;

  /// When the driver joined [companyName].
  final DateTime? companyJoinedAt;

  /// Company code, logo and the contact the driver reaches it on.
  final String? companyCode;
  final String? companyLogoUrl;
  final String? companyPhone;
  final String? companyEmail;

  /// Vehicle details set by the company, e.g. `Toyota Hiace` and `White`.
  final String? vehicleModel;
  final String? vehicleColour;

  /// Key of the app opened by "Start navigation", e.g. `google_maps`.
  final String navigationApp;

  /// Route preferences: road kinds to plan around when possible.
  final bool avoidTolls;
  final bool avoidHighways;
  final bool avoidUnpaved;

  /// Notification preferences.
  final bool notifyNewRoutes;
  final bool notifyOrderChanges;
  final bool notifyDispatchMessages;
  final bool notificationSound;
  final bool notificationVibrate;

  /// Quiet hours window, as minutes after midnight (may wrap past midnight).
  final bool quietHoursEnabled;
  final int quietHoursStartMinutes;
  final int quietHoursEndMinutes;

  /// Days quiet hours repeat on, as [DateTime.weekday] values (1 = Monday).
  final List<int> quietHoursDays;

  /// Location sharing choice: `always`, `while_using` or `never`.
  final String locationAccess;

  DriverProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? vehicleType,
    String? vehicleNumber,
    bool? isNotificationsEnabled,
    String? photoPath,
    int? loadCapacityKg,
    String? companyName,
    DateTime? companyJoinedAt,
    String? companyCode,
    String? companyLogoUrl,
    String? companyPhone,
    String? companyEmail,
    String? vehicleModel,
    String? vehicleColour,
    String? navigationApp,
    bool? avoidTolls,
    bool? avoidHighways,
    bool? avoidUnpaved,
    bool? notifyNewRoutes,
    bool? notifyOrderChanges,
    bool? notifyDispatchMessages,
    bool? notificationSound,
    bool? notificationVibrate,
    bool? quietHoursEnabled,
    int? quietHoursStartMinutes,
    int? quietHoursEndMinutes,
    List<int>? quietHoursDays,
    String? locationAccess,
  }) {
    return DriverProfileEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rating: rating,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      photoPath: photoPath ?? this.photoPath,
      loadCapacityKg: loadCapacityKg ?? this.loadCapacityKg,
      companyName: companyName ?? this.companyName,
      companyJoinedAt: companyJoinedAt ?? this.companyJoinedAt,
      companyCode: companyCode ?? this.companyCode,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColour: vehicleColour ?? this.vehicleColour,
      navigationApp: navigationApp ?? this.navigationApp,
      avoidTolls: avoidTolls ?? this.avoidTolls,
      avoidHighways: avoidHighways ?? this.avoidHighways,
      avoidUnpaved: avoidUnpaved ?? this.avoidUnpaved,
      notifyNewRoutes: notifyNewRoutes ?? this.notifyNewRoutes,
      notifyOrderChanges: notifyOrderChanges ?? this.notifyOrderChanges,
      notifyDispatchMessages: notifyDispatchMessages ?? this.notifyDispatchMessages,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationVibrate: notificationVibrate ?? this.notificationVibrate,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStartMinutes: quietHoursStartMinutes ?? this.quietHoursStartMinutes,
      quietHoursEndMinutes: quietHoursEndMinutes ?? this.quietHoursEndMinutes,
      quietHoursDays: quietHoursDays ?? this.quietHoursDays,
      locationAccess: locationAccess ?? this.locationAccess,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        vehicleType,
        vehicleNumber,
        rating,
        isNotificationsEnabled,
        photoPath,
        loadCapacityKg,
        companyName,
        companyJoinedAt,
        companyCode,
        companyLogoUrl,
        companyPhone,
        companyEmail,
        vehicleModel,
        vehicleColour,
        navigationApp,
        avoidTolls,
        avoidHighways,
        avoidUnpaved,
        notifyNewRoutes,
        notifyOrderChanges,
        notifyDispatchMessages,
        notificationSound,
        notificationVibrate,
        quietHoursEnabled,
        quietHoursStartMinutes,
        quietHoursEndMinutes,
        quietHoursDays,
        locationAccess,
      ];
}
