// lib/features/auth/domain/usecases/validate_signup_step1_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/entities/signup_credentials.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';

/// Parameters for [ValidateSignupStep1UseCase].
class ValidateSignupStep1Params {
  const ValidateSignupStep1Params({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.phoneCountryIsoCode = '',
  });

  /// First name entered on step 1.
  final String firstName;

  /// Last name entered on step 1.
  final String lastName;

  /// Email address entered on step 1.
  final String email;

  /// National phone number as typed on step 1, e.g. `0599114453`.
  ///
  /// Kept national rather than E.164 because it is validated against
  /// [phoneCountryIsoCode]: the two halves only make sense together.
  final String phone;

  /// ISO 3166-1 alpha-2 code of the country picked in the dial-code dropdown.
  final String phoneCountryIsoCode;
}

/// UseCase responsible for the final submission of Step 1.
///
/// It runs the raw inputs through the pure domain validators.
/// If valid, it constructs the [SignupCredentials] entity and persists
/// it into the injected [AuthRepository], returning the entity on success.
class ValidateSignupStep1UseCase {
  const ValidateSignupStep1UseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, SignupCredentials>> call(
    ValidateSignupStep1Params params,
  ) async {
    // 1. Domain Validation
    final nameError = AuthValidators.validateFirstName(params.firstName);
    if (nameError != null) return Left(ValidationFailure(nameError));

    final lastNameError = AuthValidators.validateLastName(params.lastName);
    if (lastNameError != null) return Left(ValidationFailure(lastNameError));

    final emailError = AuthValidators.validateEmail(params.email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    final phoneError = AuthValidators.validateInternationalPhone(
      params.phoneCountryIsoCode,
      params.phone,
    );
    if (phoneError != null) return Left(ValidationFailure(phoneError));

    // 2. Normalize once, here, so the rest of the flow only ever handles
    // E.164. The validator above already proved the number is a real mobile
    // number, so a null result here is unreachable in practice — but it is
    // still checked rather than assumed, because `phone` is what gets sent.
    final e164 = AuthValidators.toE164(
      params.phoneCountryIsoCode,
      params.phone,
    );
    if (e164 == null) return Left(ValidationFailure('errPhoneInvalid'));

    final country = AuthValidators.resolvePhoneCountry(
      params.phoneCountryIsoCode,
    );
    if (country == null) return Left(ValidationFailure('errPhoneInvalid'));

    // 3. Entity Construction
    final credentials = SignupCredentials(
      firstName: params.firstName.trim(),
      lastName: params.lastName.trim(),
      email: params.email.trim(),
      phone: e164,
      phoneCountryIsoCode: country.isoCode,
      phoneCountryDialCode: country.dialCode,
      countryName: country.apiName,
    );

    // 4. Delegate to Repository to persist across screens
    final cacheResult = await repository.cacheSignupCredentials(credentials);

    // 5. Return result
    return cacheResult.fold(
      (failure) => Left(failure),
      (_) => Right(credentials),
    );
  }
}
