import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class NewOrderOfferBanner extends StatelessWidget {
  const NewOrderOfferBanner({
    required this.orderCount,
    required this.fleetName,
    required this.deadline,
    required this.onView,
    super.key,
  });

  final int orderCount;
  final String fleetName;
  final String deadline;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final localizations = context.tr;

    return Container(
      // Figma NF3: 380×66 card — 12 inside a 1dp border, a 40dp icon.
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBlack.withAlpha(14),
            blurRadius: 14.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border.all(color: AppColors.brandMain, width: 1.w),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.brandMain,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizations.homeOrderOfferTitle(orderCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 15.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlack,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  localizations.homeOrderOfferSubtitle(fleetName, deadline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 12.sp,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          FilledButton(
            onPressed: onView,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandMain,
              foregroundColor: AppColors.onBrand,
              minimumSize: Size(65.w, 38.h),
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
              textStyle: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(localizations.homeOrderOfferView),
          ),
        ],
      ),
    );
  }
}
