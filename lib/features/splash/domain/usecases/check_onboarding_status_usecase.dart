import 'package:routex_mobile/features/splash/domain/repositories/splash_repository.dart';

class CheckOnboardingStatusUseCase {
  final SplashRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  bool call() => repository.isOnboardingCompleted();
}
