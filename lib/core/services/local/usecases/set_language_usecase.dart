// lib/core/services/local/usecases/set_language_usecase.dart
import 'package:dartz/dartz.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';

/// Persists [languageCode] as the active locale preference.
///
/// Called by the settings feature whenever the user picks a new language.
/// Returns [Right(true)] on success, [Left(CacheFailure)] on write error.
class SetLanguageUseCase implements UseCase<bool, SetLanguageParams> {
  const SetLanguageUseCase({required this.preferencesService});

  final AppPreferencesService preferencesService;

  @override
  Future<Either<Failure, bool>> call(SetLanguageParams params) async {
    try {
      final success =
          await preferencesService.setLanguageCode(params.languageCode);
      return Right(success);
    } catch (e) {
      return Left(CacheFailure('Failed to save language code: $e'));
    }
  }
}

class SetLanguageParams {
  const SetLanguageParams({required this.languageCode});
  final String languageCode;
}
