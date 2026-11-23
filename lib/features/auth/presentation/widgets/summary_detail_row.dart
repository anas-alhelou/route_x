import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'summary_edit_button.dart';

/// One labeled field of the sign-up summary card: icon badge, uppercase
/// label, value and an edit affordance opening the matching step.
class SummaryDetailRow extends StatelessWidget {
  const SummaryDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  /// Icon shown inside the leading rounded badge.
  final Widget icon;

  /// Uppercased field label rendered in grey.
  final String label;

  /// Field value rendered bold and dark.
  final String value;

  /// Invoked when the edit button is tapped.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppColors.iconBrand,
          ),
          alignment: Alignment.center,
          child: icon,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SummaryEditButton(onTap: onEdit),
      ],
    );
  }
}
