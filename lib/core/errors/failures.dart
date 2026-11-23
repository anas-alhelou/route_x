// lib/core/errors/failures.dart
import 'package:equatable/equatable.dart';

/// Base class for all domain-level errors in the application.
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Represents a failure originating from client-side validation logic.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Represents a failure originating from an API or network operation.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  /// HTTP status code when the failure came from a server response.
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a failure originating from a network layer problem
/// (offline, timeouts, DNS) — distinct from a server that answered.
///
/// The default message is a *key*, not copy: the failure is created in the
/// data layer, which has no access to a `BuildContext`, so `translateValidationKey`
/// resolves it at the point of display like any other `err*` key. Hardcoding
/// English here is what previously left Arabic users reading an untranslated
/// sentence.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = noConnectionKey]);

  /// Key for the copy used when the request never reached a server.
  ///
  /// Named so the UI can recognise this specific failure and title it
  /// ("No connection") instead of applying the generic error headline — the
  /// only two failures where a retry is worth offering before the user goes and
  /// checks something.
  static const String noConnectionKey = 'errNoInternetConnection';
}

/// Represents a 401/403 response — the session is missing, expired or the
/// refresh cycle failed. Consumers should route back to Login.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired']);
}

/// Represents a failure originating from local storage boundaries.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Generic failure for unexpected cases.
class GenericFailure extends Failure {
  const GenericFailure([super.message = 'An unexpected error occurred']);
}

/// Represents the user dismissing the Google Sign-In chooser.
///
/// Not an error: the user simply changed their mind, so the UI must return to
/// its idle state without showing a message.
class GoogleAuthCancelledFailure extends Failure {
  const GoogleAuthCancelledFailure() : super('');
}

/// Represents a Google Sign-In attempt that never reached Google because the
/// app itself is not configured for it — no server client id, no OAuth client
/// registered for this package name, no matching SHA-1.
///
/// Kept separate from [ServerFailure] and [NetworkFailure] because the fix is
/// never the user's: retrying, or checking their connection, cannot help. Only
/// a developer changing the build configuration or the Firebase/Google console
/// can.
class GoogleAuthConfigurationFailure extends Failure {
  const GoogleAuthConfigurationFailure([
    super.message = 'errGoogleNotConfigured',
  ]);
}

/// Represents the backend answering `POST /auth/google` that the Google
/// identity is brand-new and cannot be signed in until a vehicle is supplied.
///
/// Not an error the user ever sees: it is the signal that moves the flow from
/// the first attempt (token only) to the vehicle step, so the presentation
/// layer branches on this type instead of showing [message]. It is raised from
/// the one exact wire signal that means "new account" and from nothing else —
/// a generic `400`, `401` or `404` must never be read as one, or an existing
/// user would be asked to register a vehicle they already have.
///
/// Kept separate from [ValidationFailure] even though a `422` would otherwise
/// map to one: this is control flow, not something to put in front of the user.
class GoogleVehicleRequiredFailure extends Failure {
  const GoogleVehicleRequiredFailure([super.message = messageKey]);

  /// Copy used if this failure ever reaches the UI by mistake.
  ///
  /// A translation key rather than English: the failure is built in the data
  /// layer, and the vehicle copy already exists for the form's own validation.
  static const String messageKey = 'errVehicleRequired';
}

/// Represents a `POST /auth/google` the backend refused to accept.
///
/// Raised for the two statuses that both mean the same thing to the user —
/// "the Google identity you handed us is not one we accept": a `401` (wrong
/// audience, expired or forged token) and a `500` (the backend's token
/// verification blew up, which it reports with a generic server error). They
/// are deliberately collapsed into one failure so both stay retryable and
/// Google-specific.
///
/// The [message] is the backend's own reason whenever it gave one that names
/// it — the second sign-in with an account that already exists is refused for a
/// completely different reason than the first, and only the server can say
/// which. `ExceptionMapper.mapGoogleAuth` therefore passes that message
/// through, falling back to `errGoogleAuthFailed` when the body carried only a
/// status-line placeholder.
///
/// Kept separate from [ServerFailure] because the fallback copy has to be
/// Google-specific, and from [GoogleAuthConfigurationFailure] because the build
/// itself is fine here: only the credential was rejected.
class GoogleAuthTokenRejectedFailure extends Failure {
  const GoogleAuthTokenRejectedFailure([super.message = fallbackMessage]);

  /// Copy used when the backend's body carried no usable reason.
  ///
  /// Exposed as a constant so `ExceptionMapper` can name it as a fallback
  /// instead of repeating the literal, which is what keeps the key and the
  /// failure it belongs to from drifting apart.
  static const String fallbackMessage = 'errGoogleAuthFailed';
}
