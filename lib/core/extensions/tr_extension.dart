import 'package:flutter/material.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';

extension TranslateExtension on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this)!;

  /// Resolves raw string keys from the domain layer (AuthValidators,
  /// [ExceptionMapper]) into fully localized user-facing strings.
  ///
  /// Only our own keys (the `err*` constants in [AuthValidators] and in
  /// [ExceptionMapper]) and the handful of other known keys below are
  /// translated. Anything else is returned **verbatim**, because it is not a
  /// key at all: [ExceptionMapper] already lifts the human-readable
  /// `message`/`error` field out of the API error envelope into
  /// [Failure.message], so those strings are ready to show and replacing them
  /// with a generic "something went wrong" would hide the actual reason the
  /// request failed.
  ///
  /// Callers are still expected to supply their own last-resort text for a
  /// missing message (`errorMessage != null ? translateValidationKey(...) :
  /// tr.somethingWentWrong`).
  String translateValidationKey(String key) {
    switch (key) {
      case 'errNameRequired':
        return tr.errNameRequired;
      case 'errNameMinLength':
        return tr.errNameMinLength;
      case 'errFirstNameRequired':
        return tr.errFirstNameRequired;
      case 'errFirstNameMinLength':
        return tr.errFirstNameMinLength;
      case 'errLastNameRequired':
        return tr.errLastNameRequired;
      case 'errLastNameMinLength':
        return tr.errLastNameMinLength;
      case 'errEmailRequired':
        return tr.errEmailRequired;
      case 'errEmailInvalid':
        return tr.errEmailInvalid;
      case 'errPhoneRequired':
        return tr.errPhoneRequired;
      case 'errPhoneInvalid':
        return tr.errPhoneInvalid;
      case 'errPasswordRequired':
        return tr.errPasswordRequired;
      case 'errPasswordMismatch':
        return tr.errPasswordMismatch;
      case 'errPasswordMinLength':
        return tr.errPasswordMinLength;
      case 'errPasswordUppercase':
        return tr.errPasswordUppercase;
      case 'errPasswordLowercase':
        return tr.errPasswordLowercase;
      case 'errPasswordNumber':
        return tr.errPasswordNumber;
      case 'errPasswordSymbol':
        return tr.errPasswordSymbol;
      case 'errOtpRequired':
        return tr.errOtpRequired;
      case 'errOtpInvalid':
        return tr.errOtpInvalid;
      case 'errVehicleRequired':
        return tr.errVehicleRequired;
      case 'errResetTokenRequired':
        return tr.errResetTokenRequired;
      case 'errRefreshTokenRequired':
        return tr.errRefreshTokenRequired;
      case 'errOrderAddressRequired':
        return tr.errOrderAddressRequired;
      case 'errPickupLocationRequired':
        return tr.errPickupLocationRequired;
      case 'errDropoffLocationRequired':
        return tr.errDropoffLocationRequired;
      case 'errLoggedOut':
        return tr.errLoggedOut;
      case 'errOrdersLoadFailed':
        return tr.errOrdersLoadFailed;
      case 'errOrderDetailLoadFailed':
        return tr.errOrderDetailLoadFailed;
      // Emitted by [ExceptionMapper] for exceptions it refuses to show. They
      // are keys rather than copy precisely so the mapper (which has no access
      // to a BuildContext) never has to decide on user-facing wording.
      case ExceptionMapper.unexpectedErrorKey:
        return tr.errUnexpectedResponse;
      case ExceptionMapper.incompleteResponseKey:
        return tr.errIncompleteResponse;
      case ExceptionMapper.requestTimeoutKey:
        return tr.errRequestTimeout;
      // Network-layer failures name themselves with a key, because they are
      // raised in the data layer where no BuildContext exists. Listed here
      // rather than as a constant so the keys stay next to the strings they
      // resolve to.
      case NetworkFailure.noConnectionKey:
        return tr.errNoInternetConnection;
      // The three Google sign-in outcomes a user can act on: the app is
      // misconfigured for Google (nothing they can do), the SDK attempt itself
      // failed, or the backend rejected the token the SDK produced. Cancelled
      // sign-in never reaches here.
      case 'errGoogleNotConfigured':
        return tr.errGoogleNotConfigured;
      case 'errGoogleSignInFailed':
        return tr.errGoogleSignInFailed;
      case 'errGoogleAuthFailed':
        return tr.errGoogleAuthFailed;
      // Raised by the Home data layer: the header switch is locked until the
      // driver joins a fleet, and a fleet row can disappear between the list
      // being drawn and Join being tapped.
      case 'errJoinFleetBeforeGoingOnline':
        return tr.errJoinFleetBeforeGoingOnline;
      case 'errFleetNotFound':
        return tr.errFleetNotFound;
      case 'errFleetCodeInvalid':
        return tr.errFleetCodeInvalid;
      case 'errInvalidOrExpiredCode':
        return tr.errInvalidOrExpiredCode;
      case 'errSessionExpired':
        return tr.errSessionExpired;
      default:
        // Not one of our keys: a real message from the API, already
        // human-readable. Show it as-is rather than hiding it.
        return key;
    }
  }
}
