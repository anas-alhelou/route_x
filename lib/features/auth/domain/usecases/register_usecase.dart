// lib/features/auth/domain/usecases/register_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/entities/register_params.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';

/// Orchestrates a registration request (Single Responsibility Principle).
///
/// 1. Validates raw input through pure domain validators.
/// 2. Delegates the request to the injected [AuthRepository].
///
/// NOTE: registration does NOT log the user in â€” the backend activates the
/// account only after the OTP is verified, which is a separate call.
class RegisterUseCase {
  const RegisterUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, void>> call(RegisterParams params) async {
    // The API takes the name in two parts, so each is validated on its own.
    final firstNameError = AuthValidators.validateFirstName(params.firstName);
    if (firstNameError != null) {
      return Left(ValidationFailure(firstNameError));
    }

    final lastNameError = AuthValidators.validateLastName(params.lastName);
    if (lastNameError != null) {
      return Left(ValidationFailure(lastNameError));
    }

    final emailError = AuthValidators.validateEmail(params.email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    // The phone is already normalized to E.164 by the signup flow, but it is
    // re-checked here rather than trusted: this is the last gate before the
    // value leaves the device, and the domain is the only layer that can
    // guarantee it without knowing anything about the UI.
    final phoneError = AuthValidators.validateInternationalPhone(
      params.phoneCountryIsoCode,
      params.phone,
    );
    if (phoneError != null) return Left(ValidationFailure(phoneError));

    final passwordError = AuthValidators.validateStrongPassword(
      params.password,
    );
    if (passwordError != null) return Left(ValidationFailure(passwordError));

    return repository.register(params);
  }
}
