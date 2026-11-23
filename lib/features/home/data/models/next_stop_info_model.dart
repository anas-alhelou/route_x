// lib/features/home/data/models/next_stop_info_model.dart
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

class NextStopInfoModel extends NextStopInfo {
  const NextStopInfoModel({
    required super.stopLabel,
    required super.customerName,
    required super.address,
    required super.estimatedArrival,
    required super.currentStop,
    required super.totalStops,
  });

  factory NextStopInfoModel.fromJson(Map<String, dynamic> json) {
    return NextStopInfoModel(
      stopLabel: json['stopLabel'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      estimatedArrival: json['estimatedArrival'] as String? ?? '',
      currentStop: json['currentStop'] as int? ?? 1,
      totalStops: json['totalStops'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stopLabel': stopLabel,
      'customerName': customerName,
      'address': address,
      'estimatedArrival': estimatedArrival,
      'currentStop': currentStop,
      'totalStops': totalStops,
    };
  }

  NextStopInfo toEntity() => NextStopInfo(
        stopLabel: stopLabel,
        customerName: customerName,
        address: address,
        estimatedArrival: estimatedArrival,
        currentStop: currentStop,
        totalStops: totalStops,
      );
}
