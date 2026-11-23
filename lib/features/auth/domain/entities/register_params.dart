// lib/features/auth/domain/entities/register_params.dart
import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// Raw client data needed to register a new account.
///
/// The API takes the name as two discrete fields, so they are kept separate
/// here instead of being joined into a single `fullName`.
///
/// Vehicle details are deliberately absent: the company/fleet assigns a
/// vehicle to a driver after onboarding, so sign-up never sends one.
class RegisterParams extends Equatable {
  const RegisterParams({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.phone = '',
    this.phoneCountryIsoCode = '',
    this.role = UserRole.customer,
    this.country = '',
  });

  final String firstName;
  final String lastName;

  /// Email address used to sign in and receive verification codes.
  final String email;

  /// Plain-text password (hashed/sanitized before persisting).
  final String password;

  /// Contact phone number in E.164 format, e.g. `+970599114453`, which is what
  /// the API contract shows.
  final String phone;

  /// ISO 3166-1 alpha-2 code the number belongs to, e.g. `PS`.
  ///
  /// Carried alongside [phone] so the use case can re-validate the number in
  /// the domain instead of trusting a string that arrived from the UI.
  final String phoneCountryIsoCode;

  /// Account type requested at registration.
  final UserRole role;

  /// Country of residence, as the non-localized English name of the country the
  /// user picked in the dialing-code dropdown.
  ///
  /// TODO(backend): the `/auth/register` example in
  /// `api folder/q-commerce-routing.postman_collection.json` omits `country`
  /// entirely and shows no schema for it. It is still always sent because the
  /// current contract requires it. **Confirm with the backend whether this
  /// field expects an English name (as sent today) or an ISO 3166-1 code**, and
  /// send the ISO code here if it turns out to be `phoneCountryIsoCode`.
  final String country;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    password,
    phone,
    phoneCountryIsoCode,
    role,
    country,
  ];
}
