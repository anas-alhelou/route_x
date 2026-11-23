import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/direction_mirror_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The label row inside a call-to-action button.
///
/// Both button variants draw the same thing — one line of 16pt bold text, and
/// in some variants a forward arrow after it — so the pairing and the arrow's
/// mirroring live here rather than being written twice.
///
/// The text is [Flexible] because these labels are localized: "Ask your manager
/// for a new code" is comfortably wider than a 320pt screen once the arrow is
/// placed, and the label must ellipsize rather than overflow the button.
class RouteXCtaLabel extends StatelessWidget {
  const RouteXCtaLabel({
    required this.label,
    super.key,
    this.showArrow = false,
    this.color = AppColors.onBrand,
    this.style,
  });

  final String label;

  /// Draws the design's forward arrow after the text. Mirrored in RTL.
  final bool showArrow;

  final Color color;

  /// Overrides the label's role. Pass [AppTextStyles.primaryCtaLabel] from the
  /// filled button and leave it null on the outlined one: the design gives them
  /// 22.5 and 21 lines respectively, and only the filled button's label is
  /// brand-black by default.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: (style ?? AppTextStyles.ctaLabel).copyWith(color: color),
    );

    if (!showArrow) return text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: text),
        SizedBox(width: AppSpacing.s8.w),
        // The SVG rather than a Material glyph: the design's arrow is a filled
        // mark with its own weight, and the Material one next to it reads
        // noticeably lighter at the same size.
        SvgPicture.asset(
          AppAssets.icArrow,
          width: AppSizes.iconSm.w,
          height: AppSizes.iconSm.w,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ).mirroredInRtl(context),
      ],
    );
  }
}
