// lib/features/home/data/datasources/home_debug_local_data_source.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';

/// Data-layer contract for the Home debug transitions.
///
/// **Not part of [HomeLocalDataSource].** These transitions exist so every frame
/// of the Go Online sheet and the "Get started" card can be reviewed without a
/// backend to approve or decline a request against. Keeping them off the
/// production contract means nothing in the shipping path can reach them by
/// accident: a caller holding a [HomeLocalDataSource] does not have the method,
/// so the only way to call it is to have deliberately asked for this interface.
///
/// [HomeLocalDataSourceImpl] implements both interfaces over one set of state,
/// because the transitions mutate the same dashboard snapshot the real reads
/// return. Splitting the implementation would mean duplicating that state.
abstract interface class HomeDebugLocalDataSource {
  /// Moves the driver's request to [status] and returns the refreshed snapshot.
  ///
  /// [reason] is the dispatcher's explanation, used only with
  /// [FleetRequestStatus.declined]; ignored otherwise.
  Future<Either<Failure, HomeOverview>> resolveRequest({
    required FleetRequestStatus status,
    String? reason,
  });
}
