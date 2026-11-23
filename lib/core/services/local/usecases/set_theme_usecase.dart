// lib/core/services/local/usecases/set_theme_usecase.dart
import 'package:dartz/dartz.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';

/// Persists [themeMode] as the active brightness preference.
///
/// Valid values for [SetThemeParams.themeMode]:
///   - "light"  → [ThemeMode.light]
///   - "dark"   → [ThemeMode.dark]
///   - "system" → [ThemeMode.system]
///
/// The string-to-ThemeMode mapping lives in the settings Cubit, not here,
/// keeping this UseCase framework-agnostic and independently testable.
class SetThemeUseCase implements UseCase<bool, SetThemeParams> {
  const SetThemeUseCase({required this.preferencesService});

  final AppPreferencesService preferencesService;

  @override
  Future<Either<Failure, bool>> call(SetThemeParams params) async {
    try {
      final success = await preferencesService.setThemeMode(params.themeMode);
      return Right(success);
    } catch (e) {
      return Left(CacheFailure('Failed to save theme mode: $e'));
    }
  }
}

class SetThemeParams {
  const SetThemeParams({required this.themeMode});

  /// One of "light", "dark", or "system".
  final String themeMode;
}
