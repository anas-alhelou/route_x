import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:routex_mobile/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';

import 'forgot_password_state.dart';

/// Orchestrates the forgot-password flow: email -> verify-otp -> set new password.
///
/// The OTP is always verified by the backend; only a valid code moves the flow
/// forward to the password-reset screen.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({
    required this.forgotPasswordUseCase,
    required this.verifyResetOtpUseCase,
    required this.resetPasswordUseCase,
  }) : super(const ForgotPasswordState());

  /// Sends `POST /auth/forgot-password`.
  final ForgotPasswordUseCase forgotPasswordUseCase;

  /// Verifies the OTP via `POST /auth/verify-otp` and returns `resetToken`.
  final VerifyResetOtpUseCase verifyResetOtpUseCase;

  /// Applies the new password via `POST /auth/reset-password`.
  final ResetPasswordUseCase resetPasswordUseCase;

  Timer? _timer;

  /// In-memory reset token from the verify response. Never persisted.
  String? _resetToken;

  /// Whether the reset token from a successful verification is available.
  bool get hasResetToken => _resetToken != null && _resetToken!.isNotEmpty;

  /// The last code sent to `POST /auth/verify-otp` on this screen.
  ///
  /// The reset OTP is single-use, exactly like the signup one, so a second
  /// request for the same code is answered with "Invalid or expired
  /// verification code". Holding the code that was sent keeps a duplicate
  /// notification — the six boxes report their joined value on every change, so
  /// a paste, a focus change, or a digit edited and restored all repeat the
  /// same value — from consuming it twice. It is released only when the user
  /// types something different (see [codeEdited]).
  String _lastSubmittedCode = '';

  /// The code the last [verifyOtp] was given, or `''` if none was.
  ///
  /// Exposed so the screen can offer a retry that repeats the *same* attempt
  /// rather than guessing: the code is single-use, so only the exact value that
  /// just failed can still be worth submitting, and any edit has already
  /// released it.
  String get lastSubmittedCode => _lastSubmittedCode;

  /// True while a `POST /auth/verify-otp` request is in flight.
  bool _isVerifying = false;

  /// Releases the *rejected* code lock once the user types a different code.
  ///
  /// Called on every keystroke. It cannot re-open a code that was already
  /// accepted: once [hasResetToken] is set the flow has moved past this screen
  /// and any further request would only be rejected.
  void codeEdited(String code) {
    if (_isVerifying || hasResetToken) return;
    resetError();
    if (code.trim() != _lastSubmittedCode) {
      _lastSubmittedCode = '';
    }
  }

  /// Requests a reset code for [email] and starts the resend cooldown.
  Future<void> submitEmail(String email) async {
    final error = AuthValidators.validateEmail(email);
    if (error != null) {
      emit(
        state.copyWith(
          step: ForgotPasswordStep.email,
          status: ForgotPasswordStatus.failure,
          error: error,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: ForgotPasswordStep.email,
        status: ForgotPasswordStatus.loading,
        email: email.trim(),
        error: '',
      ),
    );

    final result = await forgotPasswordUseCase(state.email);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          step: ForgotPasswordStep.email,
          status: ForgotPasswordStatus.failure,
          error: failure.message,
        ),
      ),
      (_) {
        _resetToken = null;
        // A freshly issued code supersedes whatever was sent before it.
        _lastSubmittedCode = '';
        _startTimer();
        emit(
          state.copyWith(
            step: ForgotPasswordStep.otp,
            status: ForgotPasswordStatus.success,
            error: '',
            resendSeconds: 30,
          ),
        );
      },
    );
  }

  /// Verifies [code] with the backend and advances only on success.
  ///
  /// Guards, in order: no other request is in flight (a resend or a second
  /// attempt, both of which put this flow in `loading`), the flow must not have
  /// moved past the OTP step ([hasResetToken]), and the same six digits must not
  /// have been sent before ([_lastSubmittedCode]). Together they keep the
  /// single-use code from being consumed twice by a repeated input event.
  ///
  /// The lock is deliberately per last value rather than a set of every value
  /// ever submitted: a failure here is not always a rejection, so a timeout or a
  /// 500 must leave the user able to retry the same code. Only the value they
  /// just tried is blocked, and [codeEdited] frees it the moment they type
  /// something different.
  Future<void> verifyOtp(String code) async {
    if (_isVerifying) return;
    if (state.status == ForgotPasswordStatus.loading) return;
    if (hasResetToken) return;

    final error = AuthValidators.validateOtp(code);
    if (error != null) {
      emit(
        state.copyWith(
          step: ForgotPasswordStep.otp,
          status: ForgotPasswordStatus.failure,
          error: error,
        ),
      );
      return;
    }

    if (code.trim() == _lastSubmittedCode) return;

    _timer?.cancel();
    _isVerifying = true;
    _lastSubmittedCode = code.trim();
    emit(
      state.copyWith(
        step: ForgotPasswordStep.otp,
        status: ForgotPasswordStatus.loading,
        error: '',
        resendSeconds: 0,
      ),
    );

    final result = await verifyResetOtpUseCase(
      VerifyResetOtpParams(email: state.email, otp: code),
    );
    if (isClosed) {
      _isVerifying = false;
      return;
    }
    _isVerifying = false;

    result.fold(
      (failure) => emit(
        state.copyWith(
          step: ForgotPasswordStep.otp,
          status: ForgotPasswordStatus.failure,
          error: failure.message,
        ),
      ),
      (token) {
        _resetToken = token;
        _lastSubmittedCode = '';
        _timer?.cancel();
        emit(
          state.copyWith(
            step: ForgotPasswordStep.reset,
            status: ForgotPasswordStatus.success,
            error: '',
          ),
        );
      },
    );
  }

  /// Re-requests a code and restarts the cooldown.
  Future<void> resendOtp() async {
    if (_isVerifying) return;

    emit(
      state.copyWith(
        step: ForgotPasswordStep.otp,
        status: ForgotPasswordStatus.loading,
        error: '',
      ),
    );

    final result = await forgotPasswordUseCase(state.email);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          step: ForgotPasswordStep.otp,
          status: ForgotPasswordStatus.failure,
          error: failure.message,
        ),
      ),
      (_) {
        _startTimer();
        // The resend invalidated the previous code, so its lock goes too.
        _lastSubmittedCode = '';
        emit(
          state.copyWith(
            step: ForgotPasswordStep.otp,
            status: ForgotPasswordStatus.success,
            error: '',
          ),
        );
      },
    );
  }

  /// Applies [newPassword] using the stored reset token.
  Future<void> resetPassword(String newPassword) async {
    if (!hasResetToken) {
      emit(
        state.copyWith(
          step: ForgotPasswordStep.reset,
          status: ForgotPasswordStatus.failure,
          error: 'errResetTokenRequired',
        ),
      );
      return;
    }

    final error = AuthValidators.validateStrongPassword(newPassword);
    if (error != null) {
      emit(
        state.copyWith(
          step: ForgotPasswordStep.reset,
          status: ForgotPasswordStatus.failure,
          error: error,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: ForgotPasswordStep.reset,
        status: ForgotPasswordStatus.loading,
        error: '',
      ),
    );

    final result = await resetPasswordUseCase(
      ResetPasswordParams(
        resetToken: _resetToken ?? '',
        newPassword: newPassword,
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          step: ForgotPasswordStep.reset,
          status: ForgotPasswordStatus.failure,
          error: failure.message,
        ),
      ),
      (_) {
        _resetToken = null;
        emit(
          state.copyWith(
            step: ForgotPasswordStep.reset,
            status: ForgotPasswordStatus.success,
          ),
        );
      },
    );
  }

  /// Clears error state so the OTP boxes reset.
  void resetError() {
    if (state.status == ForgotPasswordStatus.failure) {
      emit(state.copyWith(status: ForgotPasswordStatus.initial));
    }
  }

  /// Resets the whole flow (cancel timer, clear token, emit initial state).
  void reset() {
    _stopTimer();
    _resetToken = null;
    _lastSubmittedCode = '';
    emit(const ForgotPasswordState());
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      final next = state.resendSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        emit(state.copyWith(resendSeconds: 0));
      } else {
        emit(state.copyWith(resendSeconds: next));
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    if (!isClosed) emit(state.copyWith(resendSeconds: 0));
  }

  @override
  Future<void> close() {
    _resetToken = null;
    _timer?.cancel();
    return super.close();
  }
}
