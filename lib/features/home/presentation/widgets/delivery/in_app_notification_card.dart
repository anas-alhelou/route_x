// lib/features/home/presentation/widgets/delivery/in_app_notification_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// In-app notification overlay card — Figma HM8 & HM9.
///
/// 380 x 70 at left 16, top 50, drawn above the status bar area and content.
/// 40 x 40 icon container at inset 15, title row (title + "now" timestamp),
/// subtitle below, and "Review" button 79 x 34 on the right.
class InAppNotificationCard extends StatelessWidget {
  const InAppNotificationCard({
    required this.title,
    required this.subtitle,
    required this.onReviewTap,
    this.timeAgo,
    this.onDismiss,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? timeAgo;
  final VoidCallback onReviewTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380.w,
      constraints: BoxConstraints(minHeight: 70.h),
      // 15 from the outer edge in the design = 1 border + 14 padding.
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowStrong.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 40 x 40 Icon container at inset 15 — solid bright lime-green circle
          Container(
            width: 40.r,
            height: 40.r,
            decoration: const BoxDecoration(
              color: AppColors.brandMain,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                AppAssets.icPackage,
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

          // ── Title + "now" + Subtitle ────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontFamilyFallback: AppFonts.fontFamilyFallback,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      timeAgo ?? context.tr.homeInAppNow,
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilySatoshi,
                        fontFamilyFallback: AppFonts.fontFamilyFallback,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── "Review" button (79 x 34) ───────────────────────────────────────
          SizedBox(
            width: 79.w,
            height: 34.h,
            child: ElevatedButton(
              onPressed: onReviewTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandMain,
                foregroundColor: AppColors.onBrand,
                padding: EdgeInsets.zero,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.r),
                ),
              ),
              child: Text(
                context.tr.homeReview,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
