// lib/features/home/domain/repositories/find_fleet_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';

/// Abstract definition of the Find a Fleet data operations.
///
/// Mirrors [HomeRepository] in shape: every method returns `Either<Failure, T>`
/// so the bloc and tests exercise the same contract the future remote
/// implementation will honour.
abstract class FindFleetRepository {
  /// Returns all fleets, optionally filtered by [filter] and [query].
  ///
  /// An empty [query] means no text filtering. [filter] defaults to
  /// [FleetFilter.all] (no chip filtering).
  Future<Either<Failure, List<FleetSummary>>> getFleets({
    FleetFilter filter = FleetFilter.all,
    String query = '',
  });

  /// Returns the set of filter chips available on the screen.
  Future<Either<Failure, List<FleetFilter>>> getAvailableFilters();

  /// Records that the driver asked to join [fleetId].
  Future<Either<Failure, void>> joinFleet({required String fleetId});
}
