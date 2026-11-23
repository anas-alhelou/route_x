// lib/core/services/local/usecases/clear_user_preferences_usecase.dart
import 'package:dartz/dartz.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';

/// Clears all SESSION-LEVEL preferences (currently: "remember me").
///
/// Call this during the logout flow — alongside clearing secure storage
/// tokens — to reset the login-bypass behaviour.
///
/// APP-LEVEL preferences (language, theme) are intentionally NOT cleared
/// here. Logging out should not reset the user's display language or
/// brightness choice — those belong to the device, not the session.
///
/// If you add a new session-level preference in the future:
///   1. Add its key to [PreferenceKeys] with a comment marking it
///      SESSION-LEVEL.
///   2. Add its removal to [AppPreferencesServiceImpl.clearUserPreferences].
///   3. Update this doc comment to list the new key.
class ClearUserPreferencesUseCase implements UseCase<bool, NoParams> {
  const ClearUserPreferencesUseCase({required this.preferencesService});

  final AppPreferencesService preferencesService;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      final success = await preferencesService.clearUserPreferences();
      return Right(success);
    } catch (e) {
      return Left(CacheFailure('Failed to clear user preferences: $e'));
    }
  }
}
