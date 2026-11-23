// lib/features/home/presentation/widgets/enter_code_help_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The outlined "Help" pill that occupies the Enter Fleet Code top bar's
/// trailing slot.
///
/// Shown only on the invalid frame. Before a code has been rejected there is
/// nothing the driver could be stuck on, so the slot stays empty rather than
/// offering a permanent escape hatch that would sit there on every visit.
///
/// An [InkWell] inside a [Material] rather than a bare [GestureDetector]: the
/// pill needs both the ripple and the button semantics a platform tap target
/// gives, and the white [Material] is also what paints the fill, so the
/// container does not have to.
class EnterCodeHelpButton extends StatelessWidget {
  const EnterCodeHelpButton({super.key, required this.label});

  /// Localized button text.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(AppSizes.rPill.r),
      child: InkWell(
        // TODO: help flow — no destination designed yet.
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSizes.rPill.r),
        child: Container(
          width: AppSizes.helpButtonW.w,
          height: AppSizes.helpButtonH.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.rPill.r),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            label,
            style: AppTextStyles.helpButtonLabel.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
