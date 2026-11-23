import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/pages/signup_flow_page.dart';

void main() {
  final step2 = SignupState.initial().copyWith(currentStep: 2);

  test('a successful registration opens the OTP screen', () {
    final loading = step2.copyWith(status: SignupStatus.loading);
    final registered = loading.copyWith(status: SignupStatus.registered);
    expect(shouldHandleStepChange(loading, registered), isTrue);
  });

  test('staying registered does not fire a second time', () {
    final registered = step2.copyWith(status: SignupStatus.registered);
    expect(shouldHandleStepChange(registered, registered), isFalse);
  });

  test('loading and failure on step 2 do not navigate', () {
    final loading = step2.copyWith(status: SignupStatus.loading);
    expect(shouldHandleStepChange(step2, loading), isFalse);
    expect(
      shouldHandleStepChange(
        loading,
        loading.copyWith(status: SignupStatus.failure),
      ),
      isFalse,
    );
  });

  test('moving to another step still counts', () {
    final step1 = SignupState.initial();
    expect(shouldHandleStepChange(step1, step1.copyWith(currentStep: 2)), isTrue);
  });
}
