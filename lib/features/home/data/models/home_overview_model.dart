// lib/features/home/data/models/home_overview_model.dart
import 'package:routex_mobile/features/home/data/models/driver_profile_model.dart';
import 'package:routex_mobile/features/home/data/models/fleet_summary_model.dart';
import 'package:routex_mobile/features/home/data/models/setup_progress_model.dart';
import 'package:routex_mobile/features/home/data/models/shift_stats_model.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';

/// Data-layer shape of [HomeOverview].
class HomeOverviewModel extends HomeOverview {
  const HomeOverviewModel({
    required super.profile,
    required super.availability,
    required super.stats,
    required super.setup,
    required super.nearbyFleets,
    super.fleetRequest,
  });

  factory HomeOverviewModel.fromJson(Map<String, dynamic> json) {
    final rawFleets = (json['nearbyFleets'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    return HomeOverviewModel(
      profile: DriverProfileModel.fromJson(
        json['profile'] as Map<String, dynamic>,
      ),
      availability: DriverAvailability(
        isOnline: (json['isOnline'] as bool),
        fleetId: json['fleetId'] as String?,
      ),
      stats: ShiftStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
      setup: SetupProgressModel.fromJson(json['setup'] as Map<String, dynamic>),
      nearbyFleets: rawFleets
          .map(FleetSummaryModel.fromJson)
          .toList(growable: false),
    );
  }
}
