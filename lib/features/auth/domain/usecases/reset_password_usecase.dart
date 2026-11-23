// lib/features/auth/domain/usecases/reset_password_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';

/// Input for [ResetPasswordUseCase].
class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.resetToken,
    required this.newPassword,
  });

  final String resetToken;
  final String newPassword;

  @override
  List<Object?> get props => [resetToken, newPassword];
}

/// Sets a new password using the emailed reset token (Single Responsibility
/// Principle). The new password must satisfy the same strong-password rule as
/// registration.
class ResetPasswordUseCase {
  const ResetPasswordUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    if (params.resetToken.trim().isEmpty) {
      return const Left(ValidationFailure('errResetTokenRequired'));
    }

    final passwordError = AuthValidators.validateStrongPassword(
      params.newPassword,
    );
    if (passwordError != null) return Left(ValidationFailure(passwordError));

    return repository.resetPassword(
      resetToken: params.resetToken.trim(),
      newPassword: params.newPassword,
    );
  }
}
