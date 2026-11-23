// lib/features/home/domain/usecases/verify_fleet_code_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/repositories/enter_fleet_code_repository.dart';

/// Input for [VerifyFleetCodeUseCase].
///
/// Wraps the code in an object rather than taking a bare `String` so the use case
/// matches the app's `UseCase<T, P>` shape: several use cases take a single
/// argument, and an `Equatable` params object is what makes `when(() =>
/// useCase(any()))` work in a mock without registering a fallback for `String`.
///
/// [code] is expected to be already normalized. The BLoC owns that rule; the
/// value object [FleetCode] does not travel through here so the failure a driver
/// sees cannot depend on which layer normalized the input.
class VerifyFleetCodeParams extends Equatable {
  /// Creates the params for [code].
  const VerifyFleetCodeParams({required this.code});

  /// The normalized, six-character fleet code the driver typed.
  final String code;

  @override
  List<Object?> get props => [code];
}

/// Checks a driver-supplied fleet code and records a pending join request.
///
/// A one-line use case on purpose. It exists so `EnterFleetCodeBloc` depends on
/// a domain contract rather than on a repository interface, which is what keeps
/// the bloc free of `dartz` and of the data layer — and so the "verify then
/// record" intent is named at the call site instead of implied by the repository
/// method's name.
///
/// Returns the recorded request on success. A rejected code comes back as a
/// [Failure] carrying a localization key, never as a thrown exception.
class VerifyFleetCodeUseCase
    implements UseCase<FleetRequest, VerifyFleetCodeParams> {
  /// Creates the use case over [repository].
  const VerifyFleetCodeUseCase({required this.repository});

  /// Where the lookup happens.
  final EnterFleetCodeRepository repository;

  @override
  Future<Either<Failure, FleetRequest>> call(VerifyFleetCodeParams params) {
    return repository.verifyFleetCode(params.code);
  }
}