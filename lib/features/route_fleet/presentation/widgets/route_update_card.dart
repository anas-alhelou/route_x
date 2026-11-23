import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class RouteUpdateCard extends StatelessWidget {
  const RouteUpdateCard({
    super.key,
    required this.companyName,
    required this.updateSummaryText,
    required this.onOkTapped,
    required this.onViewWhenStoppedTapped,
  });

  final String companyName;
  final String updateSummaryText;
  final VoidCallback onOkTapped;
  final VoidCallback onViewWhenStoppedTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.proofSheetShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row: Icon Tile + Text (Figma: 10 vertical padding)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.amberSurface, // #FFF3D6
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.routeIcNotification,
                    width: 22.w,
                    height: 22.h,
                    colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        context.tr.routeUpdatedBy(companyName),
                        style: AppTextStyles.s15Bold135.copyWith(color: AppColors.brandBlack),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        updateSummaryText,
                        style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
          SizedBox(height: 12.h),
          // Buttons Row
          Row(
            children: [
              SizedBox(
                width: 101.w,
                height: 52.h,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceWhite,
                    side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                  ),
                  onPressed: onOkTapped,
                  child: Text(
                    context.tr.routeOk,
                    style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandMain,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                    ),
                    onPressed: onViewWhenStoppedTapped,
                    child: Text(
                      context.tr.routeViewWhenStopped,
                      style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
