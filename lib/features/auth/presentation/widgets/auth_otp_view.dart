import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_logo.dart';
import 'package:routex_mobile/core/widgets/routex_page_header.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_prompt_action_row.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_underlined_button.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/otp_code_input_row.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/signup_back_button.dart';

/// Shared OTP verification view used by both the signup and forgot-password
/// flows.
///
/// Renders the wordmark, a two-tone page header, the destination email, the
/// 6-digit code input (with shake-on-error behaviour), a localized error block,
/// a resend countdown row and a "use a different email" link.
///
/// Pure presentation: no network/state logic lives here. Parents own the cubit
/// and translate user intent (code entered, resend, error clear) into calls via
/// [onCodeEntered], [onErrorReset] and [onResendTapped].
class AuthOtpView extends StatefulWidget {
  const AuthOtpView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.email,
    required this.onCodeEntered,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    this.titleHighlight,
    this.onResendTapped,
    this.canResend = true,
    this.remainingSeconds = 0,
    this.isInputLocked = false,
    this.onErrorReset,
    this.inputResetEpoch = 0,
    this.onUseDifferentEmailPressed,
    this.showLogo = true,
    this.showEmail = true,
  });

  /// Whether the RouteX wordmark sits above the title. Flows reached from
  /// inside the app (settings) hide it.
  final bool showLogo;

  /// Whether the destination email is printed under the subtitle. The
  /// sign-up design omits it; the forgot-password design shows it.
  final bool showEmail;

  /// First (dark) part of the two-tone header title.
  final String title;

  /// Second (green) part of the two-tone header title.
  final String? titleHighlight;

  /// Body text displayed under the header.
  final String subtitle;

  /// The email address the code was sent to.
  final String email;

  /// Called whenever the user types in the OTP boxes (every keystroke).
  final ValueChanged<String> onCodeEntered;

  /// Called when the resend action is tapped while [canResend] is true.
  final VoidCallback? onResendTapped;

  /// True while the parent is verifying the code (shows a progress spinner).
  final bool isLoading;

  /// True when the entered code was rejected (red outline + error block).
  final bool hasError;

  final String? errorMessage;

  /// Whether the "Resend code" action is currently enabled.
  final bool canResend;

  /// Seconds left in the resend cooldown. Displayed when [canResend] is false.
  final int remainingSeconds;

  /// Freezes the code boxes: input is ignored entirely while true.
  ///
  /// Parents set it while the verification is in flight or has been accepted.
  /// The OTP is single-use, so anything typed after the code was sent could
  /// only re-submit an already-consumed code; the boxes are made read-only and
  /// [onCodeEntered] is not called at all.
  final bool isInputLocked;

  /// Called on input tap/change so the parent can clear the error state.
  final VoidCallback? onErrorReset;

  /// Changing this value wipes the six boxes and refocuses the first one.
  /// Parents bump it when an error is acknowledged.
  final int inputResetEpoch;

  /// Called when the "Use a different email" action is tapped.
  ///
  /// The view stays flow-agnostic: when this is null (e.g. forgot-password) the
  /// tap simply pops the screen, which is all that flow needs. Flows that must
  /// do something extra on the way back — the signup flow returns to the
  /// summary and reopens the profile editor there — pass their own callback and
  /// own the pop themselves.
  final VoidCallback? onUseDifferentEmailPressed;

  @override
  State<AuthOtpView> createState() => _AuthOtpViewState();
}

class _AuthOtpViewState extends State<AuthOtpView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _otpController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void didUpdateWidget(AuthOtpView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.hasError && widget.hasError) {
      _otpController.clear();
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onBackPressed() => Navigator.of(context).pop();

  void _onUseDifferentEmailTapped() {
    final onUseDifferentEmailPressed = widget.onUseDifferentEmailPressed;
    if (onUseDifferentEmailPressed != null) {
      onUseDifferentEmailPressed();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 26.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24.h),

          SignupBackButton(onPressed: _onBackPressed),

          SizedBox(height: 24.h),
          if (widget.showLogo) ...[
            const RouteXLogo(),
            SizedBox(height: 16.h),
          ],

          RouteXPageHeader(
            titleStart: widget.title,
            titleEnd: widget.titleHighlight ?? '',
            subtitle: widget.subtitle,
            titleStartSize: AppFonts.size48,
            titleEndSize: AppFonts.size48,
          ),

          // Figma: the address continues the subtitle (Satoshi Medium 14).
          if (widget.showEmail)
          Text(
            widget.email,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: AppFonts.size14.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.14,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 24.h),

          Center(
            child:
                (widget.hasError
                        ? Assets.images.png.imgOtpEmailErrorIcon
                        : Assets.images.png.imgOtpEmailIcon)
                    .image(width: 222.8.w),
          ),

          SizedBox(height: 32.h),

          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OtpCodeInputRow(
                  controller: _otpController,
                  hasError: widget.hasError,
                  readOnly: widget.isInputLocked,
                  resetEpoch: widget.inputResetEpoch,
                  onTap: widget.onErrorReset,
                  onChanged: (code) {
                    // Nothing is forwarded while the code is in flight or
                    // accepted: the OTP has already been consumed.
                    if (widget.isInputLocked) return;
                    widget.onErrorReset?.call();
                    widget.onCodeEntered(code);
                  },
                ),
                if (widget.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error,
                          color: AppColors.textError,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.translateValidationKey(
                                  widget.errorMessage ??
                                      "errUnexpectedResponse",
                                ),
                                style: TextStyle(
                                  fontFamily: AppFonts.fontFamilySatoshi,
                                  fontFamilyFallback:
                                      AppFonts.fontFamilyFallback,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textError,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                context.tr.otpCodeMismatchSubtitle,
                                style: TextStyle(
                                  fontFamily: AppFonts.fontFamilySatoshi,
                                  fontFamilyFallback:
                                      AppFonts.fontFamilyFallback,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          AuthPromptActionRow(
            promptText: context.tr.didntReceiveCode,
            actionText: context.tr.resendCode,
            actionFontWeight: FontWeight.w500,
            onActionTapped: widget.canResend ? widget.onResendTapped : null,
            bottomText: widget.canResend
                ? null
                : '(00:${widget.remainingSeconds.toString().padLeft(2, '0')})',
          ),

          SizedBox(height: 32.h),

          Center(
            child: AuthUnderlinedButton(
              text: context.tr.useDifferentEmail,
              onTap: _onUseDifferentEmailTapped,
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
