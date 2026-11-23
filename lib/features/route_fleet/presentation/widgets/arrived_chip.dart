import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class ArrivedChip extends StatelessWidget {
  const ArrivedChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r100),
        // Figma R12: the chip has no border
        boxShadow: AppTextStyles.summaryChipShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppAssets.routeIcArrive,
            width: 18.w,
            height: 18.h,
            colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
          ),
          SizedBox(width: 8.w),
          Text(
            context.tr.routeYouveArrived,
            style: AppTextStyles.s14Bold14.copyWith(color: AppColors.brandBlack),
          ),
        ],
      ),
    );
  }
}
