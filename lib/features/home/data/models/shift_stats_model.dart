// lib/features/home/data/models/shift_stats_model.dart
import 'package:routex_mobile/features/home/domain/entities/shift_stats.dart';

/// Data-layer shape of [ShiftStats].
class ShiftStatsModel extends ShiftStats {
  const ShiftStatsModel({
    required super.deliveries,
    required super.deliveriesTarget,
    required super.distanceKm,
    required super.shiftDuration,
  });

  factory ShiftStatsModel.fromJson(Map<String, dynamic> json) {
    return ShiftStatsModel(
      deliveries: (json['deliveries'] as num).toInt(),
      deliveriesTarget: (json['deliveriesTarget'] as num).toInt(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      shiftDuration: Duration(seconds: (json['shiftSeconds'] as num).toInt()),
    );
  }

  Map<String, dynamic> toJson() => {
    'deliveries': deliveries,
    'deliveriesTarget': deliveriesTarget,
    'distanceKm': distanceKm,
    'shiftSeconds': shiftDuration.inSeconds,
  };
}
