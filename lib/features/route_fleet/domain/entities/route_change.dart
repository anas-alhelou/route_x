// lib/features/route_fleet/domain/entities/route_change.dart

enum RouteChangeType { added, removed, totals }

class RouteUpdateChange {
  const RouteUpdateChange({
    required this.type,
    required this.customerName,
    required this.address,
    required this.subtitle,
    required this.timestamp,
    this.updatedStopCount,
  });

  final RouteChangeType type;
  final String customerName;
  final String address;
  final String subtitle;
  final String timestamp;
  final int? updatedStopCount;
}
