// lib/core/network/exception_mapper.dart
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:routex_mobile/core/errors/exceptions.dart';
import 'package:routex_mobile/core/errors/failures.dart';

/// Translates raw exceptions (mainly [DioException]) into domain [Failure]s.
///
/// Repositories use this so that no `DioException` ever leaks into the
/// presentation layer — the UI only ever sees [Failure] values.
///
/// Only [DioException]s carry a message written *for* the user (the API error
/// envelope's `message`/`error` field), and those pass through untouched.
/// Anything else is an internal fault — a [FormatException] from a model's
/// `fromJson`, a `TypeError`, a bad state — whose `toString()` can quote the
/// whole response body, tokens included. Those are reported to the developer
/// logs and replaced by a translation key, so a UI that renders
/// [Failure.message] verbatim can never put one on screen.
class ExceptionMapper {
  const ExceptionMapper();

  /// Key resolved to a generic, human message by `translateValidationKey`.
  ///
  /// Used for any exception that escaped from somewhere it should not have.
  static const String unexpectedErrorKey = 'errUnexpectedResponse';

  /// Key resolved to a message about an incomplete server response.
  ///
  /// Distinct from [unexpectedErrorKey] on purpose: the request was accepted,
  /// so "something went wrong" would wrongly suggest the user's input was at
  /// fault, and it is the exact symptom of a backend response regression.
  static const String incompleteResponseKey = 'errIncompleteResponse';

  /// Key resolved to a "the request was too slow" message.
  ///
  /// Distinct from [NetworkFailure]'s default "no internet connection" on
  /// purpose: the network was reachable, the backend simply did not answer in
  /// time (`ApiTimeouts.requestTimeout`), and telling the user to check their
  /// connection would send them to the wrong problem.
  static const String requestTimeoutKey = 'errRequestTimeout';

  /// Fallback copy for a [DioException] that carries no usable message.
  static const String _defaultServerMessage = 'Something went wrong';

  /// Copy for a rejected Google sign-in whose body carried no usable reason.
  ///
  /// Read off [GoogleAuthTokenRejectedFailure] rather than repeated, so the key
  /// has exactly one definition and cannot drift from the failure it defaults to.
  static const String _googleAuthFallbackKey =
      GoogleAuthTokenRejectedFailure.fallbackMessage;

  /// Server messages that name no reason at all.
  ///
  /// Every status-line default (`"Internal Server Error"`, `"Forbidden"`, ...)
  /// and every framework placeholder ends up in the envelope's `message`/`error`
  /// field, so echoing one replaces the actual reason with a sentence the user
  /// has already read — in English, and untranslated. Compared
  /// case-insensitively and ignoring trailing punctuation; the original casing
  /// is what gets shown when the message *is* specific.
  static const Set<String> _boilerplateServerMessages = {
    'bad gateway',
    'bad request',
    'error',
    'forbidden',
    'gateway timeout',
    'internal error',
    'internal server error',
    'not authorized',
    'not found',
    'request failed',
    'server error',
    'service unavailable',
    'something went wrong',
    'unauthorized',
    'unprocessable entity',
  };

  Failure map(Object error, [StackTrace? stackTrace]) {
    if (error is! DioException) {
      _report(error, stackTrace);

      if (error is IncompleteAuthResponseException) {
        return const ServerFailure(incompleteResponseKey);
      }
      return const ServerFailure(unexpectedErrorKey);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(requestTimeoutKey);

      case DioExceptionType.connectionError:
      case DioExceptionType.cancel:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final code = effectiveStatusOf(error);
        switch (code) {
          case 400:
          case 422:
            return ValidationFailure(_message(error) ?? 'Invalid input');
          case 401:
          case 403:
            return UnauthorizedFailure(_message(error) ?? 'Session expired');
          default:
            return ServerFailure(_message(error) ?? _defaultServerMessage);
        }

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkFailure();
    }
  }

  /// Maps an exception raised by `POST /auth/google`.
  ///
  /// Narrower than [map] in one way: a `401` and a `500` both become a
  /// [GoogleAuthTokenRejectedFailure] rather than an [UnauthorizedFailure] and a
  /// [ServerFailure], because to the user they are the same event — "the Google
  /// identity this build sent was not accepted" — and both must resolve to the
  /// same retryable, Google-specific copy.
  ///
  /// What the failure *says*, though, is no longer flattened. The backend's own
  /// message is carried through whenever it names a real reason ("Email already
  /// registered", "نوع المركبة غير مدعوم"), because that message is the only
  /// thing that distinguishes a brand-new account (which registers fine) from
  /// the second sign-in with the same account (which the backend refuses), and
  /// collapsing both into one sentence is what made the difference invisible.
  /// The generic key is used only when the body carried nothing usable — empty,
  /// a status-line placeholder, or a proxy's HTML page.
  ///
  /// Everything else (timeouts, transport errors, a `400` with a readable
  /// validation message) keeps the specific mapping it has everywhere else.
  Failure mapGoogleAuth(Object error, [StackTrace? stackTrace]) {
    if (error is DioException && error.type == DioExceptionType.badResponse) {
      final status = effectiveStatusOf(error);
      if (status == 401 || status == 500) {
        return GoogleAuthTokenRejectedFailure(
          _specificGoogleRejection(error) ?? _googleAuthFallbackKey,
        );
      }
    }
    return map(error, stackTrace);
  }

  /// The backend's own reason for rejecting a Google identity, or `null` when it
  /// gave none that is worth showing.
  ///
  /// `null` covers the three ways "no reason" arrives: no `message`/`error`
  /// field at all, a placeholder from the status line, and the HTML error page a
  /// reverse proxy substitutes for a JSON envelope. A one- or two-character body
  /// is treated the same way — it is a truncated or encoded fragment, not a
  /// sentence anyone can act on.
  static String? _specificGoogleRejection(DioException error) {
    final message = _message(error)?.trim();
    if (message == null || message.isEmpty) return null;
    if (message.contains('<') || message.length <= 2) return null;
    final normalized = message.toLowerCase().replaceAll(RegExp(r'[\s.]+$'), '');
    if (_boilerplateServerMessages.contains(normalized)) return null;
    return message;
  }

  /// Hands the full original exception to the developer logs.
  ///
  /// `dart:developer`'s `log` keeps the message and the stack trace attached to
  /// the error, so DevTools and any crash reporter plugged into it show the
  /// real cause even though the UI only ever sees a safe key. Nothing is logged
  /// for [DioException]s: their message is user-facing copy that is shown as-is,
  /// and they arrive with the response that already documents them.
  static void _report(Object error, StackTrace? stackTrace) {
    developer.log(
      'Mapped a non-HTTP exception to a safe failure; full error follows',
      name: 'ExceptionMapper',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Best-effort extraction of a human-readable message from the response body.
  ///
  /// The backend error envelope is
  /// `{ statusCode, timestamp, path, message, error }`, where `message` is a
  /// `String` for regular errors but a `List<String>` for validation failures
  /// (e.g. `["password must be longer than or equal to 8 characters"]`) —
  /// both are handled so the specific reason is never lost in favour of the
  /// generic `error` field ("Bad Request").
  ///
  /// `error` may also be an object rather than that generic string, which is how
  /// a 500 envelope carries the failure it wraps; see [_message].
  static String? messageOf(Object error) =>
      error is DioException ? _message(error) : null;

  /// Best-effort extraction of the *effective* HTTP status of a failed call.
  ///
  /// Some backend routes answer a rejected request with a `500` envelope whose
  /// body embeds the real status:
  /// `{ statusCode: 500, message: "...", error: { statusCode: 400, message: ... } }`.
  /// Trusting the outer `500` turned every such rejection into a generic
  /// [ServerFailure], hiding the actual cause, so a nested `error.statusCode` is
  /// preferred whenever it is present and numeric.
  ///
  /// Returns `null` for anything that is not an HTTP error response.
  static int? effectiveStatusOf(Object error) {
    if (error is! DioException) return null;
    final status = error.response?.statusCode;
    if (status == null) return null;

    final data = error.response?.data;
    if (data is! Map) return status;

    final nested = (data['error']);
    if (nested is Map) {
      final nestedStatus = nested['statusCode'];
      if (nestedStatus is int) return nestedStatus;
      if (nestedStatus is String) {
        final parsed = int.tryParse(nestedStatus);
        if (parsed != null) return parsed;
      }
    }

    // A top-level `statusCode` that contradicts the envelope status is the same
    // wrapper seen without the extra nesting.
    final declared = data['statusCode'];
    if (declared is int && declared != status) return declared;

    return status;
  }

  /// Debug-only breadcrumb for a failed HTTP call.
  ///
  /// Logs the effective status (see [effectiveStatusOf]), the top-level keys of
  /// the response body and the backend message. Values are deliberately not
  /// logged: the body of an auth response carries tokens, and this line exists
  /// to diagnose a wrong status/message pairing, not to reproduce a payload.
  static void logRejection(Object error, {required String label}) {
    if (!kDebugMode) return;
    if (error is! DioException) return;
    if (error.response == null) return;

    final data = error.response?.data;
    final keys = data is Map
        ? data.keys.join(', ')
        : data.runtimeType.toString();
    developer.log(
      '$label failed '
      '(status: ${effectiveStatusOf(error)}, '
      'bodyKeys: $keys, '
      'message: ${_message(error) ?? 'none'})',
      name: 'ExceptionMapper',
    );
  }

  static String? _message(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      // When the envelope wraps a real failure (`{ statusCode: 500, message:
      // "Internal server error", error: { statusCode: 400, message: "Invalid
      // or expired verification code" } }`), the nested message is the actual
      // cause while the outer one is generic wrapper text. Preferring the outer
      // message is what made a rejected OTP report "Internal server error" even
      // though [effectiveStatusOf] had already recovered the 400.
      final nested = data['error'];
      if (nested is Map) {
        final nestedMessage = nested['message'];
        if (nestedMessage is String && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List) {
        final joined = message
            .whereType<String>()
            .map((entry) => entry.trim())
            .where((entry) => entry.isNotEmpty)
            .join('\n');
        if (joined.isNotEmpty) return joined;
      }
      final errorField = data['error'];
      if (errorField is String && errorField.isNotEmpty) return errorField;
    }
    return null;
  }
}
