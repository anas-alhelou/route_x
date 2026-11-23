import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

/// Compact "Edit" label with a chevron, shown on each sign-up summary row.
class SummaryEditButton extends StatelessWidget {
  const SummaryEditButton({super.key, required this.onTap});

  /// Invoked when the edit button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr.editLabel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.brandMain,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: AppColors.brandMain,
            ),
          ],
        ),
      ),
    );
  }
}
