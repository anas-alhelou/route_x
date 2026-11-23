// lib/features/home/data/models/today_summary_model.dart
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

class TodaySummaryModel extends TodaySummary {
  const TodaySummaryModel({
    required super.deliveredCount,
    required super.totalOrders,
    required super.distanceKm,
    required super.onRouteTime,
    required super.couldNotDeliver,
    required super.progressPercent,
  });

  factory TodaySummaryModel.fromJson(Map<String, dynamic> json) {
    return TodaySummaryModel(
      deliveredCount: json['deliveredCount'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      onRouteTime: json['onRouteTime'] as String? ?? '0m',
      couldNotDeliver: json['couldNotDeliver'] as int? ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveredCount': deliveredCount,
      'totalOrders': totalOrders,
      'distanceKm': distanceKm,
      'onRouteTime': onRouteTime,
      'couldNotDeliver': couldNotDeliver,
      'progressPercent': progressPercent,
    };
  }

  TodaySummary toEntity() => TodaySummary(
        deliveredCount: deliveredCount,
        totalOrders: totalOrders,
        distanceKm: distanceKm,
        onRouteTime: onRouteTime,
        couldNotDeliver: couldNotDeliver,
        progressPercent: progressPercent,
      );
}
