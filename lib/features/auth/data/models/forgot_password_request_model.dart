// lib/features/auth/data/models/forgot_password_request_model.dart

/// Body for `POST /auth/forgot-password`.
class ForgotPasswordRequestModel {
  const ForgotPasswordRequestModel({required this.email});

  final String email;

  /// Serializes the request body for `POST /auth/forgot-password`.
  Map<String, dynamic> toJson() => {'email': email};
}
