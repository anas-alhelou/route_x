// lib/features/auth/data/models/register_response_model.dart
import 'user_model.dart';

/// Parsed success response for `POST /auth/register`.
///
/// Registering does **not** sign the user in: the account is created inactive
/// and no tokens are returned until the emailed OTP is verified, so this model
/// deliberately carries no `accessToken` / `refreshToken`.
///
/// ```json
/// { "success": true,
///   "data": { "message": "Registration successful",
///             "user": { "id": "...", "firstName": "...", "lastName": "...",
///                       "email": "...", "role": "DRIVER", "isActive": false } },
///   "timestamp": "..." }
/// ```
class RegisterResponseModel {
  const RegisterResponseModel({required this.message, required this.user});

  /// Human-readable confirmation, e.g. "Verification code sent to your email".
  final String message;

  /// The freshly created (still inactive) account.
  final UserModel user;

  /// Parses the `data` object of a register response.
  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw FormatException('Missing `user` in the register response: $json');
    }

    return RegisterResponseModel(
      message: json['message'] as String? ?? '',
      user: UserModel.fromJson(userJson),
    );
  }
}
