// lib/features/auth/domain/usecases/forgot_password_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';

/// Requests a password-reset token for [email] (Single Responsibility
/// Principle). The backend emails the reset code/token to the account.
class ForgotPasswordUseCase {
  const ForgotPasswordUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, void>> call(String email) async {
    final emailError = AuthValidators.validateEmail(email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    return repository.forgotPassword(email: email.trim());
  }
}
