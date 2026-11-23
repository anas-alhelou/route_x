import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:routex_mobile/core/config/constants/api_endpoints.dart';
import 'package:routex_mobile/core/config/constants/api_timeouts.dart';
import 'package:routex_mobile/core/network/api_envelope.dart';
import 'package:routex_mobile/core/network/session_events.dart';
import 'package:routex_mobile/core/storage/secure_storage_service.dart';

/// Constructs the app's `Dio` graph.
///
/// This is the single HTTP client of the app (the previously duplicated
/// `core/services/remote/dio_client.dart` wrapper was removed): it is
/// registered in the DI container and handed to every remote data source.
///
/// Besides the base options it installs the auth interceptor, which
///   * attaches `Authorization: Bearer <accessToken>` to outgoing requests, and
///   * on a `401` calls `POST /auth/refresh` once, stores the new token pair and
///     replays the original request. If the refresh fails the session is
///     cleared and the original `401` propagates, which `ExceptionMapper`
///     surfaces as `UnauthorizedFailure`.
///
/// Timeouts all come from [ApiTimeouts.requestTimeout], the single value kept in
/// `core/config/constants/api_timeouts.dart`.
///
/// They are deliberately generous: the Render.com instance can take 30–50s to
/// wake from idle, so the first call must not be killed early. UI layers
/// surface this as a "connecting…" state, and a request that does expire is
/// reported as a timeout rather than a connectivity problem.
class DioClient {
  DioClient._(); // prevent instantiation

  /// Requests that must not carry (or auto-refresh) an Authorization header.
  /// Mark a call with `Options(extra: {'skipAuth': true})`.
  static const String skipAuthFlag = 'skipAuth';

  /// Internal marker ensuring a request is never retried more than once.
  static const String retriedFlag = '_retriedAfterRefresh';

  static BaseOptions _baseOptions() => BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: ApiTimeouts.requestTimeout,
    sendTimeout: ApiTimeouts.requestTimeout,
    receiveTimeout: ApiTimeouts.requestTimeout,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    headers: {'Accept': Headers.jsonContentType},
  );

  /// App-wide HTTP client.
  ///
  /// [refreshClientFactory] builds the interceptor-free client used for the
  /// refresh call and the replay. It is injectable only so tests can point both
  /// at a fake adapter; production uses a plain client with the same options.
  static Dio createClient({
    required SecureStorageService storage,
    Dio Function()? refreshClientFactory,
    bool logRequests = false,
  }) {
    final dio = Dio(_baseOptions());
    if (logRequests) dio.interceptors.add(_TimingLogInterceptor());
    dio.interceptors.add(_RateLimitRetryInterceptor(dio));

    // The refresh call and the replay bypass this client's interceptors on
    // purpose: re-entering the chain from inside an error handler would make
    // the refresh recurse on its own 401, and it keeps the refresh call itself
    // free of a stale Authorization header.
    final transport = refreshClientFactory?.call() ?? Dio(_baseOptions());

    dio.interceptors.add(
      _AuthInterceptor(
        storage: storage,
        transport: transport,
        refresh: _singleFlightRefresh(transport, storage),
      ),
    );

    return dio;
  }

  /// Wraps [refresh] so that simultaneous `401`s trigger a single refresh
  /// round-trip — a second one would send an already-rotated refresh token and
  /// log the user out.
  static Future<String?> Function() _singleFlightRefresh(
    Dio transport,
    SecureStorageService storage,
  ) {
    Future<String?>? inFlight;
    return () => inFlight ??= _refreshAccessToken(
      transport,
      storage,
    ).whenComplete(() => inFlight = null);
  }

  /// Exchanges the stored refresh token for a new token pair and persists it.
  ///
  /// Returns the new access token, or `null` when there is no usable refresh
  /// token or the backend rejects it.
  static Future<String?> _refreshAccessToken(
    Dio transport,
    SecureStorageService storage,
  ) async {
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await transport.post<dynamic>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final tokens = ApiEnvelope.unwrapTokens(
        response.data,
        path: ApiEndpoints.refreshToken,
      );
      if (tokens == null) return null;

      await storage.writeTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens.accessToken;
    } on DioException {
      return null;
    }
  }
}

/// Attaches the bearer token to every request and transparently recovers from
/// a `401` by refreshing the session once.
///
/// Implemented as an explicit [Interceptor] subclass (not a
/// `QueuedInterceptorsWrapper`) because the refresh call and the replay are
/// issued on [transport]: a request started from inside an interceptor callback
/// would otherwise queue behind the request that is already being handled and
/// deadlock.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required SecureStorageService storage,
    required Dio transport,
    required Future<String?> Function() refresh,
  }) : _storage = storage,
       _transport = transport,
       _refresh = refresh;

  final SecureStorageService _storage;
  final Dio _transport;
  final Future<String?> Function() _refresh;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _authorize(options).then((_) => handler.next(options));
  }

  Future<void> _authorize(RequestOptions options) async {
    if (options.extra[DioClient.skipAuthFlag] == true) return;
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _handleError(err, handler);
  }

  Future<void> _handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await _recover(err);
      if (response == null) {
        handler.next(err);
      } else {
        handler.resolve(response);
      }
    } on DioException catch (retryError) {
      // The replayed request failed too: report that failure, not the original.
      handler.next(retryError);
    }
  }

  /// Returns the replayed response, or `null` when the failure must be passed
  /// through untouched (after clearing the session if refresh failed).
  Future<Response<dynamic>?> _recover(DioException err) async {
    final request = err.requestOptions;
    final canRetry =
        err.response?.statusCode == 401 &&
        request.extra[DioClient.skipAuthFlag] != true &&
        request.extra[DioClient.retriedFlag] != true;

    if (!canRetry) return null;

    final refreshed = await _refresh();
    if (refreshed == null) {
      // The refresh token is gone or rejected: drop the session and let the
      // original 401 surface as UnauthorizedFailure.
      await _storage.clear();
      SessionEvents.notifyExpired();
      return null;
    }

    request.extra[DioClient.retriedFlag] = true;
    request.headers['Authorization'] = 'Bearer $refreshed';
    try {
      return await _transport.fetch<dynamic>(request);
    } on DioException catch (e) {
      // Only a refused fresh token ends the session; a timeout or a 5xx on
      // the replay must not log the driver out.
      if (e.response?.statusCode == 401) {
        await _storage.clear();
        SessionEvents.notifyExpired();
      }
      rethrow;
    }
  }
}

/// The backend answers `429 Too Many Requests` when it is hit too often. A
/// read is safe to repeat, so a rejected GET is retried twice after the wait
/// the server asked for (`Retry-After`, capped), instead of failing the screen.
/// Writes are never retried: repeating one could do it twice.
class _RateLimitRetryInterceptor extends Interceptor {
  _RateLimitRetryInterceptor(this._dio);

  final Dio _dio;
  static const String _attemptKey = 'rateLimitAttempt';
  static const int _maxRetries = 2;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final attempt = (request.extra[_attemptKey] as int?) ?? 0;
    final retryable =
        err.response?.statusCode == 429 &&
        request.method.toUpperCase() == 'GET' &&
        attempt < _maxRetries;
    if (!retryable) return handler.next(err);

    final header = err.response?.headers.value('retry-after');
    final seconds = int.tryParse(header ?? '');
    final wait = Duration(
      seconds: (seconds ?? (attempt + 1) * 2).clamp(1, 6),
    );
    await Future<void>.delayed(wait);
    request.extra[_attemptKey] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

/// Debug aid: prints one line per request with method, path, outcome and how
/// long it took. Never prints headers or bodies, so passwords and tokens stay
/// out of the console.
class _TimingLogInterceptor extends Interceptor {
  static const String _startKey = '_logStartedAt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _log(response.requestOptions, 'HTTP ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    _log(err.requestOptions, status != null ? 'HTTP $status' : err.type.name);
    handler.next(err);
  }

  void _log(RequestOptions o, String outcome) {
    final started = o.extra[_startKey] as int?;
    final ms = started == null
        ? '?'
        : '${DateTime.now().millisecondsSinceEpoch - started}';
    debugPrint('[api] ${o.method} ${o.path} -> $outcome in ${ms}ms');
  }
}
