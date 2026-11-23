// lib/features/home/domain/entities/home_stats_entity.dart
import 'package:equatable/equatable.dart';

/// Represents driver statistics for today and weekly periods.
class HomeStatsEntity extends Equatable {
  const HomeStatsEntity({
    required this.todayRides,
    required this.todayEarnings,
    required this.totalDrivingTime,
    required this.averageRating,
    required this.completionRate,
    required this.averageSpeed,
    required this.completedRidesWeekly,
    required this.cancelledRidesWeekly,
  });

  final int todayRides;
  final double todayEarnings;
  final Duration totalDrivingTime;

  final double averageRating;
  final double completionRate;
  final double averageSpeed;

  final int completedRidesWeekly;
  final int cancelledRidesWeekly;

  /// Total trips for the week.
  int get totalTripsWeekly => completedRidesWeekly + cancelledRidesWeekly;

  /// Weekly completion percentage.
  double get weeklyCompletionPercent => totalTripsWeekly == 0
      ? 0.0
      : (completedRidesWeekly / totalTripsWeekly) * 100.0;

  @override
  List<Object?> get props => [
        todayRides,
        todayEarnings,
        totalDrivingTime,
        averageRating,
        completionRate,
        averageSpeed,
        completedRidesWeekly,
        cancelledRidesWeekly,
      ];
}
