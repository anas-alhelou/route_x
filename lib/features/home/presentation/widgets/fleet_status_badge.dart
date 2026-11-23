import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// How a fleet's status reads at a glance, and what the pill looks like.
enum FleetBadgeTone {
  /// Taking new drivers: solid brand-green fill with white type.
  active,

  /// Waiting on a fleet manager to answer: the same solid green, different copy.
  pending,

  /// Not taking drivers: solid grey fill with muted type.
  paused,
}

/// The status pill beside a fleet — "ACTIVE" on the Find a fleet card, "In
/// review" on the Go Online sheet.
///
/// One component for both because the design draws the same pill twice: a solid
/// fill, a 6pt status dot and a 10pt bold label with 1.2pt of tracking. Only the
/// wording and the tone change, and splitting them would let the two drift apart
/// on the next tweak.
///
/// The fills are saturated on purpose. The design draws ACTIVE on solid
/// #9BEF00 with *white* type, not the pale green tint a lighter reading of
/// "green badge" would suggest — and on a solid fill the type has to invert,
/// because brand-black on #9BEF00 is a contrast failure even though it looks
/// fine in a mockup.
class FleetStatusBadge extends StatelessWidget {
  const FleetStatusBadge({required this.label, required this.tone, super.key});

  final String label;
  final FleetBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (fill, foreground) = switch (tone) {
      FleetBadgeTone.active => (
        AppColors.surfaceBadgeActive,
        AppColors.textBadgeActive,
      ),
      FleetBadgeTone.pending => (
        AppColors.surfaceBadgeActive,
        AppColors.textBadgeActive,
      ),
      FleetBadgeTone.paused => (
        AppColors.surfaceBadgePaused,
        AppColors.textBadgePaused,
      ),
    };

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s3.h,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSizes.r3.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.badgeDot.w,
            height: AppSizes.badgeDot.w,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.s5.w),
          Text(
            label,
            style: AppTextStyles.badgeLabel.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
