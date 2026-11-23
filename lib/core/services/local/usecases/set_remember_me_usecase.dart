// lib/core/services/local/usecases/set_remember_me_usecase.dart
import 'package:dartz/dartz.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';

/// Persists [value] as the "remember me" flag.
///
/// Called by the login feature when the user toggles the "remember me"
/// checkbox. The LoginBloc passes the checkbox state here via its UseCase —
/// it never writes to SharedPreferences directly.
///
/// This is a SESSION-LEVEL preference — cleared by
/// [ClearUserPreferencesUseCase] on logout, independent of app-level
/// preferences (language, theme).
class SetRememberMeUseCase implements UseCase<bool, SetRememberMeParams> {
  const SetRememberMeUseCase({required this.preferencesService});

  final AppPreferencesService preferencesService;

  @override
  Future<Either<Failure, bool>> call(SetRememberMeParams params) async {
    try {
      final success = await preferencesService.setRememberMe(params.value);
      return Right(success);
    } catch (e) {
      return Left(CacheFailure('Failed to save remember-me flag: $e'));
    }
  }
}

class SetRememberMeParams {
  const SetRememberMeParams({required this.value});
  final bool value;
}
