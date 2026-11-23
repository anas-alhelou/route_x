import 'package:routex_mobile/core/errors/exceptions.dart';

/// Parses the reset token returned by the forgot-password OTP endpoint.
class VerifyResetOtpResponseModel {
  const VerifyResetOtpResponseModel({required this.resetToken});

  /// The single-use token accepted by `POST /auth/reset-password`.
  final String resetToken;

  /// Builds a model from the unwrapped `/auth/verify-otp` response data.
  factory VerifyResetOtpResponseModel.fromJson(Map<String, dynamic> data) {
    final token = data['resetToken'];
    if (token is! String || token.trim().isEmpty) {
      throw IncompleteAuthResponseException(
        'Missing `resetToken` in the reset OTP response',
      );
    }
    return VerifyResetOtpResponseModel(resetToken: token);
  }
}
