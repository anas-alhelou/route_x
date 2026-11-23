// lib/features/home/domain/repositories/home_debug_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';

/// Domain contract for the Home debug transitions.
///
/// Exists so `HomeBloc` can drive a debug transition without importing the data
/// layer. The presentation layer was reaching into `getIt<HomeLocalDataSource>()`
/// — a service locator call *and* an inward-pointing import, both from the same
/// handler. It now depends on this abstraction like every other use case does,
/// which is what makes the import-direction check come out clean.
///
/// Like [HomeDebugLocalDataSource] on the other side of the boundary, this is a
/// separate interface from [HomeRepository] on purpose: the production repository
/// does not advertise the ability to approve a driver's own request.
abstract interface class HomeDebugRepository {
  /// Moves the driver's request to [status] and returns the refreshed snapshot.
  Future<Either<Failure, HomeOverview>> resolveRequest({
    required FleetRequestStatus status,
    String? reason,
  });
}
