import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/direction_mirror_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class RouteXTopBar extends StatelessWidget {
  const RouteXTopBar({
    required this.onBack,
    super.key,
    this.title,
    this.trailing,
    this.height = AppSizes.topBarH50,
    this.backgroundColor,
    this.backButtonColor = Colors.transparent,
    this.titleStyle,
    this.titleGap = AppSpacing.s14,
  });

  final VoidCallback onBack;
  final String? title;
  final Widget? trailing;
  final double height;
  final Color? backgroundColor;
  final Color backButtonColor;
  final TextStyle? titleStyle;
  final double titleGap;

  static const EdgeInsetsDirectional _padding = EdgeInsetsDirectional.fromSTEB(
    AppSizes.screenGutter,
    AppSpacing.s10,
    AppSizes.screenGutter,
    0,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = backgroundColor ?? colors.surfaceCanvas;

    return Container(
      height: height.h,
      width: double.infinity,
      color: bg,
      padding: _padding,
      child: Row(
        children: [
          _BackButton(onTap: onBack, color: backButtonColor),
          if (title != null) ...[
            SizedBox(width: titleGap.w),
            Expanded(
              child: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: (titleStyle ?? AppTextStyles.topBarTitle).copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ] else
            const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap, required this.color});

  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final arrow = SvgPicture.asset(
      AppAssets.icArrowLeft,
      width: AppSizes.backButtonIcon.w,
      height: AppSizes.backButtonIcon.w,
      colorFilter: ColorFilter.mode(
        colors.textPrimary,
        BlendMode.srcIn,
      ),
    );

    return SizedBox(
      width: AppSizes.backButton.w,
      height: AppSizes.backButton.w,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(child: arrow.mirroredInRtl(context)),
        ),
      ),
    );
  }
}
