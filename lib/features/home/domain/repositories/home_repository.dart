// lib/features/home/domain/repositories/home_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';

/// Abstract definition of the Home data operations, implemented by the data
/// layer.
///
/// Every method returns `Either<Failure, T>` even though the current
/// implementation is local and cannot fail on a network: the contract the bloc
/// and the tests exercise is the one the remote implementation will honour, so
/// swapping the data source later changes nothing above this line.
abstract class HomeRepository {
  /// Loads everything the Home screen renders.
  Future<Either<Failure, HomeOverview>> getHomeOverview();

  /// Moves the driver on or off shift and returns the resulting availability.
  ///
  /// Rejects a request to go online without a fleet, mirroring
  /// [DriverAvailability.canToggle].
  Future<Either<Failure, DriverAvailability>> setOnlineStatus({
    required bool isOnline,
  });

  /// Records that the driver asked to join [fleetId] and returns the refreshed
  /// overview, in which the setup checklist has advanced.
  Future<Either<Failure, HomeOverview>> joinFleet({required String fleetId});
}
