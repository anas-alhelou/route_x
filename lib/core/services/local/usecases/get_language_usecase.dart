// lib/core/services/local/usecases/get_language_usecase.dart
import 'package:dartz/dartz.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';

/// Returns the persisted language code (e.g. "en", "ar"), or `null` if the
/// user has never explicitly set a language (fall back to device locale).
///
/// Wraps the synchronous [AppPreferencesService.getLanguageCode] in Either so
/// the BLoC/Cubit layer receives a consistent [Either<Failure, String?>] and
/// is never exposed to raw storage exceptions.
class GetLanguageUseCase implements UseCase<String?, NoParams> {
  const GetLanguageUseCase({required this.preferencesService});

  final AppPreferencesService preferencesService;

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    try {
      return Right(preferencesService.getLanguageCode());
    } catch (e) {
      return Left(CacheFailure('Failed to read language code: $e'));
    }
  }
}
