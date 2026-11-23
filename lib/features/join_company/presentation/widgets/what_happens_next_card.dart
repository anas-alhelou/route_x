import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class WhatHappensNextCard extends StatelessWidget {
  const WhatHappensNextCard({
    super.key,
    required this.title,
    required this.step1,
    required this.step2,
    required this.step3,
  });

  final String title;
  final String step1;
  final String step2;
  final String step3;

  Widget _buildStepRow(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceTint,
            border: Border.all(
              color: AppColors.brandMain,
              width: AppSpacing.s1.w,
            ),
          ),
          child: Text(
            number,
            style: AppTextStyles.s14Bold.copyWith(
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.s14.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.s14Medium.copyWith(
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 11.h,
      ),
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
            title,
            style: AppTextStyles.s16Bold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s16.h),
          _buildStepRow('1', step1),
          SizedBox(height: 16.h),
          _buildStepRow('2', step2),
          SizedBox(height: 16.h),
          _buildStepRow('3', step3),
        ],
      ),
    );
  }
}
