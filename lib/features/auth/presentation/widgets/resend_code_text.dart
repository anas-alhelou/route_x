import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// "Didn't receive the code?" line with a tappable resend action and a
/// live countdown. The link is enabled only when [canResend] is true.
class ResendCodeText extends StatelessWidget {
  const ResendCodeText({
    super.key,
    required this.canResend,
    required this.remainingSeconds,
    required this.onResendTapped,
    required this.didntReceiveText,
    required this.resendActionText,
  });

  /// Whether the resend link is currently active.
  final bool canResend;

  /// Seconds left before [canResend] turns true; shown as `(00:SS)`.
  final int remainingSeconds;

  /// Invoked when the active resend link is tapped.
  final VoidCallback onResendTapped;

  /// Static prefix, e.g. "Didn't receive the code?".
  final String didntReceiveText;

  /// Action label, e.g. "Resend".
  final String resendActionText;

  @override
  Widget build(BuildContext context) {
    final timerText = canResend
        ? ''
        : ' (00:${remainingSeconds.toString().padLeft(2, '0')})';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: AppFonts.fontFamilySatoshi,
          fontFamilyFallback: AppFonts.fontFamilyFallback,
          fontSize: AppFonts.size14,
          color: AppColors.textGray,
        ),
        children: [
          TextSpan(text: didntReceiveText),
          TextSpan(
            text: '$resendActionText$timerText',
            style: TextStyle(
              color: canResend ? AppColors.brandMain : AppColors.textGray,
              fontWeight: canResend ? FontWeight.w600 : FontWeight.w400,
            ),
            recognizer: canResend
                ? (TapGestureRecognizer()..onTap = onResendTapped)
                : null,
          ),
        ],
      ),
    );
  }
}
