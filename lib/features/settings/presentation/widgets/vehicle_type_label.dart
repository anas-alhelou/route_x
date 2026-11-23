// lib/features/settings/presentation/widgets/vehicle_type_label.dart
import 'package:flutter/widgets.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';

/// Display helpers for the vehicle type keys stored on the profile
/// (`motorcycle`, `car`, `van`, `truck`, as produced by the sign-up selector).
extension VehicleTypeLabel on BuildContext {
  /// Localized name of [key]; unknown keys are shown as-is.
  String vehicleTypeLabel(String key) => switch (key) {
        'motorcycle' => tr.vehicleMotorcycle,
        'car' => tr.vehicleCar,
        'van' => tr.vehicleVan,
        'truck' => tr.vehicleTruck,
        _ => key,
      };
}

/// Icon asset for a vehicle type key, defaulting to the van.
SvgGenImage vehicleTypeIcon(String key) => switch (key) {
      'motorcycle' => Assets.icons.svg.icMotorcycle,
      'car' => Assets.icons.svg.icCar,
      'truck' => Assets.icons.svg.icTruck,
      _ => Assets.icons.svg.icVan,
    };
