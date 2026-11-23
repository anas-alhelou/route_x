// lib/features/auth/data/models/register_request_model.dart

/// Body for `POST /auth/register`.
///
/// Mirrors the API contract exactly: `firstName` and `lastName` are separate
/// fields (there is no `fullName`), and `country` is required.
///
/// Vehicle fields are not part of this body: the fleet assigns the vehicle
/// after onboarding.
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  final String firstName;
  final String lastName;

  /// Country of residence, e.g. "Saudi Arabia".
  final String country;

  final String email;
  final String password;
  final String phone;

  /// `CUSTOMER` | `DRIVER`.
  final String role;

  /// Serializes the request body for `POST /auth/register`.
  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'country': country,
    'email': email,
    'password': password,
    'phone': phone,
    'role': role,
  };
}
