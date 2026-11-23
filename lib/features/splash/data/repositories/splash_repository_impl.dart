// lib/features/splash/data/repositories/splash_repository_impl.dart
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';
import 'package:routex_mobile/features/splash/domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  const SplashRepositoryImpl(this.preferencesService);

  final AppPreferencesService preferencesService;

  @override
  bool isOnboardingCompleted() => preferencesService.isOnboardingCompleted();

  @override
  Future<bool> setOnboardingCompleted(bool value) =>
      preferencesService.setOnboardingCompleted(value);
}
