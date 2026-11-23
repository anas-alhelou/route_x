// lib/features/app_permissions/presentation/widgets/precise_location_required_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class PreciseLocationRequiredDialog extends StatelessWidget {
  const PreciseLocationRequiredDialog({
    super.key,
    required this.onPreciseEnabled,
    required this.onOpenSettings,
  });

  final VoidCallback onPreciseEnabled;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      backgroundColor: AppColors.surfaceWhite,
      elevation: 20,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Visual Icon Badge with soft circular container and background glow
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandMain.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandMain.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.location_on_rounded,
                  size: 32.r,
                  color: AppColors.brandBlack,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              context.tr.preciseLocationRequiredTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.brandBlack,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 12.h),

            // Body Text
            Text(
              context.tr.preciseLocationRequiredMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.grey6B7280,
                height: 1.45,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 28.h),

            // Modern Action Buttons (Primary filled button + Secondary ghost button)
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: onPreciseEnabled,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMain,
                  foregroundColor: AppColors.onBrand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  context.tr.preciseLocationRequiredEnable,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlack,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: TextButton(
                onPressed: onOpenSettings,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textGray,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  context.tr.preciseLocationRequiredOpenSettings,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGray,
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
