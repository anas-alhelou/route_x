// test/otp_verification_cubit_test.dart
// Regression guards for the post-signup OTP screen reporting an error for a
// correct code. Every test here corresponds to one of the causes:
// the resend timer overwriting the status, a duplicate submit consuming the
// single-use OTP, and success being decided by the presence of `tokens`.
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_role.dart';
import 'package:routex_mobile/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/otp_verification_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/otp_verification_state.dart';

/// What a stubbed verification answers with.
typedef _Outcome = Future<Either<Failure, AuthSessionEntity>> Function();

/// Records every [VerifyOtpUseCase] call so a duplicate submit is observable.
///
/// The repository is deliberately never used: the guards under test live in the
/// cubit, so a fake of the *use case* is the right seam. It answers after
/// [delay] to leave a real window in which a duplicate submit can arrive.
///
/// [responses] is consumed one entry per call, so a test can reject the first
/// attempt and accept the next; the last entry answers every call after that.
class _CountingVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {
  _CountingVerifyOtpUseCase(this.responses, {this.delay});

  /// What each successive call answers with.
  final List<_Outcome> responses;

  /// How long each call stays in flight before answering.
  final Duration? delay;

  /// Every params value this fake was called with, in order.
  final List<VerifyOtpParams> calls = [];

  @override
  Future<Either<Failure, AuthSessionEntity>> call(
    VerifyOtpParams params,
  ) async {
    calls.add(params);
    final wait = delay;
    if (wait != null) await Future<void>.delayed(wait);
    final index = calls.length - 1;
    return (index < responses.length ? responses[index] : responses.last)();
  }
}

/// The usual successful verification.
AuthSessionEntity _session() => AuthSessionEntity(
  user: const UserEntity(
    id: 'user-1',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    role: UserRole.driver,
  ),
  tokens: const AuthTokensEntity(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  ),
);

/// A verified account with no session: a 2xx whose body carried no `tokens`.
AuthSessionEntity _sessionWithoutTokens() => AuthSessionEntity(
  user: const UserEntity(
    id: '',
    firstName: '',
    lastName: '',
    email: 'john@example.com',
    role: UserRole.driver,
  ),
  tokens: const AuthTokensEntity(accessToken: '', refreshToken: ''),
);

/// What the endpoint answers for a wrong, expired or already-used code.
Future<Either<Failure, AuthSessionEntity>> _rejected() async =>
    const Left(ValidationFailure('Invalid or expired code'));

const String _email = 'john@example.com';
const String _code = '123456';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const VerifyOtpParams(email: 'a@b.com', otp: '000000'),
    );
  });

  group('resend countdown stays out of the status', () {
    test('a tick never overwrites an in-flight request', () async {
      // The request is deliberately slower than the cooldown ticks that land
      // while it runs, which is the exact interleaving that used to overwrite
      // the status and turn a correct code into a visible error.
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ], delay: const Duration(milliseconds: 1500));
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      final emitted = <OtpVerificationState>[];
      final subscription = cubit.stream.listen(emitted.add);

      final pending = cubit.verifyOtp(_code);
      expect(cubit.state, isA<OtpVerificationLoading>());

      // Three ticks land while the request is still in flight.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(
        cubit.state,
        isA<OtpVerificationLoading>(),
        reason: 'the countdown must not replace the loading status',
      );

      await pending;
      expect(cubit.state, isA<OtpVerificationSuccess>());

      await Future<void>.delayed(const Duration(milliseconds: 2200));
      expect(
        cubit.state,
        isA<OtpVerificationSuccess>(),
        reason: 'ticks after the outcome must not reset it either',
      );
      expect(
        emitted.whereType<OtpVerificationInitial>(),
        isEmpty,
        reason: 'no tick may emit at all',
      );

      await subscription.cancel();
    });

    test('ticks only move the countdown, never the emitted status', () async {
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      final emitted = <OtpVerificationState>[];
      final subscription = cubit.stream.listen(emitted.add);

      expect(cubit.canResend, isFalse);
      expect(cubit.remainingSeconds, 30);

      await Future<void>.delayed(const Duration(milliseconds: 2100));
      expect(cubit.remainingSeconds, lessThan(30));
      expect(
        emitted,
        isEmpty,
        reason: 'the countdown alone is not a state change',
      );

      await subscription.cancel();
    });

    test('closing the cubit stops the countdown timer', () async {
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );

      expect(cubit.canResend, isFalse);
      await cubit.close();

      // A cancelled timer never fires again, so nothing is written to the
      // disposed notifier (which would otherwise throw).
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      expect(cubit.isClosed, isTrue);
    });
  });

  group('resend is honest while no endpoint exists', () {
    test('the countdown runs but the action stays unavailable', () async {
      // No resend endpoint has been confirmed with the backend, so there is
      // nothing to call. The action must not pretend otherwise: it stays
      // unavailable even once the cooldown has elapsed, and the screen has no
      // way to announce a code that was never sent.
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      expect(OtpVerificationCubit.isResendSupported, isFalse);
      expect(cubit.canResend, isFalse);
      expect(cubit.remainingSeconds, 30);

      // With the cooldown elapsed the countdown reads zero — and the action is
      // still off, because there is no request that could be made.
      cubit.resendCountdown.value = 0;
      expect(cubit.remainingSeconds, 0);
      expect(
        cubit.canResend,
        isFalse,
        reason:
            'a completed cooldown must not enable a call that cannot be made',
      );
    });
  });

  group('a single-use code is submitted once', () {
    test('concurrent submits send exactly ONE request', () async {
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ], delay: const Duration(milliseconds: 30));
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      // Three submits of the same complete code while the first is in flight,
      // exactly as repeated `onCodeEntered` callbacks produce.
      final first = cubit.verifyOtp(_code);
      final second = cubit.verifyOtp(_code);
      final third = cubit.verifyOtp(_code);

      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(
        useCase.calls.length,
        1,
        reason: 'the OTP is single-use: one code must mean one request',
      );

      await Future<void>.delayed(const Duration(milliseconds: 400));
      await Future.wait([first, second, third]);

      expect(useCase.calls.length, 1);
      expect(cubit.state, isA<OtpVerificationSuccess>());
    });

    test(
      'codeEdited during an in-flight request cannot open a second one',
      () async {
        // The page reports every keystroke and calls codeEdited before verifying,
        // so the edit hook must not be a way around the in-flight guard.
        final useCase = _CountingVerifyOtpUseCase([
          () async => Right(_session()),
        ], delay: const Duration(milliseconds: 60));
        final cubit = OtpVerificationCubit(
          verifyOtpUseCase: useCase,
          email: _email,
        );
        addTearDown(cubit.close);

        final pending = cubit.verifyOtp(_code);
        // Digits edited while the request runs; the completed value is reported
        // again as soon as they are put back.
        cubit.codeEdited('12345');
        await cubit.verifyOtp(_code);
        cubit.codeEdited(_code);
        await pending;

        expect(
          useCase.calls.length,
          1,
          reason: 'nothing typed mid-request may reach the backend again',
        );
        expect(cubit.state, isA<OtpVerificationSuccess>());
      },
    );

    test('success is emitted exactly once', () async {
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      final emitted = <OtpVerificationState>[];
      final subscription = cubit.stream.listen(emitted.add);

      await cubit.verifyOtp(_code);
      // A late duplicate arriving after the outcome must not re-emit, or the
      // page would navigate to "you're all set" twice.
      await cubit.verifyOtp(_code);

      expect(
        emitted.whereType<OtpVerificationSuccess>().length,
        1,
        reason: 'the page navigates once per Success emission',
      );
      expect(useCase.calls.length, 1);

      await subscription.cancel();
    });

    test('an incomplete code is never sent', () async {
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      await cubit.verifyOtp('12345');
      await cubit.verifyOtp('1234567');
      await cubit.verifyOtp('');

      expect(useCase.calls, isEmpty);
      expect(cubit.state, isA<OtpVerificationInitial>());
    });
  });

  group('an accepted code is final for this screen', () {
    test('a duplicate submit after success is a no-op', () async {
      // The reported bug: a *correct* code verified, then a second request with
      // the same (already consumed) code came back as "Invalid or expired
      // verification code", so the user saw an error after a success.
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      final emitted = <OtpVerificationState>[];
      final subscription = cubit.stream.listen(emitted.add);

      await cubit.verifyOtp(_code);
      expect(cubit.state, isA<OtpVerificationSuccess>());

      // Every shape of duplicate the input row can produce after the success:
      // a plain repeat, one preceded by an edit, and one after the user types
      // something different.
      await cubit.verifyOtp(_code);
      cubit.codeEdited(_code);
      await cubit.verifyOtp(_code);
      cubit.codeEdited('654321');
      await cubit.verifyOtp('654321');

      expect(
        useCase.calls.length,
        1,
        reason:
            'the account is active and the OTP is spent; nothing may resend',
      );
      expect(
        emitted.whereType<OtpVerificationSuccess>().length,
        1,
        reason: 'the page navigates to "you\'re all set" exactly once',
      );
      expect(
        emitted.whereType<OtpVerificationFailure>(),
        isEmpty,
        reason: 'no failure may follow a success',
      );

      await subscription.cancel();
    });

    test('codeEdited after success does not reset the status', () async {
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      await cubit.verifyOtp(_code);
      cubit.codeEdited('999999');

      expect(
        cubit.state,
        isA<OtpVerificationSuccess>(),
        reason: 'typing cannot walk back an accepted verification',
      );
      expect(useCase.calls.length, 1);
    });
  });

  group('a rejected code can only be retried after it changes', () {
    test('re-sending the rejected code verbatim sends nothing', () async {
      final useCase = _CountingVerifyOtpUseCase([_rejected]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      await cubit.verifyOtp('111111');
      expect(cubit.state, isA<OtpVerificationFailure>());

      // The error clears the boxes and the user puts the very same code back.
      // It has already been rejected — and on this endpoint already spent — so
      // the same request would only produce the same error.
      cubit.codeEdited('111111');
      await cubit.verifyOtp('111111');

      expect(
        useCase.calls.length,
        1,
        reason: 'the rejected value must stay locked until the user changes it',
      );
    });

    test('a corrected code goes through after the user changes it', () async {
      final useCase = _CountingVerifyOtpUseCase([
        _rejected,
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      await cubit.verifyOtp('111111');
      expect(cubit.state, isA<OtpVerificationFailure>());

      // Typing a different code releases the lock and clears the error.
      cubit.codeEdited(_code);
      expect(cubit.state, isA<OtpVerificationInitial>());

      await cubit.verifyOtp(_code);

      expect(useCase.calls.length, 2);
      expect(
        useCase.calls.last,
        const VerifyOtpParams(email: _email, otp: _code),
      );
      expect(cubit.state, isA<OtpVerificationSuccess>());
    });

    test(
      'a distinct value submitted before is never sent twice either',
      () async {
        // The lock is per value: a second wrong code is a fresh attempt.
        final useCase = _CountingVerifyOtpUseCase([
          _rejected,
          _rejected,
          () async => Right(_session()),
        ]);
        final cubit = OtpVerificationCubit(
          verifyOtpUseCase: useCase,
          email: _email,
        );
        addTearDown(cubit.close);

        await cubit.verifyOtp('111111');
        cubit.codeEdited('222222');
        await cubit.verifyOtp('222222');
        cubit.codeEdited('222222');
        // Same rejected value again: still locked.
        await cubit.verifyOtp('222222');

        expect(useCase.calls.length, 2);

        cubit.codeEdited(_code);
        await cubit.verifyOtp(_code);
        expect(useCase.calls.length, 3);
        expect(cubit.state, isA<OtpVerificationSuccess>());
      },
    );
  });

  group('error acknowledgement ("Try again")', () {
    test('a wrong code sets the failure state', () async {
      final useCase = _CountingVerifyOtpUseCase([_rejected]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      await cubit.verifyOtp(_code);

      expect(cubit.state, isA<OtpVerificationFailure>());
    });

    test('errorAcknowledged clears the error without any request', () async {
      final useCase = _CountingVerifyOtpUseCase([_rejected]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      await cubit.verifyOtp(_code);
      final epoch = cubit.inputResetEpoch;
      expect(useCase.calls.length, 1);

      cubit.errorAcknowledged();

      expect(cubit.state, isA<OtpVerificationInitial>());
      expect(cubit.state.code, isEmpty);
      expect(cubit.inputResetEpoch, epoch + 1);
      expect(
        useCase.calls.length,
        1,
        reason: 'Try again must not call verify (or any resend)',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(useCase.calls.length, 1);
    });

    test('errorAcknowledged is a no-op when there is no failure', () async {
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      cubit.errorAcknowledged();
      expect(cubit.inputResetEpoch, 0);

      await cubit.verifyOtp(_code);
      cubit.errorAcknowledged();
      expect(cubit.state, isA<OtpVerificationSuccess>());
      expect(cubit.inputResetEpoch, 0);
    });

    test('typing clears the error and does not bump the reset epoch', () async {
      final useCase = _CountingVerifyOtpUseCase([_rejected]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      await cubit.verifyOtp(_code);
      expect(cubit.state, isA<OtpVerificationFailure>());

      cubit.codeEdited('1');

      expect(cubit.state, isA<OtpVerificationInitial>());
      expect(
        cubit.inputResetEpoch,
        0,
        reason: 'typing must never wipe the boxes',
      );
    });

    test('submit is ignored while a request is loading', () async {
      final useCase = _CountingVerifyOtpUseCase([
        () async => Right(_session()),
      ], delay: const Duration(milliseconds: 50));
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      final first = cubit.verifyOtp(_code);
      expect(cubit.state, isA<OtpVerificationLoading>());
      await cubit.verifyOtp('654321');
      await cubit.verifyOtp(_code);
      await first;

      expect(useCase.calls.length, 1);
      expect(useCase.calls.single.otp, _code);
    });
  });

  group('success is decided by the HTTP status, not by tokens', () {
    blocTest<OtpVerificationCubit, OtpVerificationState>(
      'a 2xx without tokens is a success, not a failure',
      build: () => OtpVerificationCubit(
        verifyOtpUseCase: _CountingVerifyOtpUseCase([
          () async => Right(_sessionWithoutTokens()),
        ]),
        email: _email,
      ),
      act: (cubit) => cubit.verifyOtp(_code),
      wait: const Duration(milliseconds: 20),
      // Matchers, not instances: these states are plain classes and compare by
      // identity, so concrete instances would never be equal to the emitted ones.
      expect: () => <Matcher>[
        isA<OtpVerificationLoading>().having((s) => s.code, 'code', _code),
        isA<OtpVerificationSuccess>()
            .having((s) => s.code, 'code', _code)
            .having((s) => s.hasSession, 'hasSession', false),
      ],
      verify: (cubit) {
        expect(cubit.state, isA<OtpVerificationSuccess>());
      },
    );

    blocTest<OtpVerificationCubit, OtpVerificationState>(
      'a 2xx with tokens reports a session',
      build: () => OtpVerificationCubit(
        verifyOtpUseCase: _CountingVerifyOtpUseCase([
          () async => Right(_session()),
        ]),
        email: _email,
      ),
      act: (cubit) => cubit.verifyOtp(_code),
      wait: const Duration(milliseconds: 20),
      expect: () => <Matcher>[
        isA<OtpVerificationLoading>().having((s) => s.code, 'code', _code),
        isA<OtpVerificationSuccess>()
            .having((s) => s.code, 'code', _code)
            .having((s) => s.hasSession, 'hasSession', true),
      ],
    );

    test('the session flag reaches the state the next screen reads', () async {
      // The "you're all set" screen branches on this: a session means continue
      // into the app, no session means go back to the login form.
      final withSession = OtpVerificationCubit(
        verifyOtpUseCase: _CountingVerifyOtpUseCase([
          () async => Right(_session()),
        ]),
        email: _email,
      );
      addTearDown(withSession.close);
      await withSession.verifyOtp(_code);
      expect((withSession.state as OtpVerificationSuccess).hasSession, isTrue);

      final withoutSession = OtpVerificationCubit(
        verifyOtpUseCase: _CountingVerifyOtpUseCase([
          () async => Right(_sessionWithoutTokens()),
        ]),
        email: _email,
      );
      addTearDown(withoutSession.close);
      await withoutSession.verifyOtp(_code);
      expect(
        (withoutSession.state as OtpVerificationSuccess).hasSession,
        isFalse,
      );
    });

    test('a rejected code still surfaces the backend message', () async {
      final useCase = _CountingVerifyOtpUseCase([_rejected]);
      final cubit = OtpVerificationCubit(
        verifyOtpUseCase: useCase,
        email: _email,
      );
      addTearDown(cubit.close);

      await cubit.verifyOtp(_code);

      expect(cubit.state, isA<OtpVerificationFailure>());
      expect(
        (cubit.state as OtpVerificationFailure).errorMessage,
        'Invalid or expired code',
      );
    });
  });
}
