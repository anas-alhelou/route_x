// lib/features/settings/presentation/widgets/logout_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// Asks the driver to confirm logging out. Resolves to `true` when they tap
/// "Log out", `null` for "Cancel" or a dismiss.
Future<bool?> showLogoutSheet(BuildContext context) {
  return showRoutexSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LogoutSheet(),
  );
}

class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet();

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r));
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
                // Figma S25: a 56dp well with a 1dp red ring.
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: AppColors.iconWarning,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textError, width: 1),
                ),
                child: Icon(Icons.logout, size: 26.r, color: AppColors.textError),
              ),
              SizedBox(height: 12.h),
              Text(
                tr.logoutTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.s24Bold.copyWith(
                  fontSize: 20.sp,
                  height: 1.35,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                tr.logoutBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.s14Regular.copyWith(
                  fontSize: 15.sp,
                  height: 1.35,
                  color: AppColors.textGray,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.iconWarning,
                    foregroundColor: AppColors.textError,
                    side: const BorderSide(color: AppColors.textError),
                    shape: buttonShape,
                  ),
                  icon: Icon(Icons.logout, size: 20.r),
                  label: Text(
                    tr.settingsLogOut,
                    style: AppTextStyles.s16Bold.copyWith(fontSize: AppFonts.size16.sp),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.borderDeactivated),
                    shape: buttonShape,
                  ),
                  child: Text(
                    tr.cancel,
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
