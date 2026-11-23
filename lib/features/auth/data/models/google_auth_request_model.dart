// lib/features/auth/data/models/google_auth_request_model.dart

/// Body for `POST /auth/google`.
///
/// [vehicleType] and [vehicleNumber] are optional: the first attempt carries
/// only the identity (token, platform, push token when available) so the
/// backend can report a brand-new account, and the vehicle fields are added by
/// the second attempt — the one that registers that account. They are omitted
/// from the body entirely when null, because an explicit `null` is not the
/// same as an absent field to the endpoint's validation.
class GoogleAuthRequestModel {
  const GoogleAuthRequestModel({
    required this.idToken,
    required this.platform,
    this.vehicleType,
    this.vehicleNumber,
    this.fcmToken,
  });

  final String idToken;

  /// Only `MOBILE` is confirmed by the backend sample.
  final String platform;

  /// Backend enum value (`BIKE`, `CAR`, `VAN`, `TRUCK`); `null` when the
  /// vehicle step has not run yet.
  final String? vehicleType;

  /// Plate number; `null` when the vehicle step has not run yet.
  final String? vehicleNumber;
  final String? fcmToken;

  /// Serializes the request body for `POST /auth/google`, omitting the push
  /// token when it is not available and the vehicle fields when the attempt
  /// does not carry them.
  Map<String, dynamic> toJson() => {
    'idToken': idToken,
    'platform': platform,
    if (fcmToken != null && fcmToken!.isNotEmpty) 'fcmToken': fcmToken,
    if (vehicleType != null) 'vehicleType': vehicleType,
    if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
  };
}
