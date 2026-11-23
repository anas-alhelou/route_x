// lib/features/home/domain/usecases/set_online_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_repository.dart';

/// Input for [SetOnlineStatusUseCase].
///
/// A single nullable flag rather than a bare `bool` would read better at the
/// call site, but the field is required: the design toggles the switch between
/// two known states and the widget always knows which one the user asked for.
class SetOnlineStatusParams {
  const SetOnlineStatusParams({required this.isOnline});

  /// The state the driver asked for.
  final bool isOnline;
}

/// Moves the driver on or off shift.
///
/// The guard against going online without a fleet lives in the repository,
/// which is the layer that owns [DriverAvailability]; repeating it here would
/// be a second rule to keep in step with the first.
class SetOnlineStatusUseCase
    implements UseCase<DriverAvailability, SetOnlineStatusParams> {
  const SetOnlineStatusUseCase({required this.repository});

  final HomeRepository repository;

  @override
  Future<Either<Failure, DriverAvailability>> call(
    SetOnlineStatusParams params,
  ) {
    return repository.setOnlineStatus(isOnline: params.isOnline);
  }
}
