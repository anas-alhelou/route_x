import '../../domain/entities/device_setup_entity.dart';

class DeviceSetupModel extends DeviceSetupEntity {
  const DeviceSetupModel({
    required super.locationGranted,
    required super.notificationGranted,
    required super.galleryGranted,
    super.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'location_granted': locationGranted,
      'notification_granted': notificationGranted,
      'gallery_granted': galleryGranted,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }

  factory DeviceSetupModel.fromEntity(DeviceSetupEntity entity) {
    return DeviceSetupModel(
      locationGranted: entity.locationGranted,
      notificationGranted: entity.notificationGranted,
      galleryGranted: entity.galleryGranted,
      fcmToken: entity.fcmToken,
    );
  }
}
