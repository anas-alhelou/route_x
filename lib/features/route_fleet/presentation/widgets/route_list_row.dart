import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class RouteListRow extends StatelessWidget {
  const RouteListRow({
    super.key,
    required this.icon,
    this.tileColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.titleBold = false,
    this.showDivider = true,
    this.dividerGap = 4,
    this.onTap,
  });

  final Widget icon;
  /// Icon tile fill; null follows the theme ([AppColors.deactivatedBadge]).
  final Color? tileColor;
  final String title;
  final String? subtitle;
  /// Title colour; null follows the theme ([AppColors.brandBlack]).
  final Color? titleColor;

  /// Figma: R31 rows use 15 Bold titles, R26b / R29 rows use 15 SemiBold.
  final bool titleBold;
  final bool showDivider;

  /// Space above and below the divider (Figma: 4 in R29 / R31, 10 in R26b).
  final double dividerGap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                // 36x36 icon tile, radius 8
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: tileColor ?? AppColors.deactivatedBadge,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: Center(child: icon),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: (titleBold ? AppTextStyles.s15Bold135 : AppTextStyles.s15SemiBold)
                            .copyWith(color: titleColor ?? AppColors.brandBlack),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 1.h),
                        Text(
                          subtitle!,
                          style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: EdgeInsets.symmetric(vertical: dividerGap.h),
              child: Divider(
                height: 1.h,
                thickness: 1.w,
                color: AppColors.borderDeactivated,
              ),
            ),
        ],
      ),
    );
  }
}
