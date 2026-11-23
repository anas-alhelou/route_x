// lib/core/widgets/routex_language_toggle.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// A compact, animated toggle button that switches the app locale between
/// English and Arabic.
///
/// This is a pure presentation component (Dumb Widget). It relies on its
/// parent to provide the current language state [isEnglish], the callback
/// [onToggle] to trigger the actual language switch, and the localized labels
/// [englishLabel] / [arabicLabel] to render — the widget itself never
/// hardcodes or localizes text.
class RouteXLanguageToggle extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onToggle;
  final String englishLabel;
  final String arabicLabel;

  const RouteXLanguageToggle({
    super.key,
    required this.isEnglish,
    required this.onToggle,
    required this.englishLabel,
    required this.arabicLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Small delay for the animation effect before triggering the callback
        Future.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            onToggle();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: AppSpacing.s40.h,
        height: AppSpacing.s40.h,
        decoration: BoxDecoration(
          color: AppColors.brandMain,
          borderRadius: BorderRadius.circular(AppSpacing.s10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.onBrand.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            // Scale transition — exact legacy animation preserved
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              isEnglish ? englishLabel : arabicLabel,
              // ValueKey forces AnimatedSwitcher to detect a child swap
              key: ValueKey<bool>(isEnglish),
              style: AppTextStyles.s14Bold.copyWith(
                color: AppColors.brandWhite,
                fontSize: AppTextStyles.s14Bold.fontSize?.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}