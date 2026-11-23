// lib/features/auth/domain/entities/google_auth_params.dart
import 'vehicle_type.dart';

/// Everything `POST /auth/google` needs, gathered by the presentation layer.
///
/// The ID token is supplied by the caller instead of being obtained here: the
/// Google SDK has already run by the time these params exist (see
/// `GetGoogleIdTokenUseCase`), which is what lets the flow ask for the vehicle
/// details *before* the account is created and keeps the SDK to exactly one
/// call per attempt.
///
/// [vehicleType] and [vehicleNumber] are optional, and are omitted from the
/// body when absent: the first attempt sends only the token (plus the platform)
/// so the backend can tell an account that already exists — which answers with
/// a session right away — from a brand-new one, which answers with the
/// vehicle-required signal that opens the vehicle step. The vehicle fields ride
/// along only on that second attempt, the one that actually registers the new
/// identity, so an existing user's stored vehicle is never re-sent.
///
/// Deliberately a plain class rather than an `Equatable` one: `props`/`toString`
/// of a credential-carrying value must never be able to render the token.
class GoogleAuthParams {
  const GoogleAuthParams({
    required this.idToken,
    this.vehicleType,
    this.vehicleNumber,
    this.platform = mobilePlatform,
    this.fcmToken,
  });

  /// The only platform value the backend sample documents for this app.
  static const String mobilePlatform = 'MOBILE';

  /// ID token produced by the Google SDK, held in memory for one attempt.
  final String idToken;

  /// Vehicle type the user picked, sent as its wire value.
  ///
  /// `null` on the first attempt: nothing is known about the account yet.
  final VehicleType? vehicleType;

  /// Plate number the user typed, already trimmed and non-empty.
  ///
  /// `null` on the first attempt; only set once the vehicle step collected it.
  final String? vehicleNumber;

  /// `MOBILE` unless a caller explicitly targets another platform.
  final String platform;

  /// Push-notification token; omitted from the body when unavailable.
  final String? fcmToken;
}
