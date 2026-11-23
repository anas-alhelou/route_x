// lib/features/home/presentation/widgets/dashboard/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Shown in place of a list when there is nothing to display.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    this.title = 'Nothing here yet',
    this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.textUnderline),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36.r, color: AppColors.textHint),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 4.h),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
