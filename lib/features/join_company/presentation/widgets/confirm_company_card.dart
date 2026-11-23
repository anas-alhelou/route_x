import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/company.dart';
import 'company_logo.dart';

class ConfirmCompanyCard extends StatelessWidget {
  const ConfirmCompanyCard({
    super.key,
    required this.company,
    required this.codeLabel,
  });

  final Company company;
  final String codeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s20.w,
        vertical: 16.h,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular company logo with clean circular frame
          Container(
            width: 72.w,
            height: 72.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceWhite,
              border: Border.all(
                color: AppColors.blueStrong.withValues(alpha: 0.3),
                width: AppSpacing.s1_5.w,
              ),
            ),
            child: ClipOval(
              child: CompanyLogoImage(
                logo: company.logoAsset,
                size: 72.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            company.name.isEmpty ? company.code : company.name,
            style: AppTextStyles.s20Bold.copyWith(
              height: 1.2,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.s4.h),
          Text(
            codeLabel,
            style: AppTextStyles.s14Regular.copyWith(
              height: 1.3,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
