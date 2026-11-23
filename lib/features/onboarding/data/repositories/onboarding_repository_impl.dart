import 'package:routex_mobile/core/services/local/app_preferences_service.dart';
import 'package:routex_mobile/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final AppPreferencesService preferencesService;

  OnboardingRepositoryImpl(this.preferencesService);

  @override
  Future<bool> setOnboardingCompleted(bool value) =>
      preferencesService.setOnboardingCompleted(value);
}
