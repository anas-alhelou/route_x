// lib/features/auth/domain/usecases/verify_otp_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';

/// Input for [VerifyOtpUseCase].
class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}

/// Verifies the emailed OTP and, on success, activates the account and
/// returns a fully persisted session (Single Responsibility Principle).
class VerifyOtpUseCase {
  const VerifyOtpUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, AuthSessionEntity>> call(
    VerifyOtpParams params,
  ) async {
    final emailError = AuthValidators.validateEmail(params.email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    final otpError = AuthValidators.validateOtp(params.otp);
    if (otpError != null) return Left(ValidationFailure(otpError));

    return repository.verifyOtp(email: params.email.trim(), otp: params.otp);
  }
}
