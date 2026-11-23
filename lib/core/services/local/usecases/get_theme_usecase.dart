// lib/core/services/local/usecases/get_theme_usecase.dart
import 'package:dartz/dartz.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';

/// Returns the persisted theme mode string ("light" | "dark" | "system"), or
/// `null` if never explicitly set (the app should fall back to "system").
///
/// Called on app start to restore the user's brightness preference before
/// the first frame is rendered, preventing a flash of the wrong theme.
class GetThemeUseCase implements UseCase<String?, NoParams> {
  const GetThemeUseCase({required this.preferencesService});

  final AppPreferencesService preferencesService;

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    try {
      return Right(preferencesService.getThemeMode());
    } catch (e) {
      return Left(CacheFailure('Failed to read theme mode: $e'));
    }
  }
}
