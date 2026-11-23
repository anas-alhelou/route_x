import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';

/// Base class inherited by every use case in the project.
/// Type   = the return type on success
/// Params = the input parameters type
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Used when a use case does not require any parameters
class NoParams {
  const NoParams();
}
