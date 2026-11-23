// lib/features/auth/domain/entities/signup_credentials.dart
import 'dart:io';

import 'package:equatable/equatable.dart';

/// Represents the collected data across the multi-step signup process.
/// Pure Dart entity — no JSON serialization or UI logic lives here.
class SignupCredentials extends Equatable {
  const SignupCredentials({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.phoneCountryIsoCode = '',
    this.phoneCountryDialCode = '',
    this.countryName = '',
    this.profileImage,
  });

  /// User's first name.
  final String firstName;

  /// User's last name.
  final String lastName;

  /// User's email address.
  final String email;

  /// User's phone number in E.164 format, e.g. `+970599114453`.
  ///
  /// The number is normalized once, in the use case, so every consumer — the
  /// API request, the summary screen and the edit sheet — reads the same
  /// unambiguous value instead of re-guessing what the user typed.
  final String phone;

  /// ISO 3166-1 alpha-2 code of the country the number belongs to, e.g. `PS`.
  final String phoneCountryIsoCode;

  /// Dial code of that country, e.g. `+970`. Kept so the picker can be
  /// re-opened on the right country without parsing the number again.
  final String phoneCountryDialCode;

  /// Non-localized English country name sent to the API as `country`.
  ///
  /// Never the localized display name: the payload must not change with the
  /// device language.
  final String countryName;

  /// Optional profile photo picked during sign-up step 1.
  final File? profileImage;

  /// Returns a copy with only the provided fields replaced.
  SignupCredentials copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? phoneCountryIsoCode,
    String? phoneCountryDialCode,
    String? countryName,
    File? profileImage,
  }) {
    return SignupCredentials(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneCountryIsoCode: phoneCountryIsoCode ?? this.phoneCountryIsoCode,
      phoneCountryDialCode: phoneCountryDialCode ?? this.phoneCountryDialCode,
      countryName: countryName ?? this.countryName,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    phoneCountryIsoCode,
    phoneCountryDialCode,
    countryName,
    profileImage,
  ];
}
