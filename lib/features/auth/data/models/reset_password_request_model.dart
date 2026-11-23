// lib/features/auth/data/models/reset_password_request_model.dart

/// Body for `POST /auth/reset-password`.
class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
  });

  final String resetToken;
  final String newPassword;

  /// Serializes the request body for `POST /auth/reset-password`.
  Map<String, dynamic> toJson() => {
    'resetToken': resetToken,
    'newPassword': newPassword,
  };
}
