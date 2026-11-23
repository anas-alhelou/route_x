import 'package:dio/dio.dart';
import 'package:routex_mobile/core/config/constants/api_endpoints.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/fleet_company.dart';

class FleetCompanyModel {
  const FleetCompanyModel({
    required this.id,
    required this.name,
    this.address,
    this.driversCount,
  });

  final String id;
  final String name;
  final String? address;
  final String? driversCount;

  factory FleetCompanyModel.fromJson(Map<String, dynamic> json) {
    final id = json['companyId']?.toString() ??
        json['id']?.toString() ??
        json['_id']?.toString();
    final name = json['name']?.toString() ?? json['companyName']?.toString();
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      throw FormatException(
        'Company search result missing required "id" or "name"/"companyName" field: $json',
      );
    }
    final address =
        json['address']?.toString() ?? json['registrationNumber']?.toString();
    final rawDriversCount =
        json['driversCount'] ?? json['drivers_count'] ?? json['drivers'];
    final driversCount = rawDriversCount?.toString();

    return FleetCompanyModel(
      id: id,
      name: name,
      address: address,
      driversCount: driversCount,
    );
  }

  FleetCompany toEntity() => FleetCompany(
        id: id,
        name: name,
        address: address,
        driversCount: driversCount,
      );
}

abstract class RouteFleetRemoteDataSource {
  Future<List<FleetCompanyModel>> searchFleets(String query);
  Future<String?> joinFleet(String companyId);
  Future<String?> joinFleetByCode(String code);
}

class RouteFleetRemoteDataSourceImpl implements RouteFleetRemoteDataSource {
  RouteFleetRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<FleetCompanyModel>> searchFleets(String query) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.companiesSearch,
      queryParameters: {'query': query},
    );

    final dynamic body = response.data;
    List<dynamic> list;

    if (body is List) {
      list = body;
    } else if (body is Map) {
      final envelopeData = body['data'] ?? body['items'] ?? body['companies'];
      if (envelopeData is List) {
        list = envelopeData;
      } else {
        throw FormatException(
          'Unexpected response format for ${ApiEndpoints.companiesSearch}: expected list or envelope containing list',
        );
      }
    } else {
      throw FormatException(
        'Unexpected response body type for ${ApiEndpoints.companiesSearch}: ${body.runtimeType}',
      );
    }

    return list
        .map((item) => FleetCompanyModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String?> joinFleet(String companyId) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.driversJoin,
      data: {'companyId': companyId},
    );
    return _extractCompanyName(response.data);
  }

  @override
  Future<String?> joinFleetByCode(String code) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.driversJoinByCode,
      data: {'code': code},
    );
    return _extractCompanyName(response.data);
  }

  String? _extractCompanyName(dynamic body) {
    if (body is Map) {
      final data = body['data'] ?? body;
      if (data is Map) {
        return data['name']?.toString() ??
            data['companyName']?.toString() ??
            data['company']?['name']?.toString();
      }
    }
    return null;
  }
}
