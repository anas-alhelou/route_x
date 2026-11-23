import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class _LocationPinIcon extends StatelessWidget {
  const _LocationPinIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.routeIcLocation,
      width: 24.w,
      height: 24.h,
      fit: BoxFit.contain,
    );
  }
}

class RouteLocationNeededView extends StatelessWidget {
  const RouteLocationNeededView({
    super.key,
    required this.onRequestPermission,
    required this.onNotNow,
  });

  final VoidCallback onRequestPermission;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground, // #FDFDFD
        borderRadius: BorderRadius.circular(AppSizes.r24.r),
        border: Border.all(
          color: AppColors.borderDeactivated, // #D0D0D0
          width: 1.w,
        ),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Title
            Text(
              context.tr.routeTurnOnLocation,
              style: AppTextStyles.s26Bold.copyWith(
                color: AppColors.brandBlack, // #222222
              ),
            ),
            SizedBox(height: 14.h),

            // 2. Body
            Text(
              context.tr.routeLocationWhy,
              style: AppTextStyles.s12Regular145.copyWith(
                color: AppColors.textBody, // #737373
              ),
            ),
            SizedBox(height: 14.h),

            // 3. Button "Allow location"
            SizedBox(
              width: 310.w,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMain, // #8FE600
                  foregroundColor: AppColors.onBrand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                onPressed: onRequestPermission,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LocationPinIcon(),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr.routeAllowLocation,
                      style: AppTextStyles.s16Bold.copyWith(
                        color: AppColors.brandBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // 4. Button "Not now"
            SizedBox(
              width: 310.w,
              height: 44.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8.r),
                  ),
                ),
                onPressed: onNotNow,
                child: Text(
                  context.tr.routeNotNow,
                  style: AppTextStyles.s15SemiBold.copyWith(
                    color: AppColors.brandBlack,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
