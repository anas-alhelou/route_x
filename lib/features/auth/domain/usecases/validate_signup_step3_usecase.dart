// lib/features/auth/domain/usecases/validate_signup_step3_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';

/// Input for [ValidateSignupStep3UseCase]: only the candidate password.
class ValidateSignupStep3Params {
  const ValidateSignupStep3Params({required this.password});

  /// Password to validate against the strong-password rules.
  final String password;
}

/// Pure usecase for Step 3 password validation (Defense in depth).
class ValidateSignupStep3UseCase {
  const ValidateSignupStep3UseCase();

  Future<Either<Failure, String>> call(ValidateSignupStep3Params params) async {
    final text = params.password;

    if (text.length < 8) {
      return Left(
        ValidationFailure('Password must be at least 8 characters long'),
      );
    }
    if (!text.contains(RegExp(r'[A-Z]'))) {
      return Left(
        ValidationFailure('Password must contain an uppercase letter'),
      );
    }
    if (!text.contains(RegExp(r'[0-9]'))) {
      return Left(ValidationFailure('Password must contain a number'));
    }
    if (!text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return Left(
        ValidationFailure('Password must contain a special character'),
      );
    }

    return Right(text);
  }
}
