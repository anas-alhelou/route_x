import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class RouteXInfoCard extends StatelessWidget {
  const RouteXInfoCard({
    required this.title,
    required this.body,
    super.key,
    this.showIcon = true,
    this.backgroundColor,
    this.radius = AppSizes.r10,
    this.iconColor,
    this.titleColor,
    this.bodyColor,
    this.padding = AppSizes.p16,
  });

  final String title;
  final String body;
  final bool showIcon;
  final Color? backgroundColor;
  final double radius;
  final Color? iconColor;
  final Color? titleColor;
  final Color? bodyColor;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = backgroundColor ?? colors.surface;
    final ic = iconColor ?? colors.textPrimary;
    final tc = titleColor ?? colors.textPrimary;
    final bc = bodyColor ?? colors.textMuted;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.s2.h),
              child: SvgPicture.asset(
                AppAssets.icInfo,
                width: AppSizes.iconSm.w,
                height: AppSizes.iconSm.w,
                colorFilter: ColorFilter.mode(ic, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.infoCardTitle.copyWith(
                    color: tc,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  body,
                  style: AppTextStyles.infoCardBody.copyWith(color: bc),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
