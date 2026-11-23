import 'package:routex_mobile/features/onboarding/domain/repositories/onboarding_repository.dart';

class SetOnboardingCompletedUseCase {
  final OnboardingRepository repository;

  SetOnboardingCompletedUseCase(this.repository);

  Future<bool> call(bool value) => repository.setOnboardingCompleted(value);
}
