import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('ForgotPasswordCubit', () {
    late _MockAuthRepository repo;
    late ForgotPasswordCubit cubit;

    setUp(() {
      repo = _MockAuthRepository();
      cubit = ForgotPasswordCubit(
        forgotPasswordUseCase: ForgotPasswordUseCase(repository: repo),
        verifyResetOtpUseCase: VerifyResetOtpUseCase(repository: repo),
        resetPasswordUseCase: ResetPasswordUseCase(repository: repo),
      );
    });

    tearDown(() => cubit.close());

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'wrong OTP stays on OTP screen with error',
      build: () {
        when(
          () => repo.forgotPassword(email: any(named: 'email')),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => repo.verifyResetOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer(
          (_) async => const Left(
            ServerFailure('Invalid or expired verification code.'),
          ),
        );
        return cubit;
      },
      act: (c) async {
        await c.submitEmail('user@example.com');
        await c.verifyOtp('000000');
      },
      verify: (_) {
        expect(cubit.state.step, ForgotPasswordStep.otp);
        expect(cubit.state.status, ForgotPasswordStatus.failure);
        expect(cubit.hasResetToken, isFalse);
        verify(
          () => repo.verifyResetOtp(email: 'user@example.com', otp: '000000'),
        ).called(1);
      },
    );

    test('correct OTP advances to reset step with token', () async {
      when(
        () => repo.forgotPassword(email: any(named: 'email')),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => repo.verifyResetOtp(
          email: any(named: 'email'),
          otp: any(named: 'otp'),
        ),
      ).thenAnswer((_) async => const Right('abc-reset-token'));

      await cubit.submitEmail('user@example.com');
      await cubit.verifyOtp('499592');

      expect(cubit.state.step, ForgotPasswordStep.reset);
      expect(cubit.state.status, ForgotPasswordStatus.success);
      expect(cubit.hasResetToken, isTrue);
    });

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'network failure during verify shows error and is retryable',
      build: () {
        when(
          () => repo.forgotPassword(email: any(named: 'email')),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => repo.verifyResetOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => const Left(NetworkFailure()));
        return cubit;
      },
      act: (c) async {
        await c.submitEmail('user@example.com');
        await c.verifyOtp('499592');
      },
      verify: (_) {
        expect(cubit.state.step, ForgotPasswordStep.otp);
        expect(cubit.state.status, ForgotPasswordStatus.failure);
        expect(cubit.hasResetToken, isFalse);
      },
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'reset() clears token and emits initial state',
      build: () {
        when(
          () => repo.forgotPassword(email: any(named: 'email')),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => repo.verifyResetOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => const Right('tok'));
        return cubit;
      },
      act: (c) async {
        await c.submitEmail('user@example.com');
        await c.verifyOtp('499592');
        c.reset();
      },
      verify: (_) {
        expect(cubit.state, const ForgotPasswordState());
        expect(cubit.hasResetToken, isFalse);
      },
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'resetPassword uses stored resetToken not the OTP',
      build: () {
        when(
          () => repo.forgotPassword(email: any(named: 'email')),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => repo.verifyResetOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => const Right('real-reset-token-xyz'));
        when(
          () => repo.resetPassword(
            resetToken: any(named: 'resetToken'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (c) async {
        await c.submitEmail('user@example.com');
        await c.verifyOtp('499592');
        await c.resetPassword('A!1111111');
      },
      verify: (_) {
        verify(
          () => repo.resetPassword(
            resetToken: 'real-reset-token-xyz',
            newPassword: 'A!1111111',
          ),
        ).called(1);
        verifyNever(
          () => repo.resetPassword(
            resetToken: '499592',
            newPassword: any(named: 'newPassword'),
          ),
        );
      },
    );
  });
}
