import 'package:equatable/equatable.dart';

/// Flow stage of the forgot-password journey.
enum ForgotPasswordStep { email, otp, reset }

/// Lifecycle status of the current async operation.
enum ForgotPasswordStatus { initial, loading, success, failure }

/// Snapshot of the forgot-password flow: which screen is active
/// ([step]), the status of the in-flight request, the captured email and
/// any validation/error key.
class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.step = ForgotPasswordStep.email,
    this.status = ForgotPasswordStatus.initial,
    this.email = '',
    this.error = '',
    this.resendSeconds = 0,
  });

  /// Which screen the flow is currently on.
  final ForgotPasswordStep step;

  /// Status of the in-flight request.
  final ForgotPasswordStatus status;

  /// Email address captured from the first screen.
  final String email;

  /// Raw validation/error key (see [AuthValidators] and `tr_extension`).
  final String error;

  /// Seconds remaining in the resend cooldown.
  final int resendSeconds;

  /// Whether the user can resend the code right now.
  bool get canResend => resendSeconds <= 0;

  @override
  List<Object?> get props => [step, status, email, error, resendSeconds];

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    ForgotPasswordStatus? status,
    String? email,
    String? error,
    int? resendSeconds,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      status: status ?? this.status,
      email: email ?? this.email,
      error: error ?? this.error,
      resendSeconds: resendSeconds ?? this.resendSeconds,
    );
  }
}
