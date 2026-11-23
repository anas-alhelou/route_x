// lib/features/auth/domain/entities/vehicle_type.dart

/// Vehicle types accepted by the backend.
///
/// The [wireValue]s are the literals the API's `RegisterDto.vehicleType` enum
/// accepts: `["BIKE", "CAR", "VAN", "TRUCK"]` (see the published OpenAPI
/// schema). Note `BIKE`, not "MOTORCYCLE" — the client label is "Motorcycle"
/// but the wire value is `BIKE`.
enum VehicleType {
  motorcycle('BIKE'),
  car('CAR'),
  van('VAN'),
  truck('TRUCK');

  const VehicleType(this.wireValue);

  /// Serialized value sent to / received from the backend.
  final String wireValue;

  /// Maps a backend string to an enum, or `null` when unknown.
  static VehicleType? fromWire(String? value) {
    if (value != null) {
      for (final type in VehicleType.values) {
        if (type.wireValue == value) return type;
      }
    }
    return null;
  }

  /// Maps the lowercase keys used by the local vehicle selector
  /// (`car`, `van`, `motorcycle`, `truck`) to the backend's enum.
  static VehicleType? fromDisplayKey(String? displayKey) {
    switch (displayKey) {
      case 'motorcycle':
        return VehicleType.motorcycle;
      case 'car':
        return VehicleType.car;
      case 'van':
        return VehicleType.van;
      case 'truck':
        return VehicleType.truck;
      default:
        return null;
    }
  }
}
