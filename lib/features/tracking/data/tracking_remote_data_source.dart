import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:routex_mobile/core/config/constants/api_endpoints.dart';

/// Why a location upload did not go through.
enum TrackingSendResult {
  /// 204: accepted.
  ok,

  /// 401 / 403: the tracking token is no longer valid; open a new session.
  sessionInvalid,

  /// 400: this sample was refused; drop it.
  rejected,

  /// 429: slow down.
  tooManyRequests,

  /// No answer / 5xx: worth one retry with the same sequence number.
  retryable,
}

/// Talks to the three `/tracking/*` endpoints.
///
/// Two clients on purpose:
///  * [_api] is the app-wide client: it carries the driver JWT and is used to
///    open and close the session.
///  * [_plain] has NO interceptors: `/tracking/location` is authorised by the
///    tracking token (`rtk_...`), and the JWT interceptor must neither replace
///    that header nor try to refresh on a 401.
abstract class TrackingRemoteDataSource {
  /// `POST /tracking/session`. Returns the tracking token (shown only once).
  Future<String> startSession(String appVersion);

  /// `POST /tracking/location` with one binary frame.
  Future<TrackingSendResult> sendFrame({
    required String token,
    required int seq,
    required Uint8List frame,
  });

  /// `POST /tracking/session/end`.
  Future<void> endSession();
}

class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  TrackingRemoteDataSourceImpl({required Dio api, required Dio plain})
    : _api = api,
      _plain = plain;

  final Dio _api;
  final Dio _plain;

  /// A client that carries no interceptors, for `/tracking/location`.
  static Dio createPlainClient() => Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (_) => true,
    ),
  );

  @override
  Future<String> startSession(String appVersion) async {
    final response = await _api.post<dynamic>(
      ApiEndpoints.trackingSession,
      data: {'appVersion': appVersion},
    );
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final token = data is Map ? data['token'] : null;
    if (token is! String || token.isEmpty) {
      throw const FormatException('tracking session: missing token');
    }
    return token;
  }

  @override
  Future<TrackingSendResult> sendFrame({
    required String token,
    required int seq,
    required Uint8List frame,
  }) async {
    try {
      final response = await _plain.post<dynamic>(
        ApiEndpoints.trackingLocation,
        data: Stream<List<int>>.value(frame),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/octet-stream',
            'Content-Length': frame.length,
            'X-Tracking-Seq': seq.toString(),
          },
          responseType: ResponseType.plain,
        ),
      );
      final code = response.statusCode ?? 0;
      if (code == 204 || (code >= 200 && code < 300)) {
        return TrackingSendResult.ok;
      }
      if (code == 401 || code == 403) return TrackingSendResult.sessionInvalid;
      if (code == 429) return TrackingSendResult.tooManyRequests;
      if (code >= 400 && code < 500) return TrackingSendResult.rejected;
      return TrackingSendResult.retryable;
    } on DioException {
      return TrackingSendResult.retryable;
    }
  }

  @override
  Future<void> endSession() async {
    await _api.post<dynamic>(ApiEndpoints.trackingSessionEnd);
  }
}
