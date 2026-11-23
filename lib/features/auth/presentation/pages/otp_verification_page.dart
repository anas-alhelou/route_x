import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_auth_frame.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/dialogs/api_error_dialog.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/otp_verification_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/otp_verification_state.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_otp_view.dart';
import 'package:routex_mobile/features/auth/presentation/pages/youre_all_set_page.dart';

/// Post-signup email verification screen.
///
/// Thin orchestrator: owns the [OtpVerificationCubit] wiring and delegates all
/// of the shared UI to [AuthOtpView].
class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key, required this.email});

  /// The email address the verification code was sent to.
  final String email;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  /// The last complete code this screen handed to the cubit.
  ///
  /// The six OTP boxes report their joined value on *every* change, so the same
  /// six digits reach this callback more than once: a paste fans out across
  /// boxes, a focus change re-reports the current value, and editing a digit
  /// then restoring it produces the original code a second time. Submitting on
  /// a transition only — a value that is complete *and* differs from the one
  /// already sent — keeps the single-use OTP from being consumed twice, which
  /// the backend would answer with "Invalid or expired verification code" right
  /// after a correct verification.
  String? _submittedCode;

  /// "Use a different email": return to the sign-up flow and ask it to go back
  /// to Step 1 (Your details), where the address can be corrected.
  ///
  /// The request is announced through [SignupBloc] rather than through a value
  /// handed back by the pop, so the flow shell can act on it the same way it
  /// acts on every other signup state change. It is dispatched *after* the pop
  /// has completed: the flow shell listens while still mounted underneath, and
  /// dispatching any earlier would land the request while this route is still
  /// on top.
  void _onUseDifferentEmailPressed(BuildContext context) {
    final bloc = context.read<SignupBloc?>();
    // `popped` completes once this screen is really gone, which is the right
    // moment to ask the flow shell to return to Step 1.
    final popped = ModalRoute.of(context)?.popped;
    Navigator.of(context).pop();
    popped?.then((_) {
      if (bloc == null || bloc.isClosed) return;
      bloc.add(const SignupEditProfileRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpVerificationCubit, OtpVerificationState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          context.pushReplacement(
            RoutersName.youreAllSetScreen,
            // Only the fact that a session exists travels: the next screen needs
            // to know where to send the user, never the tokens themselves.
            extra: YoureAllSetArgs(hasSession: state.hasSession),
          );
        } else if (state is OtpVerificationFailure) {
          final cubit = context.read<OtpVerificationCubit>();
          // Single "Try again" action. However the dialog closes (button, scrim
          // or back), the same call clears the error and resets the input; it
          // never repeats the request.
          context
              .showApiError(
                state.errorMessage,
                confirmLabel: context.tr.tryAgain,
              )
              .whenComplete(cubit.errorAcknowledged);
        }
      },
      builder: (context, state) {
        final cubit = context.read<OtpVerificationCubit>();
        // Input is frozen while the request is running and once it succeeded:
        // in both cases the single-use code has already been spent.
        final isInputLocked =
            state is OtpVerificationLoading || state is OtpVerificationSuccess;
        // The countdown lives outside the bloc state: listening to it here is
        // what keeps a timer tick from ever overwriting Loading / Success /
        // Failure, while still repainting the "resend in 00:xx" row.
        return ValueListenableBuilder<int>(
          valueListenable: cubit.resendCountdown,
          builder: (context, remainingSeconds, child) {
            final canResend = cubit.canResend;
            return RouteXLoadingOverlay(
              isLoading: state is OtpVerificationLoading,
              child: Scaffold(
                backgroundColor: AppColors.brandBackground,
                body: RouteXAuthFrame(
                  child: AuthOtpView(
                    title: context.tr.verifyYourEmailTitle,
                    titleHighlight: context.tr.verifyYourEmailTitleHighlight,
                    subtitle: context.tr.verificationCodeSentMessage,
                    email: widget.email,
                    showEmail: false,
                    hasError: state is OtpVerificationFailure,
                    errorMessage: state is OtpVerificationFailure
                        ? state.errorMessage
                        : null,
                    isLoading: state is OtpVerificationLoading,
                    isInputLocked: isInputLocked,
                    canResend: canResend,
                    remainingSeconds: remainingSeconds,
                    onCodeEntered: (code) {
                      // Belt to the cubit's braces: ignore anything reported
                      // while a request is running or after it was accepted.
                      if (isInputLocked) return;
                      cubit.codeEdited(code);
                      // A complete code is submitted once; dropping below six
                      // digits re-arms the page-level duplicate guard.
                      if (code.length < 6) _submittedCode = null;
                      // Submit only on the transition to a complete code, never
                      // on a repeat of one that was already sent.
                      if (code.length == 6 && code != _submittedCode) {
                        _submittedCode = code;
                        cubit.verifyOtp(code);
                      }
                    },
                    inputResetEpoch: cubit.inputResetEpoch,
                    onErrorReset: cubit.resetError,
                    // No resend request is made: [OtpVerificationCubit.canResend]
                    // stays false until the backend confirms the endpoint, so
                    // there is nothing to call and nothing to announce.
                    onResendTapped: null,
                    onUseDifferentEmailPressed: () =>
                        _onUseDifferentEmailPressed(context),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
