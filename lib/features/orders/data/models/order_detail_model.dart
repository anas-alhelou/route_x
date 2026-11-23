// lib/features/orders/data/models/order_detail_model.dart
import '../../domain/entities/order_detail_entity.dart';

class OrderDetailModel extends OrderDetailEntity {
  const OrderDetailModel({
    required super.id,
    required super.orderCode,
    required super.totalStops,
    required super.customerPhone,
    required super.addressLine,
    required super.addressDetails,
    required super.gateCode,
    required super.eta,
    required super.isOnTime,
    required super.packagesCount,
    required super.scannedCount,
    required super.requirements,
    required super.dispatchNote,
    required super.latitude,
    required super.longitude,
    super.minutesAway,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] as String,
      orderCode: json['order_code'] as String,
      totalStops: (json['total_stops'] as num).toInt(),
      customerPhone: json['customer_phone'] as String? ?? '',
      addressLine: json['address_line'] as String,
      addressDetails: json['address_details'] as String? ?? '',
      gateCode: json['gate_code'] as String?,
      eta: json['eta'] as String? ?? '',
      isOnTime: json['is_on_time'] as bool? ?? true,
      packagesCount: (json['packages_count'] as num?)?.toInt() ?? 0,
      scannedCount: (json['scanned_count'] as num?)?.toInt() ?? 0,
      requirements: (json['requirements'] as List? ?? const [])
          .map((e) => _parseRequirement(e as String))
          .whereType<DeliveryRequirement>()
          .toList(),
      dispatchNote: json['dispatch_note'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      minutesAway: (json['minutes_away'] as num?)?.toInt(),
    );
  }

  /// Unknown requirements are dropped rather than guessed at: a chip the
  /// driver cannot act on is worse than no chip.
  static DeliveryRequirement? _parseRequirement(String value) {
    switch (value) {
      case 'signature':
        return DeliveryRequirement.signature;
      case 'photo':
        return DeliveryRequirement.photo;
      default:
        return null;
    }
  }
}
