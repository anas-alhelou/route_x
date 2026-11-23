import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class CompanyInfoCard extends StatelessWidget {
  const CompanyInfoCard({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16.w,
        vertical: AppSpacing.s14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAttentionBlue,
        borderRadius: BorderRadius.circular(AppSizes.r12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(top: 2.h),
            child: SvgPicture.asset(
              AppAssets.icInfo,
              width: 20.w,
              height: 20.h,
              colorFilter: ColorFilter.mode(
                AppColors.borderAttentionBlue,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s14Bold.copyWith(
                    color: AppColors.borderAttentionBlue,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  body,
                  style: AppTextStyles.s14Regular.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
