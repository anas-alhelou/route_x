import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_underlined_button.dart';

/// Row pairing a muted prompt with a tappable action (e.g. "Don't have an
/// account?" + "Sign up"), optionally showing a countdown-style text below.
class AuthPromptActionRow extends StatelessWidget {
  const AuthPromptActionRow({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionTapped,
    this.bottomText,
    this.promptFontSize,
    this.actionFontSize,
    this.actionFontWeight,
  });

  /// Static text preceding the action, styled small and dark.
  final String promptText;

  /// Highlighted, clickable text rendered by
  /// [AuthUnderlinedButton].
  final String actionText;

  /// Invoked when [actionText] is tapped; may be null to disable the link.
  final VoidCallback? onActionTapped;

  /// Optional second line rendered below the prompt/action pair.
  final String? bottomText;

  /// Overrides the default prompt font size.
  final double? promptFontSize;

  /// Overrides the default action font size.
  final double? actionFontSize;

  /// Overrides the action label weight (defaults to bold).
  final FontWeight? actionFontWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                promptText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: promptFontSize ?? AppFonts.size14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: (promptFontSize ?? AppFonts.size14) * 0.01,
                  color: AppColors.brandBlack,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            AuthUnderlinedButton(
              text: actionText,
              onTap: onActionTapped,
              fontSize: actionFontSize,
              fontWeight: actionFontWeight,
            ),
          ],
        ),
        if (bottomText != null) ...[
          SizedBox(height: 4.h),
          Text(
            bottomText!,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: AppFonts.size14,
              letterSpacing: 0.14,
              color: AppColors
                  .brandBlack, // Using standard color since timer can be either active/inactive styling as requested
            ),
          ),
        ],
      ],
    );
  }
}
