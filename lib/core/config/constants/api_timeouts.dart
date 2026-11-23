// lib/core/config/constants/api_timeouts.dart

/// Central registry for how long the app waits on a network request.
///
/// Every HTTP timeout the app configures comes from the single value below, so
/// tuning the wait is a one-line change instead of a hunt through the client
/// configuration.
class ApiTimeouts {
  ApiTimeouts._(); // prevent instantiation

  /// Budget for connecting to, sending to, and receiving from the backend.
  ///
  /// Deliberately generous: the Render.com instance can take a while to wake
  /// from idle (see [ApiEndpoints.baseUrl]), so the first request after a pause
  /// must not be killed early. When it does expire, `ExceptionMapper` reports it
  /// as a timeout rather than a connectivity problem, so the user is told the
  /// request was simply too slow.
  static const Duration requestTimeout = Duration(seconds: 45);
}
