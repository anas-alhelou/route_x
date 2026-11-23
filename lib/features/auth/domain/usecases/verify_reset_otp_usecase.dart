import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';

/// Parameters submitted to the forgot-password OTP verification endpoint.
class VerifyResetOtpParams extends Equatable {
  const VerifyResetOtpParams({required this.email, required this.otp});

  /// Email address that received the reset code.
  final String email;

  /// Six-digit code received in the reset email.
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}

/// Verifies a forgot-password OTP and returns the backend reset token.
class VerifyResetOtpUseCase {
  const VerifyResetOtpUseCase({required this.repository});

  /// Auth repository used for the backend request.
  final AuthRepository repository;

  /// Validates the input and verifies the code without creating a session.
  Future<Either<Failure, String>> call(VerifyResetOtpParams params) async {
    final emailError = AuthValidators.validateEmail(params.email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    final otpError = AuthValidators.validateOtp(params.otp);
    if (otpError != null) return Left(ValidationFailure(otpError));

    return repository.verifyResetOtp(
      email: params.email.trim(),
      otp: params.otp,
    );
  }
}
