import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class ReviewTimelineCard extends StatelessWidget {
  const ReviewTimelineCard({
    super.key,
    required this.cardTitle,
    required this.step1Title,
    required this.step1Time,
    required this.step2Title,
    required this.step2Subtitle,
    required this.step3Title,
  });

  final String cardTitle;
  final String step1Title;
  final String step1Time;
  final String step2Title;
  final String step2Subtitle;
  final String step3Title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
        border: Border.all(
          color: AppColors.borderDeactivated,
          width: AppSpacing.s1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cardTitle,
            style: AppTextStyles.s16Bold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          // Step 1: Request sent (Completed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brandMain,
                    ),
                    child: SvgPicture.asset(
                      AppAssets.icCheck,
                      width: 12.w,
                      height: 12.h,
                      colorFilter: const ColorFilter.mode(
                        AppColors.brandWhite,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 26.h,
                    color: AppColors.brandMain,
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.s14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step1Title,
                    style: AppTextStyles.s16Bold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2.h),
                  Text(
                    step1Time,
                    style: AppTextStyles.s12Regular.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Step 2: Company review (Active)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceWhite,
                      border: Border.all(
                        color: AppColors.brandMain,
                        width: AppSpacing.s2.w,
                      ),
                    ),
                    child: Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brandMain,
                      ),
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 26.h,
                    color: AppColors.borderSubtle,
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.s14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step2Title,
                    style: AppTextStyles.s16Bold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2.h),
                  Text(
                    step2Subtitle,
                    style: AppTextStyles.s12Regular.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Step 3: Start getting orders (Pending)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceWhite,
                  border: Border.all(
                    color: AppColors.borderDeactivated,
                    width: AppSpacing.s1_5.w,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s14.w),
              Expanded(
                child: Text(
                  step3Title,
                  style: AppTextStyles.s14Medium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
