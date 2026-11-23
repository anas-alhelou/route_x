// lib/features/home/presentation/widgets/enter_code_caption_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The muted format hint and the clipboard action that share one row beneath the
/// code boxes.
///
/// The caption takes the slack ([Expanded]) and the action keeps its intrinsic
/// width, so an Arabic caption that runs longer than the English one pushes the
/// paste button left instead of overflowing the row. That is why the button uses
/// a directional padding rather than a symmetric one.
class EnterCodeCaptionRow extends StatelessWidget {
  const EnterCodeCaptionRow({
    super.key,
    required this.caption,
    required this.pasteLabel,
    required this.onPaste,
  });

  /// Localized format hint, e.g. "Code is 6 characters".
  final String caption;

  /// Localized label of the clipboard action.
  final String pasteLabel;

  /// Invoked when the driver presses the clipboard action.
  ///
  /// Asynchronous work belongs to the page, which is the only layer that can
  /// check `mounted` after the clipboard await.
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            caption,
            style: AppTextStyles.s12Regular.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
        // A TextButton rather than a GestureDetector so the clipboard affordance
        // carries a real tap target and the platform's button semantics.
        TextButton(
          onPressed: onPaste,
          style: TextButton.styleFrom(
            // Directional: on an RTL device the gap belongs on the trailing
            // side of the icon, not always the left one.
            padding: EdgeInsetsDirectional.only(start: AppSpacing.s8.w),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.icClipboard,
                width: AppSizes.iconXs.w,
                height: AppSizes.iconXs.w,
                colorFilter: ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: AppSpacing.s6.w),
              Text(
                pasteLabel,
                style: AppTextStyles.pasteLabel.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
