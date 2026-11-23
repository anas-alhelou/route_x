import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class CompanyCodeErrorRow extends StatelessWidget {
  const CompanyCodeErrorRow({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(top: 2.h),
          child: SvgPicture.asset(
            AppAssets.icErrorCircle,
            width: 15.w,
            height: 15.h,
            colorFilter: const ColorFilter.mode(
              AppColors.textError,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.s6.w),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.s12Medium.copyWith(
              color: AppColors.textError,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
