import 'package:equatable/equatable.dart';

class DeviceSetupEntity extends Equatable {
  final bool locationGranted;
  final bool notificationGranted;
  final bool galleryGranted;
  final String? fcmToken;

  const DeviceSetupEntity({
    required this.locationGranted,
    required this.notificationGranted,
    required this.galleryGranted,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [locationGranted, notificationGranted, galleryGranted, fcmToken];
}
