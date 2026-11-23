import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class StopMovedToast extends StatelessWidget {
  const StopMovedToast({
    super.key,
    required this.customerName,
    required this.onUndoTapped,
  });

  final String customerName;
  // Wired to RouteFleetCubit.undoReorderStop.
  final VoidCallback onUndoTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      height: 62.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.proofSheetShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.routeIcHistory,
            width: 18.w,
            height: 18.h,
            colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              context.tr.routeStopMovedToEnd(customerName),
              style: AppTextStyles.s13SemiBold.copyWith(color: AppColors.brandBlack),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.w),
          InkWell(
            onTap: onUndoTapped,
            child: Text(
              context.tr.routeUndo,
              style: AppTextStyles.s14Bold14.copyWith(color: AppColors.brandBlack),
            ),
          ),
        ],
      ),
    );
  }
}
