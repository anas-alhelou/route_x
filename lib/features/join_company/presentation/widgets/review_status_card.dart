import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class ReviewStatusCard extends StatelessWidget {
  const ReviewStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s20.w),
      decoration: BoxDecoration(
        color: AppColors.statusAmberSurface,
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
        border: Border.all(
          color: AppColors.statusAmber,
          width: AppSpacing.s1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // White circular container with hourglass icon
              Container(
                width: 48.w,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceWhite,
                ),
                child: SvgPicture.asset(
                  AppAssets.icHourglass,
                  width: 22.w,
                  height: 22.h,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFB7791F),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              // Under review badge: amber dot + bold amber text
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.statusAmber,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s6.w),
                  Text(
                    badgeLabel,
                    style: AppTextStyles.s14Bold.copyWith(
                      color: AppColors.statusAmber,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s16.h),
          Text(
            title,
            style: AppTextStyles.s20Bold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s8.h),
          Text(
            subtitle,
            style: AppTextStyles.s14Regular.copyWith(
              color: AppColors.textPrimary,
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}
