// lib/features/home/presentation/widgets/find_fleet_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_avatar.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_status_badge.dart';
import 'package:routex_mobile/features/home/presentation/widgets/join_button.dart';

/// One fleet card in the Find a Fleet list (Figma 5237:3435).
///
/// Figma: 105h, r10, hairline border, white fill, a soft #212121 shadow, 16pt
/// padding on all sides, a 48pt logo box, a 12pt gap between the three columns
/// and a 36pt Join button on the trailing edge.
///
/// The name, zone and status stack share one expandable column so the Join
/// button keeps its place at the trailing edge no matter how long the fleet's
/// name is — the alternative, letting the text size the row, would break the
/// column of buttons down the page.
class FindFleetCard extends StatelessWidget {
  const FindFleetCard({
    required this.fleet,
    required this.onJoin,
    this.isJoining = false,
    this.isJoinEnabled,
    super.key,
  });

  final FleetSummary fleet;
  final VoidCallback onJoin;
  final bool isJoining;

  /// Overrides [FleetSummary.canJoin] — Find Fleet passes `false` while any
  /// join is in flight so a second tap cannot queue a duplicate request.
  final bool? isJoinEnabled;

  /// The design's single depth cue on this card.
  ///
  /// A different tint and blur from the Home section cards' shadow: the fleet
  /// list sits on a lighter page and needs the stronger lift to separate.
  static final List<BoxShadow> elevation = [
    BoxShadow(
      color: AppColors.shadowStrong.withValues(alpha: 0.05),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Container(
      height: AppSizes.fleetCardH.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r10.r),
        border: Border.all(color: AppColors.borderDeactivated),
        boxShadow: elevation,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p16.w),
        child: Row(
          children: [
            FleetAvatar(fleet: fleet, size: AppSizes.avatarMd),
            SizedBox(width: AppSpacing.s12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fleet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.fleetRowTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.icPin,
                        width: AppSpacing.s13.w,
                        height: AppSpacing.s13.w,
                        colorFilter: ColorFilter.mode(
                          AppColors.textMuted,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s4.w),
                      Flexible(
                        child: Text(
                          tr.homeZoneAndDistance(
                            fleet.zone,
                            fleet.distanceKm.toStringAsFixed(1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.s12Regular.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s4.h),
                  Row(
                    children: [
                      FleetStatusBadge(
                        label: fleet.canJoin
                            ? tr.findFleetActiveStatus
                            : tr.findFleetPausedStatus,
                        tone: fleet.canJoin
                            ? FleetBadgeTone.active
                            : FleetBadgeTone.paused,
                      ),
                      if (fleet.driverCount > 0) ...[
                        SizedBox(width: AppSpacing.s8.w),
                        Flexible(
                          child: Text(
                            tr.findFleetDriversCount(fleet.driverCount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.s12Regular.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),
            JoinButton(
              label: tr.homeJoin,
              isEnabled: (isJoinEnabled ?? fleet.canJoin) && !isJoining,
              isBusy: isJoining,
              onTap: onJoin,
            ),
          ],
        ),
      ),
    );
  }
}
