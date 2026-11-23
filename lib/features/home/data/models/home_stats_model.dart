// lib/features/home/data/models/home_stats_model.dart
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';

/// Data-layer shape of a [HomeStatsEntity].
class HomeStatsModel extends HomeStatsEntity {
  const HomeStatsModel({
    required super.todayRides,
    required super.todayEarnings,
    required super.totalDrivingTime,
    required super.averageRating,
    required super.completionRate,
    required super.averageSpeed,
    required super.completedRidesWeekly,
    required super.cancelledRidesWeekly,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    return HomeStatsModel(
      todayRides:
          (json['todayRides'] as num?)?.toInt() ?? (json['today_rides'] as num?)?.toInt() ?? 0,
      todayEarnings:
          (json['todayEarnings'] as num?)?.toDouble() ?? (json['today_earnings'] as num?)?.toDouble() ?? 0.0,
      totalDrivingTime: Duration(
        seconds: (json['totalDrivingTime'] as num?)?.toInt() ??
            (json['total_driving_time'] as num?)?.toInt() ??
            0,
      ),
      averageRating:
          (json['averageRating'] as num?)?.toDouble() ?? (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      completionRate:
          (json['completionRate'] as num?)?.toDouble() ?? (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      averageSpeed:
          (json['averageSpeed'] as num?)?.toDouble() ?? (json['average_speed'] as num?)?.toDouble() ?? 0.0,
      completedRidesWeekly: (json['completedRidesWeekly'] as num?)?.toInt() ??
          (json['completed_rides_weekly'] as num?)?.toInt() ??
          0,
      cancelledRidesWeekly: (json['cancelledRidesWeekly'] as num?)?.toInt() ??
          (json['cancelled_rides_weekly'] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayRides': todayRides,
      'todayEarnings': todayEarnings,
      'totalDrivingTime': totalDrivingTime.inSeconds,
      'averageRating': averageRating,
      'completionRate': completionRate,
      'averageSpeed': averageSpeed,
      'completedRidesWeekly': completedRidesWeekly,
      'cancelledRidesWeekly': cancelledRidesWeekly,
    };
  }

  HomeStatsEntity toEntity() {
    return HomeStatsEntity(
      todayRides: todayRides,
      todayEarnings: todayEarnings,
      totalDrivingTime: totalDrivingTime,
      averageRating: averageRating,
      completionRate: completionRate,
      averageSpeed: averageSpeed,
      completedRidesWeekly: completedRidesWeekly,
      cancelledRidesWeekly: cancelledRidesWeekly,
    );
  }
}
