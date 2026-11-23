// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/login_credentials.dart';
import 'package:routex_mobile/features/auth/domain/repositories/login_repository.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';

/// Input data for [LoginUseCase].
class LoginParams {
  const LoginParams({required this.email, required this.password});

  /// Email address entered by the user.
  final String email;

  /// Plain-text password entered by the user.
  final String password;
}

/// Orchestrates a single login attempt (Single Responsibility Principle).
///
/// 1. Validates raw input through pure domain validators.
/// 2. Constructs the [LoginCredentials] entity.
/// 3. Delegates authentication to the injected [LoginRepository].
class LoginUseCase {
  const LoginUseCase({required this.repository});

  final LoginRepository repository;

  Future<Either<Failure, AuthSessionEntity>> call(LoginParams params) async {
    final emailError = AuthValidators.validateEmail(params.email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    final passwordError = AuthValidators.validateLoginPassword(params.password);
    if (passwordError != null) return Left(ValidationFailure(passwordError));

    final credentials = LoginCredentials(
      email: params.email.trim(),
      password: params.password,
    );

    return repository.login(credentials);
  }
}
