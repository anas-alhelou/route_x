// lib/features/auth/data/models/verify_otp_request_model.dart

/// Body for `POST /auth/verify-otp`.
class VerifyOtpRequestModel {
  const VerifyOtpRequestModel({required this.email, required this.otp});

  final String email;
  final String otp;

  /// Serializes the request body for `POST /auth/verify-otp`.
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}
