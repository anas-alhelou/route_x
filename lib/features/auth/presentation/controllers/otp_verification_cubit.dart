import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'otp_verification_state.dart';

/// Owns the post-signup email-verification screen's state.
///
/// The 6-digit code is verified against the backend via [VerifyOtpUseCase];
/// a successful verification activates the account and returns a persisted
/// session, at which point the UI routes to the "you're all set" screen.
///
/// The OTP is **single-use**: the backend answers a second request with the
/// same code — and any code at all after the account is active — with
/// "Invalid or expired verification code". This cubit therefore submits each
/// distinct six-digit value exactly once per screen (see [verifyOtp]).
///
/// The resend countdown deliberately lives *outside* [state], in
/// [resendCountdown]: a `Timer.periodic` that emitted a status every second
/// overwrote Loading / Success / Failure with `OtpVerificationInitial`, which
/// is what turned a successful verification into a visible error.
class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  OtpVerificationCubit({required this.verifyOtpUseCase, required this.email})
    : super(const OtpVerificationInitial()) {
    _startTimer();
  }

  /// Runs the real `POST /auth/verify-otp` call.
  final VerifyOtpUseCase verifyOtpUseCase;

  /// Email the verification code was sent to.
  final String email;

  /// Live resend cooldown, in seconds, counting down from [_resendCooldown].
  ///
  /// Held in a [ValueNotifier] rather than in [state] so that ticking it can
  /// never change the verification status. The page rebuilds the countdown row
  /// from this notifier alone.
  final ValueNotifier<int> resendCountdown = ValueNotifier<int>(
    _resendCooldown,
  );

  /// Seconds a freshly issued code must be left alone before resending.
  static const int _resendCooldown = 30;

  /// Whether a resend request can actually be issued right now.
  ///
  /// Permanently false today: no resend endpoint has been confirmed with the
  /// backend, and there is nothing honest this screen could do about it. The
  /// countdown itself keeps ticking (it still reports how long ago the code was
  /// sent), but the "Resend code" action stays disabled instead of pretending a
  /// new code was delivered.
  ///
  /// TODO(auth): once the backend answers with the resend contract, add the
  /// endpoint + data-source method + use case, set this to true, and wire the
  /// action to a real call. Until then nothing is sent and no confirmation is
  /// shown.
  static const bool isResendSupported = false;

  /// True while a `POST /auth/verify-otp` request is in flight.
  ///
  /// The OTP is single-use, so a second request for the same code is answered
  /// with "Invalid or expired verification code". This flag makes
  /// [verifyOtp] a no-op while one request is already running.
  bool _isVerifying = false;

  /// The last code handed to the backend, whether it was accepted or rejected.
  ///
  /// Doubles as the "already spent" lock. A code identical to this one is
  /// ignored until the user types a *different* one (see [codeEdited]), so a
  /// duplicate notification — a paste, an autofill, a focus change, or digits
  /// edited and then restored — cannot consume the code a second time and
  /// produce "Invalid or expired verification code" right after a success.
  String _lastSubmittedCode = '';

  /// The code the last [verifyOtp] was given, or `''` if none was.
  ///
  /// Exposed for diagnostics and tests; the failure dialog no longer retries.
  String get lastSubmittedCode => _lastSubmittedCode;

  /// Drives the resend cooldown. Held here rather than inline in
  /// [_startTimer] so [close] can always cancel it.
  Timer? _timer;

  /// Seconds left before the resend action becomes available.
  int get remainingSeconds => resendCountdown.value;

  /// Whether the resend action is currently usable.
  bool get canResend => isResendSupported && resendCountdown.value <= 0;

  /// Whether a verification request is currently in flight.
  bool get isVerifying => _isVerifying;

  /// Starts (or restarts) the resend cooldown on a private timer.
  ///
  /// The tick only touches [resendCountdown]; it never emits, so no status can
  /// be clobbered by a tick landing mid-request.
  void _startTimer() {
    _timer?.cancel();
    resendCountdown.value = _resendCooldown;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
        return;
      }
      timer.cancel();
    });
  }

  /// Releases the *rejected* code lock once the user types something else.
  ///
  /// Called from the page on every keystroke, with the code currently shown in
  /// the boxes. It is deliberately one-way with respect to an accepted code:
  ///
  /// * while a request is in flight, or once one has been accepted, it changes
  ///   nothing, so no amount of typing can re-open a spent OTP;
  /// * otherwise it clears the lock only when [code] differs from the rejected
  ///   value, which is what lets a mistyped code be corrected and retried while
  ///   keeping an already-rejected one from being re-sent verbatim.
  void codeEdited(String code) {
    if (_isVerifying || _hasSucceeded) return;
    resetError();
    if (code.trim() != _lastSubmittedCode) {
      _lastSubmittedCode = '';
    }
  }

  /// Verifies [code] against the backend, at most once per distinct input.
  ///
  /// Guards, in order:
  /// * the code must be exactly six digits;
  /// * the code must not have been accepted already on this screen — the
  ///   account is active and the OTP has been consumed, so no further request
  ///   can succeed;
  /// * a request must not already be in flight ([_isVerifying]);
  /// * the same six digits must not have been submitted before
  ///   ([_lastSubmittedCode]), which covers both a duplicate notification and a
  ///   verbatim retry of a rejected code.
  ///
  /// [OtpVerificationSuccess] is emitted exactly once per accepted submission,
  /// so the page navigates away exactly once.
  Future<void> verifyOtp(String code) async {
    final normalizedCode = code.trim();

    // Only a complete, six-digit code is worth a round-trip.
    if (normalizedCode.length != 6) return;

    // Already verified: the account is active and this OTP is spent. Every
    // later call is a no-op, whatever `codeEdited` did in the meantime.
    if (_hasSucceeded) return;

    // A request is already running: this is a duplicate keystroke-driven
    // submit, not a new intent.
    if (_isVerifying) return;

    // This exact code has already been sent — accepted before, or rejected and
    // not yet corrected. Re-sending it would be rejected by the backend for
    // being single-use, and turned a working flow into a visible error.
    if (normalizedCode == _lastSubmittedCode) return;

    _isVerifying = true;
    _lastSubmittedCode = normalizedCode;
    if (!isClosed) emit(OtpVerificationLoading(code: normalizedCode));

    final result = await verifyOtpUseCase(
      VerifyOtpParams(email: email, otp: normalizedCode),
    );

    if (isClosed) {
      _isVerifying = false;
      return;
    }

    result.fold(
      (failure) {
        _log('rejected (${failure.message})');
        _isVerifying = false;
        // `_lastSubmittedCode` deliberately keeps the rejected code: it is the
        // lock that stops the very same value from being sent again. Only a
        // *different* code (through [codeEdited]) opens the field back up.
        emit(
          OtpVerificationFailure(
            errorMessage: failure.message,
            code: normalizedCode,
          ),
        );
      },
      (session) {
        _log('accepted');
        _isVerifying = false;
        emit(
          OtpVerificationSuccess(
            code: normalizedCode,
            hasSession: session.tokens.accessToken.trim().isNotEmpty,
          ),
        );
      },
    );
  }

  /// Whether a verification has already been accepted on this screen.
  bool get _hasSucceeded => state is OtpVerificationSuccess;

  /// Debug-only breadcrumb for the single request this screen makes.
  ///
  /// Never logs the code or any token: only whether the backend accepted the
  /// submission and, on rejection, the safe message the mapper produced.
  void _log(String outcome) {
    if (!kDebugMode) return;
    developer.log(
      'POST /auth/verify-otp $outcome for $email',
      name: 'OtpVerificationCubit',
    );
  }

  /// Clears a rejection so the field can be corrected.
  void resetError() {
    if (state is OtpVerificationFailure) {
      emit(OtpVerificationInitial(code: state.code));
    }
  }

  /// Bumped every time the user acknowledges a failure, so the input row knows
  /// it must wipe its boxes and refocus the first one.
  ///
  /// A plain counter (not part of [state]) because it is only meaningful as a
  /// *change*: typing after a failure also clears the error, but must never wipe
  /// what was typed.
  int get inputResetEpoch => _inputResetEpoch;
  int _inputResetEpoch = 0;

  /// The user dismissed the failure dialog ("Try again").
  ///
  /// Purely local: clears the error and asks the input to reset. It never calls
  /// the verify use case, never resends and never navigates. A no-op unless a
  /// failure is currently showing, so a late or duplicate dismissal is harmless.
  void errorAcknowledged() {
    if (isClosed || state is! OtpVerificationFailure) return;
    _inputResetEpoch++;
    emit(const OtpVerificationInitial());
  }

  /// Stops the cooldown timer and releases the notifier it wrote to.
  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    resendCountdown.dispose();
    return super.close();
  }
}
