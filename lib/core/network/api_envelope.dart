// lib/core/network/api_envelope.dart
/// Unwraps the backend's standard response envelope.
///
/// Every successful endpoint answers with
/// `{ success: true, data: { ... }, timestamp }`, and every error with
/// `{ statusCode, timestamp, path, message, error }` (where `message` is a
/// `List<String>` for validation errors).
///
/// Data sources must therefore never hand the raw envelope to a model factory:
/// doing so makes `json['user']` / `json['tokens']` silently `null` and hides a
/// total parse failure behind empty defaults. This is the single place that
/// rule is implemented, shared by the data sources and the token-refresh
/// interceptor.
abstract final class ApiEnvelope {
  const ApiEnvelope._();

  /// Returns the `data` object of a successful response body.
  ///
  /// Throws a [FormatException] when the body is not the expected envelope, so
  /// a contract change surfaces as a loud error instead of empty models.
  static Map<String, dynamic> unwrapData(Object? body, {required String path}) {
    if (body is! Map) {
      throw FormatException(
        'Unexpected response body for $path: expected an envelope object, '
        'got ${body.runtimeType}',
      );
    }

    final envelope = Map<String, dynamic>.from(body);
    final data = envelope['data'];
    if (data is! Map) {
      throw FormatException(
        'Missing `data` in the response envelope for $path: $envelope',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  /// Extracts `data.tokens` from a successful auth envelope.
  ///
  /// Returns `null` unless both tokens are present, so callers can treat a
  /// token-less response (e.g. a rejected refresh) as "no session available".
  static ({String accessToken, String refreshToken})? unwrapTokens(
    Object? body, {
    required String path,
  }) {
    final Map<String, dynamic> data;
    try {
      data = unwrapData(body, path: path);
    } on FormatException {
      return null;
    }

    final tokens = data['tokens'];
    if (tokens is! Map) return null;

    final accessToken = tokens['accessToken'];
    final refreshToken = tokens['refreshToken'];
    if (accessToken is! String || accessToken.isEmpty) return null;
    if (refreshToken is! String || refreshToken.isEmpty) return null;

    return (accessToken: accessToken, refreshToken: refreshToken);
  }
}
