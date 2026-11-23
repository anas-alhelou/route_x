// lib/features/home/data/datasources/enter_fleet_code_local_data_source.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/repositories/fleet_request_store.dart';
import 'package:routex_mobile/features/home/domain/value_objects/fleet_code.dart';

/// Contract for verifying a fleet code against local data.
abstract interface class EnterFleetCodeLocalDataSource {
  /// Checks [code] and, when it is accepted, records the resulting request.
  Future<Either<Failure, FleetRequest>> verifyFleetCode(String code);
}

/// Verifies the one code the mock backend knows, and records the join request it
/// implies.
///
/// Depends on [FleetRequestStore], not on Home's data source. The previous
/// version took a `HomeLocalDataSource` and called `resolveRequest` on it, which
/// meant the Enter Fleet Code screen could not be exercised without standing up
/// the entire Home data layer, and any change to Home's internals could break a
/// screen that has nothing to do with Home. The store is the one fact both
/// screens need; sharing it is sharing data, not sharing behaviour.
///
/// The code *format* is not decided here. [FleetCode] owns "six alphanumeric
/// characters"; this class owns the mock backend's answer to a well-formed code,
/// which is data, not a rule.
class EnterFleetCodeLocalDataSourceImpl
    implements EnterFleetCodeLocalDataSource {
  EnterFleetCodeLocalDataSourceImpl({required FleetRequestStore requestStore})
    : _requestStore = requestStore;

  /// Stands in for the round trip a real verify endpoint would make.
  static const Duration _networkDelay = Duration(milliseconds: 350);

  /// Which fleet the accepted code belongs to. Mock data, kept here so no other
  /// layer has to know it: the design's first-run frame and the seeded Home
  /// dashboard are both about this fleet.
  static const String _acceptedFleetId = 'red-sea-express';
  static const String _acceptedFleetName = 'Red Sea Express';

  final FleetRequestStore _requestStore;

  @override
  Future<Either<Failure, FleetRequest>> verifyFleetCode(String code) async {
    await Future<void>.delayed(_networkDelay);

    if (!FleetCode.isValid(code)) {
      return const Left(ValidationFailure('errFleetCodeInvalid'));
    }

    // Saved, not just returned: the driver has joined the fleet, so returning to
    // Home must show a pending request rather than the seeded "no fleet" state.
    // The screen this screen returns to is Home, and this is what makes that
    // true without Home knowing a code was entered.
    return Right(
      await _requestStore.save(
        FleetRequest(
          fleetId: _acceptedFleetId,
          fleetName: _acceptedFleetName,
          fleetLogoPath: AppAssets.imgFleetRedSeaExpress,
          requestedAt: DateTime.now(),
          status: FleetRequestStatus.pending,
        ),
      ),
    );
  }
}