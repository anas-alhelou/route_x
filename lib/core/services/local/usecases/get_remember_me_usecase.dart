// lib/core/services/local/usecases/get_remember_me_usecase.dart
import 'package:dartz/dartz.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';

/// Returns the persisted "remember me" flag.
///
/// The login flow uses this on cold start:
///   - `true`  → skip the login screen and auto-navigate to the main app.
///   - `false` → show the login screen (default on first install or after
///               logout).
///
/// This is a SESSION-LEVEL preference — it is cleared together with the
/// secure session tokens when the user logs out.
class GetRememberMeUseCase implements UseCase<bool, NoParams> {
  const GetRememberMeUseCase({required this.preferencesService});

  final AppPreferencesService preferencesService;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      return Right(preferencesService.getRememberMe());
    } catch (e) {
      return Left(CacheFailure('Failed to read remember-me flag: $e'));
    }
  }
}
