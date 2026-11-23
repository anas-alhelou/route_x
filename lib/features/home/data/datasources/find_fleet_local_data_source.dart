// lib/features/home/data/datasources/find_fleet_local_data_source.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/data/models/fleet_summary_model.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';

/// Contract for the local Find a Fleet source.
abstract class FindFleetLocalDataSource {
  Future<Either<Failure, List<FleetSummary>>> getFleets({
    FleetFilter filter = FleetFilter.all,
    String query = '',
  });

  Future<Either<Failure, List<FleetFilter>>> getAvailableFilters();

  Future<Either<Failure, void>> joinFleet({required String fleetId});
}

/// Mock implementation seeded with realistic sample data.
///
/// Mirrors [HomeLocalDataSourceImpl]: in-memory, `Either<Failure, T>`,
/// `Future.delayed` so loading states are visible, and mutable only through
/// the join path. A remote source can replace this without touching the
/// repository or bloc.
class FindFleetLocalDataSourceImpl implements FindFleetLocalDataSource {
  FindFleetLocalDataSourceImpl() : _fleets = _seedFleets();

  final List<FleetSummaryModel> _fleets;

  /// The fleets the design ships with, in the order it lists them.
  ///
  /// Four are active and the fifth is paused, which is what makes the Find a
  /// fleet screen's own arithmetic work out: Nearby and All fleets show all
  /// five cards, Open to join narrows to the four that are taking drivers, and
  /// the "4 results" count counts joinable fleets rather than visible rows.
  static List<FleetSummaryModel> _seedFleets() {
    return const [
      FleetSummaryModel(
        id: 'red-sea-express',
        name: 'Red Sea Express',
        zone: 'Al Hamra',
        distanceKm: 1.2,
        logoPath: AppAssets.imgFleetRedSeaExpress,
        accentColor: 0xFF1E87FD,
        avatarFill: 0xFFFEFEFE,
        status: FleetJoinStatus.active,
        driverCount: 48,
      ),
      FleetSummaryModel(
        id: 'ktn-wears',
        name: 'KTN Wears',
        zone: 'Al Rawdah',
        distanceKm: 2.6,
        logoPath: AppAssets.imgFleetKtnWears,
        accentColor: 0xFF000000,
        avatarFill: 0xFFFEFCFA,
        status: FleetJoinStatus.active,
        driverCount: 23,
      ),
      FleetSummaryModel(
        id: 'dridies-dry-fruits',
        name: 'Dridies Dry Fruits',
        zone: 'Al Kaakah',
        distanceKm: 3.9,
        logoPath: AppAssets.imgFleetDridiesDryFruits,
        accentColor: 0xFFA47648,
        avatarFill: 0xFFFDFAF3,
        status: FleetJoinStatus.active,
        driverCount: 61,
      ),
      FleetSummaryModel(
        id: 'bilial-pharmacy',
        name: 'Bilial Pharmacy',
        zone: 'Al Aziziyah',
        distanceKm: 1.5,
        logoPath: AppAssets.imgFleetBilialPharmacy,
        accentColor: 0xFF1E63D6,
        avatarFill: 0xFFE8F1FF,
        status: FleetJoinStatus.active,
        driverCount: 17,
      ),
      FleetSummaryModel(
        id: 'shaunize',
        name: 'Shaunize',
        zone: 'Al Salamah',
        distanceKm: 2.2,
        logoPath: AppAssets.imgFleetShaunize,
        accentColor: 0xFF6B21A8,
        avatarFill: 0xFFF3ECFF,
        // The one fleet not taking drivers, so the list has a disabled Join to
        // draw and Open to join has something to exclude.
        status: FleetJoinStatus.paused,
        driverCount: 15,
      ),
    ];
  }

  /// How far a fleet may be and still count as nearby, in kilometres.
  ///
  /// A named constant rather than a literal in [getFleets] because the seeded
  /// distances are chosen to sit either side of it: a fleet that later moves out
  /// of range should change this number and be visible in the diff.
  static const double nearbyRadiusKm = 4.0;

  /// Simulated latencies, named per call so the cost of each screen's fake
  /// network is visible in the diff rather than buried in a `delayed` literal.
  ///
  /// The filters are deliberately the fastest call: they are a chip tap, and the
  /// driver is waiting on a row highlight, not on a screen. Joining is the
  /// slowest because the button shows a spinner the whole time.
  static const Duration _listDelay = Duration(milliseconds: 350);
  static const Duration _filtersDelay = Duration(milliseconds: 150);
  static const Duration _joinDelay = Duration(milliseconds: 400);

  @override
  Future<Either<Failure, List<FleetSummary>>> getFleets({
    FleetFilter filter = FleetFilter.all,
    String query = '',
  }) async {
    await Future<void>.delayed(_listDelay);

    Iterable<FleetSummaryModel> result = _fleets;

    // Text search: name or zone, case-insensitive.
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      final lower = trimmed.toLowerCase();
      result = result.where(
        (f) =>
            f.name.toLowerCase().contains(lower) ||
            f.zone.toLowerCase().contains(lower),
      );
    }

    // Chip filter.
    result = switch (filter) {
      FleetFilter.all => result,
      FleetFilter.nearby => result.where((f) => f.distanceKm <= nearbyRadiusKm),
      FleetFilter.active => result.where(
        (f) => f.status == FleetJoinStatus.active,
      ),
      FleetFilter.paused => result.where(
        (f) => f.status == FleetJoinStatus.paused,
      ),
    };

    return Right(result.toList(growable: false));
  }

  @override
  Future<Either<Failure, List<FleetFilter>>> getAvailableFilters() async {
    await Future<void>.delayed(_filtersDelay);
    // Three chips, in the order the design draws them. [FleetFilter.paused] stays
    // in the enum and still filters correctly — it simply has no chip of its
    // own, because a driver cannot ask to see fleets that are not taking them.
    return const Right([
      FleetFilter.nearby,
      FleetFilter.active,
      FleetFilter.all,
    ]);
  }

  @override
  Future<Either<Failure, void>> joinFleet({required String fleetId}) async {
    await Future<void>.delayed(_joinDelay);
    final exists = _fleets.any((f) => f.id == fleetId);
    if (!exists) {
      return const Left(ServerFailure('errFleetNotFound'));
    }
    return const Right(null);
  }
}
