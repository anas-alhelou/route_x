/// An order as `GET /orders/mine` returns it.
///
/// Money arrives as strings (Decimal), so [totalAmount] stays a string here.
class DriverOrderDto {
  const DriverOrderDto({
    required this.id,
    required this.status,
    required this.customerName,
    required this.address,
    this.customerPhone,
    this.region,
    this.latitude,
    this.longitude,
    this.totalAmount,
    this.cancelReason,
    this.createdAt,
    this.deliveredAt,
    this.items = const [],
  });

  final String id;

  /// PENDING | ASSIGNED | IN_TRANSIT | DELIVERED | CANCELLED | NEEDS_REVIEW ...
  final String status;
  final String customerName;
  final String address;
  final String? customerPhone;
  final String? region;
  final double? latitude;
  final double? longitude;
  final String? totalAmount;
  final String? cancelReason;
  final DateTime? createdAt;
  final DateTime? deliveredAt;
  final List<DriverOrderItemDto> items;

  int get packagesCount =>
      items.fold<int>(0, (sum, i) => sum + (i.quantity < 1 ? 1 : i.quantity));

  /// Short human code (the full id is a long UUID).
  String get code {
    final compact = id.replaceAll('-', '');
    return compact.length <= 6 ? compact : compact.substring(0, 6).toUpperCase();
  }

  bool get isOffer => status == 'PENDING';
  bool get isOpenStop => status == 'ASSIGNED' || status == 'IN_TRANSIT';

  factory DriverOrderDto.fromJson(Map<String, dynamic> json) {
    double? num_(Object? v) => v is num ? v.toDouble() : double.tryParse('$v');
    DateTime? date(Object? v) => v == null ? null : DateTime.tryParse('$v');
    final rawItems = json['items'];
    return DriverOrderDto(
      id: json['id']?.toString() ?? '',
      status: (json['status']?.toString() ?? '').toUpperCase(),
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString(),
      address: json['address']?.toString() ?? '',
      region: json['region']?.toString(),
      latitude: num_(json['latitude']),
      longitude: num_(json['longitude']),
      totalAmount: json['totalAmount']?.toString(),
      cancelReason: json['cancelReason']?.toString(),
      createdAt: date(json['createdAt']),
      deliveredAt: date(json['deliveredAt']),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((e) => DriverOrderItemDto.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}

class DriverOrderItemDto {
  const DriverOrderItemDto({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  factory DriverOrderItemDto.fromJson(Map<String, dynamic> json) =>
      DriverOrderItemDto(
        productId: json['productId']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
}
