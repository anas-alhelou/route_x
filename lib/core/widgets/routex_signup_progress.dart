// lib/core/widgets/routex_signup_progress.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Textual step progress indicator for the sign-up flow.
///
/// Renders the current step over the total as a bold number pair ("01 / 03")
/// with the step's own name underneath, matching the "Sign up steps" component
/// in the redesign.
///
/// ```dart
/// RouteXSignupProgress(currentStep: 1, label: 'Your details')
/// ```
class RouteXSignupProgress extends StatelessWidget {
  const RouteXSignupProgress({
    super.key,
    required this.currentStep,
    required this.label,
    this.totalSteps = 3,
  }) : assert(
         currentStep >= 1 && currentStep <= totalSteps,
         'currentStep must be between 1 and totalSteps (inclusive)',
       );

  /// The active step, 1-indexed.
  final int currentStep;

  /// The human-readable name of the current step (e.g. "Your details").
  final String label;

  /// Total number of steps. Defaults to 3.
  final int totalSteps;

  /// Zero-pads [value] to the two-digit form the design uses ("01", "03").
  String _padded(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _padded(currentStep),
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontFamilyFallback: AppFonts.fontFamilyFallback,
                fontSize: AppFonts.size28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.brandBlack,
                height: 1.1,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              '/ ${_padded(totalSteps)}',
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontFamilyFallback: AppFonts.fontFamilyFallback,
                fontSize: AppFonts.size14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                height: 1.1,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontFamilyFallback: AppFonts.fontFamilyFallback,
            fontSize: AppFonts.size12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
