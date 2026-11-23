// lib/features/home/presentation/widgets/delivery/offline_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';

/// Offline banner — Figma HM4 (360 x 84 at top 126).
///
/// Inset 15 with 36 x 36 icon container, title "You're offline" (18 high),
/// and a two-line description.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 84.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppSpacing.s16.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 36 x 36 Icon container
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.borderCard,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                AppAssets.icWifiOffline,
                width: 20.r,
                height: 20.r,
                colorFilter: ColorFilter.mode(
                  AppColors.brandBlack,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Title (18h) + 2-line description (34h)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr.homeYoureOffline,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 18 / 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  context.tr.homeOfflineDescription,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                    height: 17 / 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
