// lib/features/auth/domain/entities/phone_country.dart

import 'package:equatable/equatable.dart';

/// A country a phone number can be entered against.
///
/// Pure Dart — deliberately free of Flutter and of any display concern, so the
/// validation, the use cases and the request payload can all read the same
/// metadata without depending on a widget layer.
class PhoneCountry extends Equatable {
  const PhoneCountry({
    required this.isoCode,
    required this.dialCode,
    required this.apiName,
  });

  /// ISO 3166-1 alpha-2 code, e.g. `PS`. What the phone parser needs, and what
  /// a stored E.164 number is split back on.
  final String isoCode;

  /// International calling prefix, e.g. `+970`.
  final String dialCode;

  /// Non-localized English country name sent to the API.
  ///
  /// Never the localized display name: the payload must not change when the
  /// user switches the device language.
  final String apiName;

  @override
  List<Object?> get props => [isoCode, dialCode, apiName];
}

/// The countries the app accepts a phone number from.
///
/// Single source of truth. The UI picker renders these entries and the domain
/// validates against them, so the dial code shown cannot disagree with the one
/// validated or sent. Order is the order the picker shows them in.
const List<PhoneCountry> kPhoneCountries = [
  PhoneCountry(isoCode: 'PS', dialCode: '+970', apiName: 'Palestine'),
  PhoneCountry(isoCode: 'SA', dialCode: '+966', apiName: 'Saudi Arabia'),
  PhoneCountry(isoCode: 'EG', dialCode: '+20', apiName: 'Egypt'),
  PhoneCountry(
    isoCode: 'AE',
    dialCode: '+971',
    apiName: 'United Arab Emirates',
  ),
  PhoneCountry(isoCode: 'JO', dialCode: '+962', apiName: 'Jordan'),
  PhoneCountry(isoCode: 'QA', dialCode: '+974', apiName: 'Qatar'),
  PhoneCountry(isoCode: 'KW', dialCode: '+965', apiName: 'Kuwait'),
  PhoneCountry(isoCode: 'OM', dialCode: '+968', apiName: 'Oman'),
  PhoneCountry(isoCode: 'BH', dialCode: '+973', apiName: 'Bahrain'),
];

/// The country assumed when nothing better is known: Palestine heads the picker
/// and is the app's home market, and it stays one tap away from being changed.
const PhoneCountry kDefaultPhoneCountry = PhoneCountry(
  isoCode: 'PS',
  dialCode: '+970',
  apiName: 'Palestine',
);

/// Looks a country up by its two-letter [isoCode], case-insensitively.
///
/// Returns null for anything not in [kPhoneCountries], so a stale or
/// hand-edited stored value can never put a flow into a state the phone parser
/// has no metadata for.
PhoneCountry? phoneCountryByIsoCode(String? isoCode) {
  final normalized = isoCode?.trim().toUpperCase();
  if (normalized == null || normalized.isEmpty) return null;
  for (final country in kPhoneCountries) {
    if (country.isoCode == normalized) return country;
  }
  return null;
}
