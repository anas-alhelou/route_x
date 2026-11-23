// lib/features/route_fleet/data/models/route_stop_model.dart
import '../../domain/entities/route_stop.dart';

class RouteStopModel extends RouteStop {
  const RouteStopModel({
    required super.id,
    required super.title,
    required super.address,
    required super.eta,
    required super.isCompleted,
    required super.status,
    super.phone,
    super.gateCode,
    super.timeWindow,
    super.packagesText,
    super.companyNote,
    super.orderId,
    super.packageType,
    super.doorNumber,
    super.latitude,
    super.longitude,
  });

  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    return RouteStopModel(
      id: json['id'] as String,
      title: json['title'] as String,
      address: json['address'] as String,
      eta: json['eta'] as String,
      isCompleted: json['is_completed'] as bool,
      status: json['status'] as String,
      phone: json['phone'] as String?,
      gateCode: json['gate_code'] as String?,
      timeWindow: json['time_window'] as String?,
      packagesText: json['packages_text'] as String?,
      companyNote: json['company_note'] as String?,
      orderId: json['order_id'] as String?,
      packageType: json['package_type'] as String?,
      doorNumber: json['door_number'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'eta': eta,
      'is_completed': isCompleted,
      'status': status,
      'phone': phone,
      'gate_code': gateCode,
      'time_window': timeWindow,
      'packages_text': packagesText,
      'company_note': companyNote,
      'order_id': orderId,
      'package_type': packageType,
      'door_number': doorNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
