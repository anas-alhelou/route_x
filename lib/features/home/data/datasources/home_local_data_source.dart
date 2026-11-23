// lib/features/home/data/datasources/home_local_data_source.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/data/datasources/home_debug_local_data_source.dart';
import 'package:routex_mobile/features/home/data/models/driver_profile_model.dart';
import 'package:routex_mobile/features/home/data/models/fleet_summary_model.dart';
import 'package:routex_mobile/features/home/data/models/home_overview_model.dart';
import 'package:routex_mobile/features/home/data/models/setup_progress_model.dart';
import 'package:routex_mobile/features/home/data/models/shift_stats_model.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/domain/entities/setup_progress.dart';
import 'package:routex_mobile/features/home/domain/repositories/fleet_request_store.dart';

/// Contract for the local Home source, implemented by the Data layer.
///
/// Three production reads and writes, and nothing else. The debug transitions
/// live on [HomeDebugLocalDataSource] instead — see that file for why.
abstract interface class HomeLocalDataSource {
  /// Returns the dashboard snapshot as of now.
  Future<Either<Failure, HomeOverview>> getHomeOverview();

  /// Persists the driver's on-shift flag and returns the new availability.
  Future<Either<Failure, DriverAvailability>> setOnlineStatus({
    required bool isOnline,
  });

  /// Requests to join [fleetId] and returns the refreshed snapshot.
  Future<Either<Failure, HomeOverview>> joinFleet({required String fleetId});
}

/// Seeds the Home screen with the exact contents of the `Home First Run` Figma
/// frame and keeps the mutable parts in memory.
///
/// Implements [HomeDebugLocalDataSource] as well as [HomeLocalDataSource]: both
/// operate on the same snapshot, so two implementations would mean two states
/// that disagree.
///
/// **Where the truth lives.** The driver's request is held by [FleetRequestStore],
/// not by a field here, because Enter Fleet Code writes it too. Everything else
/// on the dashboard that depends on that one fact — the availability's fleet id
/// and request status, the setup card's fleet gate — is *derived* in
/// [_snapshot] rather than stored alongside it. That is the change that removed
/// most of this file: the previous version kept four copies of "has this driver
/// asked to join a fleet" and rebuilt the setup list by hand inside each of four
/// `switch` branches.
class HomeLocalDataSourceImpl
    implements HomeLocalDataSource, HomeDebugLocalDataSource {
  HomeLocalDataSourceImpl({required FleetRequestStore requestStore})
    : _requestStore = requestStore;

  /// Simulated latency for the two calls a driver waits on: loading the
  /// dashboard and submitting a join. The debug transitions use a shorter one
  /// because they are not something a driver is ever waiting for.
  static const Duration _readDelay = Duration(milliseconds: 300);
  static const Duration _writeDelay = Duration(milliseconds: 300);
  static const Duration _debugDelay = Duration(milliseconds: 200);

  final FleetRequestStore _requestStore;

  /// The immutable parts of the dashboard, straight from the design.
  static final HomeOverviewModel _seed = _seedOverview();

  /// Whether the driver is on shift.
  ///
  /// The only mutable field left. Everything else that changes is either in the
  /// store or derived from it.
  bool _isOnline = false;

  @override
  Future<Either<Failure, HomeOverview>> getHomeOverview() async {
    await Future<void>.delayed(_readDelay);
    return Right(_snapshot());
  }

  @override
  Future<Either<Failure, DriverAvailability>> setOnlineStatus({
    required bool isOnline,
  }) async {
    // Locked until a fleet approves the driver: this is the rule the locked
    // switch and the Go Online sheet both exist to explain, so it is enforced
    // here rather than in the widget that draws the lock.
    if (isOnline && !_availability.canToggle) {
      return const Left(ValidationFailure('errJoinFleetBeforeGoingOnline'));
    }

    _isOnline = isOnline;
    return Right(_availability);
  }

  @override
  Future<Either<Failure, HomeOverview>> joinFleet({
    required String fleetId,
  }) async {
    await Future<void>.delayed(_writeDelay);

    final matches = _seed.nearbyFleets.where((fleet) => fleet.id == fleetId);
    if (matches.isEmpty) {
      return const Left(ServerFailure('errFleetNotFound'));
    }

    final fleet = matches.first;
    await _requestStore.save(
      FleetRequest(
        fleetId: fleet.id,
        fleetName: fleet.name,
        fleetLogoPath: fleet.logoPath,
        requestedAt: DateTime.now(),
        status: FleetRequestStatus.pending,
      ),
    );

    return Right(_snapshot());
  }

  @override
  Future<Either<Failure, HomeOverview>> resolveRequest({
    required FleetRequestStatus status,
    String? reason,
  }) async {
    await Future<void>.delayed(_debugDelay);

    if (status == FleetRequestStatus.none) {
      await _requestStore.clear();
      return Right(_snapshot());
    }

    // A transition can be reached from the seeded state, where there is no
    // request yet to advance. Rather than making the debug gesture drive two
    // separate requests, it moves the driver to the seeded fleet — the one the
    // design's first-run frame is about.
    final current = _requestStore.current;
    await _requestStore.save(
      FleetRequest(
        fleetId: current?.fleetId ?? _seedFleetId,
        fleetName: current?.fleetName ?? _seedFleetName,
        fleetLogoPath: current?.fleetLogoPath ?? AppAssets.imgFleetRedSeaExpress,
        // The original timestamp is kept so repeated transitions do not make the
        // sheet's "Requested at" line jump.
        requestedAt: current?.requestedAt ?? DateTime.now(),
        status: status,
        // Left null rather than defaulted to English copy: the Go Online sheet
        // falls back to its own localized `defaultDeclinedReason`, which only
        // ever runs while this stays null.
        declineReason: status == FleetRequestStatus.declined ? reason : null,
      ),
    );

    return Right(_snapshot());
  }

  /// The dashboard as of now.
  ///
  /// Single place where the request, the availability and the setup card are
  /// brought into agreement — every method returns one of these, so no caller
  /// can be handed a snapshot from before someone else's write.
  HomeOverviewModel _snapshot() {
    final request = _requestStore.current;
    return HomeOverviewModel(
      profile: _seed.profile,
      availability: _availability,
      stats: _seed.stats,
      setup: _seed.setup.withFleetStatus(
        (request?.status ?? FleetRequestStatus.none).setupStepStatus,
      ),
      nearbyFleets: _seed.nearbyFleets,
      fleetRequest: request,
    );
  }

  /// The driver's shift state, with fleet membership read from the store.
  DriverAvailability get _availability => DriverAvailability(
    isOnline: _isOnline,
    fleetId: _requestStore.current?.fleetId,
    requestStatus:
        _requestStore.current?.status ?? FleetRequestStatus.none,
  );

  /// The fleet the debug transitions fall back to. The first fleet in the seeded
  /// list, named in one place so the three identifiers cannot drift apart.
  static const String _seedFleetId = 'red-sea-express';
  static const String _seedFleetName = 'Red Sea Express';

  /// Driver named in the design, on shift zero, no fleet — hence the locked
  /// switch and the outstanding fleet step.
  ///
  /// Every colour here is a literal because this *is* the design data: the
  /// three fleets in the Figma frame carry these exact brand values, and there is
  /// no palette to look them up in. They reach the UI as plain ARGB ints on
  /// `FleetSummary`, which wraps them in `Color(...)` at the widget layer.
  static HomeOverviewModel _seedOverview() {
    return HomeOverviewModel(
      profile: const DriverProfileModel(
        displayName: 'Hamza Barakat',
        avatarPath: AppAssets.imgDriverAvatar,
      ),
      availability: const DriverAvailability(isOnline: false),
      stats: const ShiftStatsModel(
        deliveries: 0,
        deliveriesTarget: 0,
        distanceKm: 0,
        shiftDuration: Duration.zero,
      ),
      setup: const SetupProgressModel(
        steps: [
          SetupStep(id: SetupStepId.account, status: SetupStepStatus.done),
          SetupStep(id: SetupStepId.phone, status: SetupStepStatus.done),
          SetupStep(id: SetupStepId.fleet, status: SetupStepStatus.todo),
        ],
      ),
      nearbyFleets: const [
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
      ],
      fleetRequest: null,
    );
  }
}