import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Screen J11 (Cancel request): the bottom sheet opened by "Cancel request" on
/// J10. Resolves to `true` when the driver confirms, `false`/`null` otherwise.
Future<bool?> showCancelRequestSheet({
  required BuildContext context,
  required String companyName,
}) {
  return showRoutexSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrimDark,
    builder: (_) => CancelRequestSheet(companyName: companyName),
  );
}

class CancelRequestSheet extends StatelessWidget {
  const CancelRequestSheet({super.key, required this.companyName});

  final String companyName;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.screenGutter.w,
            AppSpacing.s12.h,
            AppSizes.screenGutter.w,
            AppSpacing.s16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderDeactivated,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: AppSpacing.s20.h),
              Container(
                width: 56.w,
                height: 56.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.dangerSurface,
                  border: Border.all(
                    color: AppColors.dangerIcon,
                    width: AppSpacing.s1.w,
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 26.w,
                  color: AppColors.dangerIcon,
                ),
              ),
              SizedBox(height: AppSpacing.s16.h),
              Text(
                tr.underReviewCancelSheetTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.s20Bold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.s8.h),
              Text(
                tr.underReviewCancelSheetMessage(companyName),
                textAlign: TextAlign.center,
                style: AppTextStyles.s14Regular.copyWith(
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              SizedBox(height: AppSpacing.s24.h),
              // Danger action: "Yes, cancel request"
              RouteXTapScale(
                onTap: () => Navigator.of(context).pop(true),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.dangerSurface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.dangerIcon,
                      width: AppSpacing.s1.w,
                    ),
                  ),
                  child: Text(
                    tr.underReviewCancelSheetConfirm,
                    style: AppTextStyles.s16Bold.copyWith(
                      color: AppColors.dangerText,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s12.h),
              // Secondary action: "Keep my request"
              RouteXTapScale(
                onTap: () => Navigator.of(context).pop(false),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.borderDeactivated,
                      width: AppSpacing.s1.w,
                    ),
                  ),
                  child: Text(
                    tr.underReviewCancelSheetKeep,
                    style: AppTextStyles.s16Bold.copyWith(
                      color: AppColors.textPrimary,
                    ),
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
