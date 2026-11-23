// lib/features/settings/presentation/widgets/dispatch_locked_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// Explains that contact dispatch needs a fleet. Resolves to `true` when the
/// user taps "Find a fleet", `null` for "Not now" or a dismiss.
Future<bool?> showDispatchLockedSheet(BuildContext context) {
  return showRoutexSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DispatchLockedSheet(),
  );
}

class _DispatchLockedSheet extends StatelessWidget {
  const _DispatchLockedSheet();

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceEmpty,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                width: 54.r,
                height: 54.r,
                decoration: BoxDecoration(
                  color: AppColors.iconBrand,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline, size: 26.r, color: AppColors.brandMain),
              ),
              SizedBox(height: 14.h),
              Text(
                tr.dispatchLockedTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.s24Bold.copyWith(
                  fontSize: AppFonts.size24.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                tr.dispatchLockedBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.s14Regular.copyWith(
                  fontSize: AppFonts.size14.sp,
                  color: AppColors.textGray,
                ),
              ),
              SizedBox(height: 20.h),
              RouteXMainButton(
                isLoading: false,
                onPressed: () => Navigator.pop(context, true),
                text: tr.dispatchLockedFindFleet,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.borderDeactivated),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    tr.dispatchLockedNotNow,
                    style: AppTextStyles.s16Bold.copyWith(fontSize: AppFonts.size16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
