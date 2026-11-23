// lib/features/auth/domain/entities/user_role.dart

/// Account role used across the platform.
///
/// Typed rather than a raw string so a future `ADMIN`/`CUSTOMER` role only
/// touches this enum (Open/Closed).
enum UserRole {
  customer('CUSTOMER'),
  driver('DRIVER');

  const UserRole(this.wireValue);

  /// Serialized value sent to / received from the backend.
  final String wireValue;

  /// Maps a backend string to an enum, defaulting to [UserRole.customer] when
  /// the value is unknown (forward-compatible with new roles).
  static UserRole fromWire(String? value) {
    if (value != null) {
      for (final role in UserRole.values) {
        if (role.wireValue == value) return role;
      }
    }
    return UserRole.customer;
  }
}
