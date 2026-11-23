// lib/features/home/presentation/widgets/go_online/go_online_chrome.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_variant.dart';

/// The 40x4 drag handle, centred at the top of every sheet.
///
/// Identical on all three frames, which is why it lives here and not on a
/// variant: if it were per-frame the three would drift.
class GoOnlineSheetHandle extends StatelessWidget {
  const GoOnlineSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppSizes.sheetHandleW.w,
        height: AppSizes.sheetHandleH.h,
        decoration: BoxDecoration(
          color: AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(AppSizes.r3.r),
        ),
      ),
    );
  }
}

/// The 56pt tinted disc behind the frame's leading glyph.
///
/// Purely decorative: it repeats the reason the heading is about to state, so it
/// is hidden from the accessibility tree rather than announced as an image with
/// no label. Takes its colours and its glyph from the variant, which is the only
/// per-frame difference it has.
class GoOnlineIconWell extends StatelessWidget {
  const GoOnlineIconWell({super.key, required this.variant});

  /// The frame being drawn.
  final GoOnlineVariantBase variant;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: AppSizes.sheetIconWell.w,
        height: AppSizes.sheetIconWell.w,
        decoration: BoxDecoration(color: variant.discFill, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          variant.iconPath,
          width: AppSizes.iconLg.w,
          height: AppSizes.iconLg.w,
          colorFilter: ColorFilter.mode(variant.iconTint, BlendMode.srcIn),
        ),
      ),
    );
  }
}

/// The sheet's centred title and body.
///
/// Two [Text]s in a [Column] rather than one block of rich text, because the two
/// halves are styled differently and are separate sentences - the design's title
/// is a claim and its body is an explanation.
class GoOnlineHeaders extends StatelessWidget {
  const GoOnlineHeaders({super.key, required this.variant});

  /// The frame being drawn.
  final GoOnlineVariantBase variant;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          variant.title(context),
          textAlign: TextAlign.center,
          style: AppTextStyles.sheetTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.s8.h),
        Text(
          variant.body(context),
          textAlign: TextAlign.center,
          // Not textMuted: the design draws this line at 80% of the primary ink,
          // which reads as body copy rather than as a caption.
          style: AppTextStyles.sheetBody.copyWith(
            color: AppColors.textBodyStrong,
          ),
        ),
      ],
    );
  }
}