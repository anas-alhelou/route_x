// lib/features/home/data/models/driver_profile_model.dart
import 'package:routex_mobile/features/home/domain/entities/driver_profile.dart';

/// Data-layer shape of a [DriverProfile].
///
/// Wrapping every entity in a model that only forwards its fields buys nothing
/// while the source is local, but it is the seam the JSON mapping will grow
/// into once the remote source lands, and it keeps `fromJson` out of the domain
/// where it does not belong.
class DriverProfileModel extends DriverProfile {
  const DriverProfileModel({
    required super.displayName,
    required super.avatarPath,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      displayName: json['displayName'] as String,
      avatarPath: json['avatarPath'] as String,
    );
  }
}
