import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// Shared chrome for the summary "edit" dialogs: a centered brand-white
/// rounded card with a close button and a centered title, opened as a modal
/// dialog over a dimmed backdrop.
///
/// The host screen stays mounted underneath, so the summary card rebuilds
/// immediately whenever the SignupBloc emits a local-edit event.
class SummaryEditSheet extends StatelessWidget {
  const SummaryEditSheet({super.key, required this.title, required this.child});

  /// Dialog title, e.g. "Edit Profile" / "Edit Vehicle".
  final String title;

  /// Scrollable form content shown below the title.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s24.w,
        vertical: AppSpacing.s24.h,
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.s16.h),
              Row(
                // 🔴 التعديل تم هنا: جعل المحاذاة في المنتصف عمودياً
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 40.w, height: 40.h),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontFamilyFallback: AppFonts.fontFamilyFallback,
                          fontSize: AppFonts.size16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 20.sp,
                      icon: Icon(Icons.close, color: AppColors.textGray),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s24.h),
              child,
              SizedBox(height: AppSpacing.s16.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens one of the summary edit dialogs with the app's standard dialog
/// styling (centered brand-white rounded card over a dimmed backdrop). Keeps
/// the card above the keyboard when a field gains focus.
Future<T?> showSummaryEditSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showRoutexDialog<T>(
    context: context,
    builder: (dialogContext) => builder(dialogContext),
  );
}

/// Outlined, full-width "Cancel" action used under the primary Save button in
/// both summary edit dialogs. Closes the dialog without dispatching any event.
class SummarySheetCancelButton extends StatelessWidget {
  const SummarySheetCancelButton({super.key, required this.onPressed});

  /// Invoked when cancel is tapped; closes the dialog and discards edits.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandBlack,
          side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          context.tr.cancel,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontFamilyFallback: AppFonts.fontFamilyFallback,
            fontSize: AppFonts.size16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
