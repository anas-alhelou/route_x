import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class PrivacyFootnote extends StatelessWidget {
  const PrivacyFootnote({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(top: 2.h),
          child: SvgPicture.asset(
            AppAssets.icShieldCheck,
            width: 15.w,
            height: 15.h,
            colorFilter: ColorFilter.mode(
              AppColors.textMuted,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.s8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.s12Regular.copyWith(
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
