// lib/features/home/domain/entities/driver_profile.dart
import 'package:equatable/equatable.dart';

/// The signed-in driver as shown in the Home header.
///
/// [avatarPath] is an asset path rather than a URL on purpose: while Home runs
/// on the local data source the avatar is a bundled placeholder, and the real
/// backend will hand back a remote URL that the widget layer resolves the same
/// way. Keeping it a plain string here means the swap needs no change to this
/// entity, the bloc or the use cases.
class DriverProfile extends Equatable {
  const DriverProfile({required this.displayName, required this.avatarPath});

  /// Full name shown under the greeting ("Hamza Barakat").
  final String displayName;

  /// Asset path or URL of the driver's profile picture.
  final String avatarPath;

  @override
  List<Object?> get props => [displayName, avatarPath];
}
