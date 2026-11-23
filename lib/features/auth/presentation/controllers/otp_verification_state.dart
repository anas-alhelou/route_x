/// State of email OTP verification. Every variant carries the current
/// [code]; [OtpVerificationFailure] additionally reports an error message
/// suitable for localization.
///
/// The resend countdown is deliberately *not* part of this state: it ticks once
/// a second, so folding it in here would overwrite the in-flight / outcome
/// variant every second. It lives in the cubit's `resendCountdown` notifier
/// instead.
sealed class OtpVerificationState {
  const OtpVerificationState({this.code = ''});

  /// Six-digit code currently entered by the user.
  final String code;
}

class OtpVerificationInitial extends OtpVerificationState {
  const OtpVerificationInitial({super.code = ''});
}

/// The verification request is in flight against the backend.
class OtpVerificationLoading extends OtpVerificationState {
  const OtpVerificationLoading({required super.code});
}

/// The code was confirmed by the backend and the account is now active.
///
/// Emitted once per accepted submission, which is what drives the single
/// navigation to the "you're all set" screen.
class OtpVerificationSuccess extends OtpVerificationState {
  const OtpVerificationSuccess({required super.code, required this.hasSession});

  /// Whether a usable session was issued along with the activation.
  ///
  /// False for a 2xx whose body carried no tokens: the account is verified, but
  /// there is nothing to sign in with, so the next screen must send the user to
  /// the login form instead of straight into the app.
  final bool hasSession;
}

/// Verification failed with a localized [OtpVerificationFailure.errorMessage].
class OtpVerificationFailure extends OtpVerificationState {
  const OtpVerificationFailure({
    required this.errorMessage,
    required super.code,
  });

  /// Message displayed to the user when verification fails.
  final String errorMessage;
}
