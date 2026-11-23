import 'package:dio/dio.dart';
import 'package:routex_mobile/core/config/constants/api_endpoints.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';

import '../models/driver_order_dto.dart';

/// The driver's order endpoints, shared by every Orders screen.
///
/// Connectivity errors are thrown as [NetworkFailure] so the repositories'
/// offline handling (saved copy, retry) keeps working; every other error is
/// rethrown as the original [DioException] for the caller to map.
class DriverOrdersRemoteDataSource {
  DriverOrdersRemoteDataSource(this._dio);

  final Dio _dio;

  /// `GET /orders/mine` — the orders assigned to, or offered to, the driver.
  Future<List<DriverOrderDto>> getMine() => _cached(() => _guard(() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.ordersMine);
    final body = response.data;
    final data = body is Map ? body['data'] : body;
    final list = data is List
        ? data
        : (data is Map ? (data['orders'] ?? data['items']) : null);
    if (list is! List) return const <DriverOrderDto>[];
    return list
        .whereType<Map>()
        .map((e) => DriverOrderDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }));

  /// `PATCH /orders/accept {orderId, fleetCompanyId?}`.
  ///
  /// `fleetCompanyId` is only needed when the driver is approved by more than
  /// one company.
  Future<void> accept(String orderId, {String? fleetCompanyId}) => _mutate(
    () => _dio.patch<dynamic>(
      ApiEndpoints.ordersAccept,
      data: {
        'orderId': orderId,
        if (fleetCompanyId != null) 'fleetCompanyId': fleetCompanyId,
      },
    ),
  );

  /// `PATCH /orders/reject {orderId, reason?}` (reason: at most 500 chars).
  /// The order goes back to PENDING with no driver.
  Future<void> reject(String orderId, [String? reason]) {
    final text = reason?.trim();
    return _mutate(
      () => _dio.patch<dynamic>(
        ApiEndpoints.ordersReject,
        data: {
          'orderId': orderId,
          if (text != null && text.isNotEmpty)
            'reason': text.length > 500 ? text.substring(0, 500) : text,
        },
      ),
    );
  }

  /// `POST /orders/start-delivery`.
  ///
  /// No body, or `{storeId}` — the store id is only required when the driver
  /// holds ASSIGNED orders from more than one store (otherwise the backend
  /// answers `MIXED_COMPANY_ORDERS`).
  ///
  /// Returns the route data: `routeId`, `totalDistanceMeters`,
  /// `totalDurationSeconds`, `geometry` and `stops[]` (each with
  /// `stopSequence`, `estimatedArrival` and an `order` object). The orders
  /// become IN_TRANSIT only after the route is generated.
  Future<Map<String, dynamic>?> startDelivery({String? storeId}) => _mutate(() async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.ordersStartDelivery,
      data: storeId == null ? null : {'storeId': storeId},
    );
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  });

  /// `POST /orders/deliver` (multipart): `orderId` + `proof` image
  /// (JPEG / PNG / WebP, at most 5 MB).
  Future<void> deliver(String orderId, String proofImagePath) => _mutate(() async {
    final form = FormData.fromMap({
      'orderId': orderId,
      'proof': await MultipartFile.fromFile(proofImagePath),
    });
    await _dio.post<dynamic>(ApiEndpoints.ordersDeliver, data: form);
  });

  // Home, Route, Orders, offers and search all read `/orders/mine`. Opening a
  // few screens in a row used to fire that request many times in a second and
  // the backend answered 429. One request now serves every caller for a few
  // seconds, concurrent callers share the same call, and any change the driver
  // makes (accept, reject, start, deliver) drops the saved copy.
  static const Duration _cacheFor = Duration(seconds: 8);
  List<DriverOrderDto>? _cache;
  DateTime? _cachedAt;
  Future<List<DriverOrderDto>>? _inFlight;

  Future<List<DriverOrderDto>> _cached(
    Future<List<DriverOrderDto>> Function() load,
  ) {
    final at = _cachedAt;
    final saved = _cache;
    if (saved != null &&
        at != null &&
        DateTime.now().difference(at) < _cacheFor) {
      return Future.value(saved);
    }
    return _inFlight ??= load()
        .then((orders) {
          _cache = orders;
          _cachedAt = DateTime.now();
          return orders;
        })
        .whenComplete(() => _inFlight = null);
  }

  void _invalidate() {
    _cache = null;
    _cachedAt = null;
  }

  Future<T> _mutate<T>(Future<T> Function() call) =>
      _guard(() async {
        try {
          return await call();
        } finally {
          _invalidate();
        }
      });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final failure = const ExceptionMapper().map(e);
      if (failure is NetworkFailure) throw failure;
      rethrow;
    }
  }
}
