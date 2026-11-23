// lib/features/home/presentation/widgets/go_online/go_online_request_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_variant.dart';

/// The "pending" frame's panel: which fleet was asked for, when, and that the
/// request is still in review.
///
/// White rather than the tinted canvas the progress panel uses: this one is a
/// restatement of a real fleet row, and the design gives it the same white fill
/// and border so the two frames read as the same component in two states.
class GoOnlineRequestPanel extends StatelessWidget {
  const GoOnlineRequestPanel({super.key, required this.overview});

  /// The snapshot to name. Nullable, with the same fallbacks as the sheet.
  final HomeOverview? overview;

  @override
  Widget build(BuildContext context) {
    final request = overview?.fleetRequest;
    final fleetName = request?.fleetName ?? kFallbackFleetName;
    final logoPath = request?.fleetLogoPath ?? AppAssets.imgFleetRedSeaExpress;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r12.r),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          _RequestFleetMark(logoPath: logoPath),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fleetName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // The same 15 Bold as a fleet row's name: this card is a
                  // compact restatement of one of those rows, so reusing the
                  // role keeps the two at one size if the design ever moves.
                  style: AppTextStyles.fleetRowTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  context.tr.goOnlineSheetRequestedToday(_requestedAt(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s12Regular.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
          const _InReviewPill(),
        ],
      ),
    );
  }

  /// The clock time the request was made, in the active locale.
  ///
  /// Formatted through [MaterialLocalizations] rather than a hardcoded string or
  /// a private [DateFormat]: the sheet is shown in English and Arabic, and
  /// `MaterialLocalizations` is already resolved for the ambient locale, so this
  /// stays correct without a second locale table to keep in step.
  ///
  /// Empty when there is no request: the localized string around it is written
  /// for a time, so there is nothing sensible to show.
  String _requestedAt(BuildContext context) {
    final requestedAt = overview?.fleetRequest?.requestedAt;
    if (requestedAt == null) return '';

    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(requestedAt));
  }
}

/// The fleet's logo in a clipped square.
class _RequestFleetMark extends StatelessWidget {
  const _RequestFleetMark({required this.logoPath});

  final String logoPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r8.r),
      child: Image.asset(
        logoPath,
        width: AppSizes.avatarRequest.w,
        height: AppSizes.avatarRequest.w,
        fit: BoxFit.cover,
        // A missing logo must not take the sheet down with it — the frame's
        // whole job is to name the fleet, which the text beside it still does.
        errorBuilder: (_, __, ___) => Container(
          width: AppSizes.avatarRequest.w,
          height: AppSizes.avatarRequest.w,
          color: AppColors.surfaceCanvas,
        ),
      ),
    );
  }
}

/// The "In review" status pill on the request card.
class _InReviewPill extends StatelessWidget {
  const _InReviewPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s10.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceBadgeActive,
        borderRadius: BorderRadius.circular(AppSizes.rPill.r),
      ),
      child: Text(
        context.tr.goOnlineSheetInReview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.inReviewLabel.copyWith(
          color: AppColors.textBadgeActive,
        ),
      ),
    );
  }
}