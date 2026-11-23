// lib/features/home/presentation/widgets/find_fleet_invite_footer.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_secondary_cta.dart';

/// Sticky invite footer on the Find a Fleet screen.
///
/// Figma 5237:3435 — a 127pt band across the bottom of the 412x917 page, filled
/// with the page's own #FDFDFD (not white) so it reads as part of the canvas
/// rather than a floating card, padding 26/16/26/26, with 10pt between the line
/// of copy and the button.
///
/// Sits in the page's `bottomNavigationBar` slot rather than at the end of the
/// scroll view, and the list carries a matching bottom inset, so the last card
/// scrolls clear of the band instead of being permanently half-hidden behind it.
class FindFleetInviteFooter extends StatelessWidget {
  const FindFleetInviteFooter({required this.onEnterFleetCode, super.key});

  final VoidCallback onEnterFleetCode;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.s26,
          AppSpacing.s16,
          AppSpacing.s26,
          AppSpacing.s26,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr.findFleetInviteTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.s12Regular.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: AppSpacing.s10.h),
            RouteXSecondaryCta(
              label: tr.findFleetInviteButton,
              height: AppSizes.buttonH56,
              showTrailingArrow: true,
              onPressed: onEnterFleetCode,
            ),
          ],
        ),
      ),
    );
  }
}
