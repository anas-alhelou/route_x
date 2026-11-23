// lib/features/home/domain/repositories/enter_fleet_code_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';

/// Domain contract for checking a driver-supplied fleet code.
///
/// Declared here, in the domain, rather than on the data source, so
/// [VerifyFleetCodeUseCase] depends on an interface and the local seed
/// implementation stays replaceable by a remote one without touching the use
/// case, the bloc, or the screen.
///
/// Takes a plain [String] rather than a `FleetCode` value object: normalization
/// is the BLoC's decision, and a repository that silently reformatted its input
/// would make the failure a driver sees depend on which layer happened to run
/// first.
abstract class EnterFleetCodeRepository {
  /// Checks [code] and, when it is accepted, records the join request.
  ///
  /// Returns the recorded [FleetRequest] on success, or a [Failure] carrying a
  /// localization key when the code is unknown or expired. Implementations must
  /// not throw for a rejected code — a wrong code is an expected outcome here,
  /// not an exceptional one.
  Future<Either<Failure, FleetRequest>> verifyFleetCode(String code);
}