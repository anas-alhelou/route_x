import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_cta_label.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// The filled brand-green call to action.
///
/// One component for every primary action in the Home flow — Join fleet, Try
/// again, Find a fleet, Find another fleet — because the design draws them
/// identically: 6pt radius, full width, brand fill on a brand-black label. The
/// label text, the optional arrow and the busy state are the only things that
/// change between call sites.
///
/// [height] exists because the design does not use one value: 56pt is the button
/// everywhere except the Enter-fleet-code footer's "Join fleet", which it draws
/// at 48. Both are passed explicitly by their screens.
///
/// Complements rather than replaces `RouteXMainButton`: that widget is the
/// taller press-scaling variant the auth and onboarding flows already use, and
/// restyling those screens is out of scope here.
class RouteXPrimaryCta extends StatelessWidget {
  const RouteXPrimaryCta({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.showArrow = false,
    this.height = AppSizes.buttonH56,
  });

  final String label;

  /// Null, or [isLoading], disables the button.
  final VoidCallback? onPressed;

  /// Blocks further taps; the label stays visible (the screen's loading overlay is the only loader).
  final bool isLoading;

  /// Appends the design's forward arrow, after the label.
  final bool showArrow;

  final double height;

  @override
  Widget build(BuildContext context) {
    final button = RouteXPressable(
      onTap: onPressed,
      isEnabled: onPressed != null && !isLoading,
      child: SizedBox(
        width: double.infinity,
        height: height.h,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandMain,
            foregroundColor: AppColors.onBrand,
            disabledBackgroundColor: AppColors.brandMain.withValues(alpha: 0.6),
            disabledForegroundColor: AppColors.onBrand,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r6.r),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: RouteXCtaLabel(
            label: label,
            showArrow: showArrow,
            style: AppTextStyles.primaryCtaLabel,
          ),
        ),
      ),
    );

    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.controlW360),
        child: button,
      ),
    );
  }
}
