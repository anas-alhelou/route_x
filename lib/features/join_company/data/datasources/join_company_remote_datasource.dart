import 'package:dio/dio.dart';
import 'package:routex_mobile/features/settings/data/datasources/settings_api_data_source.dart';
import 'package:routex_mobile/core/session/driver_identity.dart';
import 'package:routex_mobile/core/config/constants/api_endpoints.dart';
import 'package:routex_mobile/core/network/api_envelope.dart';

/// Thrown when `POST /drivers/join-by-code` answers that the code is unknown
/// or malformed (400/404).
class JoinCodeNotFoundException implements Exception {
  const JoinCodeNotFoundException();
}

/// 409: the driver is already a member, or a request is already pending.
class JoinAlreadyRequestedException implements Exception {
  const JoinAlreadyRequestedException();
}

/// 403: membership suspended, or the code route refuses a re-request after a
/// rejection.
class JoinNotAllowedException implements Exception {
  const JoinNotAllowedException();
}

/// Result of `POST /drivers/join-by-code`.
class JoinByCodeResult {
  const JoinByCodeResult({
    required this.companyId,
    required this.companyName,
    this.logoUrl,
  });

  final String companyId;
  final String companyName;
  final String? logoUrl;
}

/// The company logo URL, if the backend sent one under a known name.
String? _pickLogo(Map<String, dynamic> json) {
  final sources = <Map<String, dynamic>>[
    json,
    if (json['company'] is Map) Map<String, dynamic>.from(json['company'] as Map),
  ];
  for (final source in sources) {
    for (final key in const ['companyLogo', 'companyLogoUrl', 'logoUrl', 'logo']) {
      final v = source[key];
      if (v is String && v.startsWith('http')) return v;
    }
  }
  return null;
}

/// One entry of `memberships[]` from `GET /auth/me`.
class MembershipModel {
  const MembershipModel({
    required this.companyId,
    required this.companyName,
    required this.status,
    this.rejectionReason,
    this.logoUrl,
  });

  final String companyId;
  final String companyName;

  /// PENDING | APPROVED | REJECTED | SUSPENDED
  final String status;
  final String? rejectionReason;
  final String? logoUrl;

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      companyId: json['companyId']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'PENDING').toUpperCase(),
      rejectionReason: json['rejectionReason']?.toString(),
      logoUrl: _pickLogo(json),
    );
  }
}

/// Snapshot of the driver read from `GET /auth/me`.
class DriverMembershipsModel {
  const DriverMembershipsModel({
    required this.driverName,
    required this.memberships,
  });

  final String driverName;
  final List<MembershipModel> memberships;
}

abstract class JoinCompanyRemoteDataSource {
  Future<JoinByCodeResult> joinByCode(String code);

  /// Looks the company up by its join code without sending a request, if the
  /// search endpoint can match codes. Null when it cannot be told.
  Future<JoinByCodeResult?> findCompanyByCode(String code);
  Future<DriverMembershipsModel> fetchMemberships();
}

class JoinCompanyRemoteDataSourceImpl implements JoinCompanyRemoteDataSource {
  JoinCompanyRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<JoinByCodeResult> joinByCode(String code) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.driversJoinByCode,
        data: {'code': code},
      );
      final body = response.data;
      final data = body is Map && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : (body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{});
      return JoinByCodeResult(
        companyId: data['companyId']?.toString() ?? '',
        companyName: data['companyName']?.toString() ?? '',
        logoUrl: _pickLogo(data),
      );
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 400:
        case 404:
          throw const JoinCodeNotFoundException();
        case 409:
          throw const JoinAlreadyRequestedException();
        case 403:
          throw const JoinNotAllowedException();
      }
      rethrow;
    }
  }

  @override
  Future<JoinByCodeResult?> findCompanyByCode(String code) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.companiesSearch,
        queryParameters: {'query': code},
      );
      final body = response.data;
      final data = body is Map ? body['data'] : body;
      if (data is! List) return null;
      for (final item in data.whereType<Map>()) {
        final m = Map<String, dynamic>.from(item);
        final matches = const ['joinCode', 'code', 'companyCode']
            .any((k) => m[k]?.toString().toUpperCase() == code);
        if (matches) {
          return JoinByCodeResult(
            companyId: m['companyId']?.toString() ?? '',
            companyName: m['companyName']?.toString() ?? '',
            logoUrl: _pickLogo(m),
          );
        }
      }
    } catch (_) {
      // Not able to tell: the code is still checked when the request is sent.
    }
    return null;
  }

  @override
  Future<DriverMembershipsModel> fetchMemberships() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.me);
    final data = ApiEnvelope.unwrapData(response.data, path: ApiEndpoints.me);
    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;
    final first = user['firstName']?.toString() ?? '';
    final last = user['lastName']?.toString() ?? '';
    final raw = data['memberships'] ?? user['memberships'];
    final memberships = raw is List
        ? raw
              .whereType<Map>()
              .map((m) => MembershipModel.fromJson(Map<String, dynamic>.from(m)))
              .toList()
        : <MembershipModel>[];
    DriverIdentity.update(
      name: '$first $last',
      photo: SettingsApiDataSource.profileImageUrl(user),
    );
    return DriverMembershipsModel(
      driverName: '$first $last'.trim(),
      memberships: memberships,
    );
  }
}
