// lib/features/home/presentation/widgets/go_online/go_online_declined_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';

/// The "declined" frame's panel: the dispatcher's reason, or the standing
/// fallback when the request carried none.
///
/// The only red-tinted panel in the sheet, and the only one whose content comes
/// from outside the app — so it is the one panel that must have a fallback rather
/// than trusting its input.
class GoOnlineDeclinedPanel extends StatelessWidget {
  const GoOnlineDeclinedPanel({super.key, required this.overview});

  /// The snapshot to read the reason from. Nullable; null means no reason.
  final HomeOverview? overview;

  @override
  Widget build(BuildContext context) {
    // The fallback is localized and comes from the arb, not from the data layer:
    // a dispatcher reason is free text the app did not write, so the app's own
    // "we do not know why" wording has to be ready in every language.
    final reason =
        overview?.fleetRequest?.declineReason ??
        context.tr.defaultDeclinedReason;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeclined,
        borderRadius: BorderRadius.circular(AppSizes.r12.r),
        border: Border.all(color: AppColors.borderDeclined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr.goOnlineSheetReasonTitle,
            style: AppTextStyles.reasonTitle.copyWith(
              color: AppColors.textDeclinedTitle,
            ),
          ),
          SizedBox(height: AppSpacing.s6.h),
          Text(
            reason,
            style: AppTextStyles.reasonBody.copyWith(
              color: AppColors.textDeclinedBody,
            ),
          ),
        ],
      ),
    );
  }
}