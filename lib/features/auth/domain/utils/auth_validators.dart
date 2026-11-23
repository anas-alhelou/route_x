// lib/features/auth/domain/utils/auth_validators.dart

import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:routex_mobile/features/auth/domain/entities/phone_country.dart';

/// Pure utility class for Auth-related form validation.
///
/// Designed as a "Humble Object". These pure, stateless, synchronous functions
/// can be called directly by the UI layer (`validator:` property in `FormField`)
/// to preserve instant feedback without mixing validation logic into Flutter widgets.
class AuthValidators {
  AuthValidators._(); // Prevent instantiation

  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
  static final _otpRegex = RegExp(r'^\d{6}$');
  static final _uppercaseRegex = RegExp(r'[A-Z]');
  static final _digitRegex = RegExp(r'[0-9]');
  static final _symbolRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

  /// Everything a user may type into a phone field that is not part of the
  /// number itself. Stripped before parsing so `599 114 453`,
  /// `599-114-453` and `0599114453` are all the same number to the parser.
  static final _phoneSeparators = RegExp(r'[\s\-().]');

  /// Resolves an ISO 3166-1 alpha-2 code to the app's [PhoneCountry] metadata.
  ///
  /// Returns null for anything not in [kPhoneCountries], so a flow can never
  /// proceed with a country the parser has no numbering plan for.
  static PhoneCountry? resolvePhoneCountry(String? isoCode) =>
      phoneCountryByIsoCode(isoCode);

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'errNameRequired';
    }
    if (value.trim().length < 3) {
      return 'errNameMinLength';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'errFirstNameRequired';
    }
    if (value.trim().length < 3) {
      return 'errFirstNameMinLength';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'errLastNameRequired';
    }
    if (value.trim().length < 3) {
      return 'errLastNameMinLength';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'errEmailRequired';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'errEmailInvalid';
    }
    return null;
  }

  /// Validates a national phone number against the country the user picked in
  /// the dialing-code dropdown, and normalizes it to E.164.
  ///
  /// The UI splits a phone number in two — a country prefix (`+970`) and a
  /// national number (`0599114453`) — so neither half is a valid number on its
  /// own and the old `^\+?\d{8,14}$` check accepted a dozen digits of noise
  /// while rejecting a correctly typed Palestinian number. This takes both
  /// halves and does the following:
  ///
  /// 1. An empty/blank national number is `errPhoneRequired` — the user has to
  ///    type something, and that is a different problem from typing it wrong.
  /// 2. Spaces, dashes, dots, brackets and parentheses are stripped, so the
  ///    user's own formatting never makes a valid number fail.
  /// 3. The national part is parsed with the **selected country as the
  ///    destination country**. This is what makes a national trunk prefix work:
  ///    `0599114453` and `599114453` both resolve to the same `+970599114453`
  ///    because the parser knows Palestine's trunk code is `0`. Parsing the
  ///    digits on their own (no destination country) would instead throw,
  ///    since nothing in them identifies a country.
  /// 4. The result must be a valid **mobile** number for that country, not
  ///    merely a well-formed one. `isValid(type: PhoneNumberType.mobile)`
  ///    matches the country's real mobile pattern and length, so random digits
  ///    (`1234567890`) and landline lengths are rejected.
  /// 5. Any parse failure — an unknown ISO code, a number the library cannot
  ///    resolve — is `errPhoneInvalid`. A `PhoneNumberException` is expected
  ///    here rather than exceptional: it is how the library reports "this is not
  ///    a number", and the user only needs to know it is not valid.
  ///
  /// Returns the l10n **key** (`null` when valid), never display text.
  static String? validateInternationalPhone(
    String countryCode,
    String phoneNumber,
  ) {
    if (phoneNumber.trim().isEmpty) {
      return 'errPhoneRequired';
    }

    final isoCode = _tryIsoCode(countryCode);
    if (isoCode == null) return 'errPhoneInvalid';

    final parsed = _tryParse(isoCode, phoneNumber);
    if (parsed == null) return 'errPhoneInvalid';

    if (parsed.isoCode != isoCode) {
      // The typed digits resolved to a different country than the one the
      // dropdown shows (only possible when a full `+` number was typed). The
      // two would then contradict each other in the request payload.
      return 'errPhoneInvalid';
    }

    if (!parsed.isValid(type: PhoneNumberType.mobile)) {
      return 'errPhoneInvalid';
    }

    return null;
  }

  /// Normalizes a country-prefixed national number to E.164 (`+970599123456`),
  /// which is the single normalized form the API receives.
  ///
  /// Returns `null` when the number cannot be resolved, so a caller cannot
  /// accidentally send a half-parsed or unvalidated string as a phone number —
  /// validate with [validateInternationalPhone] first.
  ///
  /// When [phoneNumber] already carries an international prefix, that prefix
  /// wins over [countryCode]: the user typed the full number, so it is the more
  /// specific statement of intent.
  static String? toE164(String countryCode, String phoneNumber) {
    final isoCode = _tryIsoCode(countryCode);
    final parsed =
        _tryParse(isoCode, phoneNumber) ?? _tryParse(null, phoneNumber);
    if (parsed == null) return null;
    if (isoCode != null && parsed.isoCode != isoCode) return null;
    if (!parsed.isValid(type: PhoneNumberType.mobile)) return null;
    return parsed.international;
  }

  /// Splits a stored E.164 number back into the two halves the phone input
  /// works with, so an edit sheet can be pre-filled from what was saved.
  ///
  /// Returns `null` when [e164] cannot be parsed at all. A number that parses
  /// but is not a mobile number is still split: the picker has to be able to
  /// show the user what is stored so they can correct it.
  static ({String isoCode, String dialCode, String nationalNumber})? splitE164(
    String e164,
  ) {
    final parsed = _tryParse(null, e164);
    if (parsed == null || parsed.nsn.isEmpty) return null;
    return (
      isoCode: parsed.isoCode.name,
      dialCode: '+${parsed.countryCode}',
      nationalNumber: parsed.nsn,
    );
  }

  /// The number of national digits a mobile number has in [countryCode]
  /// (e.g. `9` for `SA`), or `null` when the country has no single length, so
  /// a form can say "Enter 9 digits" instead of a bare "invalid".
  static int? expectedMobileLength(String countryCode) {
    final isoCode = _tryIsoCode(countryCode);
    if (isoCode == null) return null;
    final lengths = metadataLenghtsByIsoCode[isoCode]?.mobile ?? const <int>[];
    return lengths.length == 1 ? lengths.single : null;
  }

  /// Resolves an ISO 3166-1 alpha-2 code, tolerating `null`/blank/garbage.
  static IsoCode? _tryIsoCode(String? code) {
    final normalized = code?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final value in IsoCode.values) {
      if (value.name == normalized) return value;
    }
    return null;
  }

  /// Parses [phoneNumber] with [isoCode] as the destination country, returning
  /// `null` for anything the library rejects.
  ///
  /// All separators are stripped first. The library is the single source of
  /// truth on what a valid number is — duplicating its rules here is how the
  /// previous regex drifted out of sync with real numbering plans.
  static PhoneNumber? _tryParse(IsoCode? isoCode, String phoneNumber) {
    final digits = phoneNumber.replaceAll(_phoneSeparators, '');
    if (digits.isEmpty) return null;
    try {
      return PhoneNumber.parse(digits, destinationCountry: isoCode);
    } on PhoneNumberException {
      return null;
    } catch (_) {
      // The library throws a bare String for a malformed ISO code and can throw
      // on metadata lookups; neither is a valid number, so both are invalid.
      return null;
    }
  }

  /// Login-specific password check — only enforces non-emptiness.
  /// (The stronger password-strength rules belong to the signup flow.)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'errPasswordRequired';
    }
    return null;
  }

  /// Verifies that the confirmation field matches the originally typed
  /// password. Used wherever a password is confirmed (signup step 3 and the
  /// forgot-password reset flow).
  static String? validatePasswordMatch(String? confirmValue, String password) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return 'errPasswordRequired';
    }
    if (confirmValue != password) {
      return 'errPasswordMismatch';
    }
    return null;
  }

  /// Strong-password rule, mirroring the backend's inferred requirements:
  /// minimum 8 characters, at least one upper, one digit and one special
  /// character. This is the *client* contract too, so users never pass
  /// client-side checks only to be rejected by the server.
  ///
  /// NOTE: the exact backend rule is still to be confirmed — if it differs,
  /// update this function (and the UI checklist) to match.
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'errPasswordRequired';
    }
    if (value.length < 8) {
      return 'errPasswordMinLength';
    }
    if (!_uppercaseRegex.hasMatch(value)) {
      return 'errPasswordUppercase';
    }
    if (!_digitRegex.hasMatch(value)) {
      return 'errPasswordNumber';
    }
    if (!_symbolRegex.hasMatch(value)) {
      return 'errPasswordSymbol';
    }
    return null;
  }

  /// Validates a 6-digit verification code.
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'errOtpRequired';
    }
    if (!_otpRegex.hasMatch(value)) {
      return 'errOtpInvalid';
    }
    return null;
  }
}
