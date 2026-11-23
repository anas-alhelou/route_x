import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../controllers/route_fleet_state.dart';

class TopSheetView extends StatelessWidget {
  const TopSheetView({
    super.key,
    required this.sheetType,
    required this.customerName,
    required this.companyName,
    this.mapAppName = 'Google Maps',
    required this.onTurnOnTapped,
    required this.onIveArrivedTapped,
    required this.onResumeTapped,
  });

  final DrivingModalSheet sheetType;
  final String customerName;
  final String companyName;
  final String mapAppName;
  final VoidCallback onTurnOnTapped;
  final VoidCallback onIveArrivedTapped;
  final VoidCallback onResumeTapped;

  @override
  Widget build(BuildContext context) {
    final isLocationStopped = sheetType == DrivingModalSheet.locationStopped;
    final isBackFromMaps = sheetType == DrivingModalSheet.backFromMaps;

    if (!isLocationStopped && !isBackFromMaps) return const SizedBox.shrink();

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
        // Figma R33/R34: 24 + message row (10 + 57 + 10) + 12 + button 52 + 24 = 191 with the border
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Message Row (icon centered against the text block, 10 vertical padding)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Tile (42x42, 8r radius)
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: isLocationStopped ? AppColors.dangerSurface : AppColors.brandMain,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    isLocationStopped ? AppAssets.routeIcLocation : AppAssets.routeIcNavigate,
                    width: 24.w,
                    height: 24.h,
                    colorFilter: isLocationStopped
                        ? const ColorFilter.mode(AppColors.dangerIcon, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLocationStopped ? context.tr.routeLocationSharingStopped : context.tr.routeWelcomeBack,
                      style: AppTextStyles.s15SemiBold135.copyWith(color: AppColors.brandBlack),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      isLocationStopped
                          ? context.tr.routeCantSeeYourRoute(companyName)
                          : context.tr.routeYouWereNavigating(customerName, mapAppName),
                      style: AppTextStyles.s13Regular135.copyWith(color: AppColors.textBody),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
          SizedBox(height: 12.h),

          // 2. Action Button(s)
          if (isLocationStopped)
            SizedBox(
              height: 52.h,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMain,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                onPressed: onTurnOnTapped,
                child: Text(
                  context.tr.routeTurnOn,
                  style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceWhite,
                        side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                        ),
                      ),
                      onPressed: onIveArrivedTapped,
                      child: Text(
                        context.tr.routeIveArrived,
                        style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                      ),
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
                      onPressed: onResumeTapped,
                      child: Text(
                        context.tr.routeResume,
                        style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
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
