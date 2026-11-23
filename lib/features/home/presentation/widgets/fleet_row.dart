// lib/features/home/presentation/widgets/fleet_row.dart
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
import 'package:routex_mobile/features/home/presentation/widgets/join_button.dart';

/// One fleet in the "Fleets near you" list, with its Join button.
///
/// Figma 5222:8139 — 80pt tall, 6pt radius, tinted fill, 12pt side padding and
/// a 12pt gap between the logo, the text column and the button. The text column
/// expands so a long fleet name truncates here rather than pushing the button
/// off the row, which would break the alignment the shared [JoinButton] width
/// buys.
class FleetRow extends StatelessWidget {
  const FleetRow({
    required this.fleet,
    required this.onJoin,
    this.isJoining = false,
    this.isJoinEnabled,
    super.key,
  });

  final FleetSummary fleet;
  final VoidCallback onJoin;

  /// True while this fleet's join request is in flight, so the button can show
  /// progress instead of inviting a second tap.
  final bool isJoining;

  /// Allows the caller to disable Join independently of [FleetSummary.canJoin]
  /// — Home passes false while a request for another fleet is already pending.
  final bool? isJoinEnabled;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return SizedBox(
      height: AppSizes.rowH80.w,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(AppSizes.r6.r),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.s12.w,
          ),
          child: Row(
            children: [
              FleetAvatar(fleet: fleet),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    SizedBox(height: AppSpacing.s1.h),
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
                        // The separator is a middot inside the localized string
                        // so the order follows the locale's reading direction
                        // instead of being fixed as "zone, then distance".
                        Flexible(
                          child: Text(
                            tr.homeZoneAndDistance(
                              fleet.zone,
                              _distance(fleet.distanceKm),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.statUnit.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
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
      ),
    );
  }

  /// One decimal, matching the distance tile above.
  static String _distance(double km) => km.toStringAsFixed(1);
}
