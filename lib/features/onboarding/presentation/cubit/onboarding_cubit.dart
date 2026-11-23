import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/features/onboarding/domain/usecases/set_onboarding_completed_usecase.dart';

class OnboardingCubit extends Cubit<void> {
  final SetOnboardingCompletedUseCase setOnboardingCompletedUseCase;

  OnboardingCubit(this.setOnboardingCompletedUseCase) : super(null);

  Future<void> completeOnboarding() async {
    await setOnboardingCompletedUseCase(true);
  }
}
