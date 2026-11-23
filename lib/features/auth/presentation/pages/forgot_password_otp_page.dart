import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_auth_frame.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/dialogs/api_error_dialog.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_state.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_otp_view.dart';

/// Second step of the forgot-password flow â€” verifies the emailed 6-digit code.
///
/// Hits the same `POST /auth/verify-otp` as the signup flow, so the same
/// single-use rule applies: the boxes report their joined value on every change,
/// and each code may be sent to the backend exactly once.
class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({super.key, required this.email});

  /// The email address the reset code was sent to.
  final String email;

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  /// The last complete code this screen handed to the cubit.
  ///
  /// Submitting only on the transition to a complete code keeps a repeated
  /// report of the same six digits — from a paste, a focus change, or a digit
  /// edited and restored — from spending the single-use code twice.
  String? _submittedCode;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.step != current.step,
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success &&
            state.step == ForgotPasswordStep.reset) {
          context.pushReplacement(RoutersName.setNewPasswordScreen);
        } else if (state.status == ForgotPasswordStatus.failure) {
          final cubit = context.read<ForgotPasswordCubit>();
          // A failed verification leaves the six digits this screen submitted
          // recorded in the cubit, which is what a retry re-sends — the code is
          // single-use, so repeating it verbatim is the only attempt that can
          // succeed while it is still valid.
          context.showApiError(
            state.error,
            onRetry: () => cubit.verifyOtp(cubit.lastSubmittedCode),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ForgotPasswordCubit>();
        final isVerifying = state.status == ForgotPasswordStatus.loading;
        // Frozen once the code has been accepted: the flow has moved to the
        // reset step, so the boxes must not report anything any more.
        final isInputLocked =
            isVerifying ||
            state.step == ForgotPasswordStep.reset ||
            cubit.hasResetToken;
        return RouteXLoadingOverlay(
          isLoading: isVerifying,
          child: Scaffold(
            backgroundColor: AppColors.brandBackground,
            body: RouteXAuthFrame(
              child: AuthOtpView(
                title: context.tr.checkYourEmail,
                titleHighlight: context.tr.checkYourEmailHighlight,
                subtitle: context.tr.forgotOtpSentMessage,
                email: widget.email,
                hasError: state.status == ForgotPasswordStatus.failure,
                errorMessage: state.error,
                isLoading: isVerifying,
                isInputLocked: isInputLocked,
                canResend: state.canResend,
                remainingSeconds: state.resendSeconds,
                onCodeEntered: (code) {
                  if (isInputLocked) return;
                  cubit.codeEdited(code);
                  if (code.length == 6 && code != _submittedCode) {
                    _submittedCode = code;
                    cubit.verifyOtp(code);
                  }
                },
                onErrorReset: () {
                  if (state.status == ForgotPasswordStatus.failure) {
                    cubit.resetError();
                  }
                },
                onResendTapped: state.canResend
                    ? () => cubit.resendOtp()
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
