// lib/core/errors/exceptions.dart

/// Thrown when the backend answers a request successfully but omits data the
/// client cannot work without — e.g. `POST /auth/login` returning
/// `{ message, tokens }` with no `user`, which leaves nothing to identify or
/// persist the session with.
///
/// It extends [FormatException] so the model layer keeps failing loudly (the
/// payload really is unusable, and a half-built session must never be handed
/// out), while still being a *distinct* type: [ExceptionMapper] can then give
/// the user a specific, safe message for this known shape instead of the
/// catch-all one, and triage can tell it apart from an arbitrary bug.
///
/// The [message] deliberately keeps the offending payload for the logs. It is
/// never shown to the user: nothing renders an exception's `toString()`, only
/// the message the mapper chooses.
class IncompleteAuthResponseException extends FormatException {
  IncompleteAuthResponseException(super.message);
}
