import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The brand-green Join button that trails every fleet in the list.
///
/// The Home row and the Find a fleet card both end with one of these at the same
/// 36pt height, and the design fixes its width so the rows line up down the
/// page — hence a width token rather than one derived from the label, which
/// would leave the two screens' columns ragged.
///
/// Handles all three button states in place: enabled, disabled (the fleet is not
/// taking drivers, or a request is already in flight) and busy (this specific
/// fleet's join is in flight). The busy state is per-row rather than per-list so
/// joining one fleet does not grey out the other four.
///
/// A disabled button changes *shape* as well as colour: the design swaps the
/// brand fill for an outlined treatment and narrows to
/// [AppSizes.buttonW64]. That width asymmetry is deliberate in the design and
/// reproduced here, so it must not be "tidied" into matching the enabled width —
/// losing the fill is what makes the paused row read as unavailable at a glance,
/// and a dimmed-but-still-filled button would not.
class JoinButton extends StatelessWidget {
  const JoinButton({
    required this.label,
    required this.onTap,
    super.key,
    this.isEnabled = true,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final isInteractive = isEnabled && !isBusy;
    final radius = BorderRadius.circular(AppSizes.r4.r);

    return SizedBox(
      height: AppSizes.buttonH36.h,
      width: (isEnabled ? AppSizes.buttonW80 : AppSizes.buttonW64).w,
      child: Material(
        color: isEnabled ? AppColors.brandMain : AppColors.surfaceWhite,
        borderRadius: radius,
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          borderRadius: radius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: isEnabled
                  ? null
                  : Border.all(color: AppColors.borderDeactivated),
            ),
            child: Center(
              child: isBusy
                  ? SizedBox(
                      width: AppSizes.iconSm.w,
                      height: AppSizes.iconSm.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brandBlack,
                      ),
                    )
                  : Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.joinLabel.copyWith(
                        // Brand-black on brand green; muted grey on white. The
                        // disabled label recolours rather than dims, because an
                        // opacity-dimmed brand-black on white reads as broken
                        // text rather than as an inactive control.
                        color: isEnabled
                            ? AppColors.brandBlack
                            : AppColors.textMuted,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
