// lib/features/settings/presentation/widgets/profile_photo_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// Asks where the new profile photo comes from.
///
/// Resolves to `true` for the camera, `false` for the gallery and `null` when
/// the user cancels or dismisses the sheet.
Future<bool?> showProfilePhotoSheet(BuildContext context) {
  return showRoutexSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProfilePhotoSheet(),
  );
}

class _ProfilePhotoSheet extends StatelessWidget {
  const _ProfilePhotoSheet();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceEmpty,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Figma S04: title 20 and the line under it 15, 4 apart.
              SizedBox(height: 16.h),
              Text(
                tr.profilePhotoTitle,
                style: AppTextStyles.s24Bold.copyWith(
                  fontSize: 20.sp,
                  height: 1.35,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                tr.profilePhotoCompanySees,
                style: AppTextStyles.s14Regular.copyWith(
                  fontSize: 15.sp,
                  height: 1.35,
                  color: AppColors.textGray,
                ),
              ),
              SizedBox(height: 18.h),
              _SourceOption(
                icon: Icons.photo_camera_outlined,
                label: tr.profilePhotoTake,
                onTap: () => Navigator.pop(context, true),
              ),
              SizedBox(height: 16.h),
              _SourceOption(
                icon: Icons.image_outlined,
                label: tr.profilePhotoGallery,
                onTap: () => Navigator.pop(context, false),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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

/// Green-outlined option row: icon in a ring, then the label.
class _SourceOption extends StatelessWidget {
  const _SourceOption({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          height: 56.h,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.brandBackground,
            borderRadius: radius,
            border: Border.all(color: AppColors.brandMain, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brandMain, width: 1.5),
                ),
                child: Icon(icon, size: 20.r, color: AppColors.brandMain),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.s16Bold.copyWith(
                    fontSize: AppFonts.size16.sp,
                    color: AppColors.textPrimary,
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
