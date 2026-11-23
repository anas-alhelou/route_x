// lib/features/splash/domain/repositories/splash_repository.dart
abstract class SplashRepository {
  bool isOnboardingCompleted();
  Future<bool> setOnboardingCompleted(bool value);
}
