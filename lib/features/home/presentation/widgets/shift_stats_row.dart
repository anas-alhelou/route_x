// lib/features/home/presentation/widgets/shift_stats_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/shift_stats.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_section_card.dart';

/// One figure in "Today's overview": an icon, the number, its unit and a label.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.iconPath,
    required this.value,
    required this.unit,
    required this.label,
    super.key,
  });

  final String iconPath;

  /// Pre-formatted for display — the formatting differs per tile (one decimal
  /// for distance, none for deliveries), so it is resolved by the caller rather
  /// than guessed here.
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.statTileW.w,
      // The design draws the tile as a fixed 142pt component and the strip is
      // sized by it. Left to its content the column lands on 140, which would
      // leave "Today's overview" 2pt short of the design's 196 and push every
      // section below it out of rhythm.
      height: AppSizes.statTileH.h,
      padding: const EdgeInsets.all(AppSizes.p16).w,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r16.w),
        border: Border.all(color: AppColors.borderSubtle),
        // Same elevation as the section cards: the design gives the tiles and
        // the panels the same single soft shadow.
        boxShadow: HomeSectionCard.elevation,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            iconPath,
            width: AppSizes.iconMd.w,
            height: AppSizes.iconMd.w,
          ),
          SizedBox(height: AppSpacing.s10.w),
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            unit,
            style: AppTextStyles.statUnit.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: AppSpacing.s6.w),
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// The three "Today's overview" tiles, scrolled sideways.
///
/// Horizontal rather than three squeezed into a row: the design draws them at
/// their natural 132pt and lets the third run past the edge, naming the group
/// "Tiles (scrolls sideways)". A 3-up `Row` on a 412pt screen would force them
/// narrower than drawn and squeeze every number.
class ShiftStatsRow extends StatelessWidget {
  const ShiftStatsRow({required this.stats, super.key});

  final ShiftStats stats;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return SizedBox(
      // A horizontal viewport expands across its cross axis, and this one is a
      // direct child of the section's `Column`, which hands its children
      // unbounded height. Without a bound here the strip trips "Horizontal
      // viewport was given unbounded height" the moment Home is laid out. The
      // design fixes the strip at 142, so the bound is that height.
      height: AppSizes.statTileH.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.s12.w),
        itemBuilder: (context, index) {
          return switch (index) {
            0 => StatTile(
              iconPath: AppAssets.icStatDeliveries,
              value: '${stats.deliveries}',
              unit: tr.homeDeliveriesOf(stats.deliveriesTarget),
              label: tr.homeDeliveries,
            ),
            1 => StatTile(
              iconPath: AppAssets.icStatDistance,
              // The design pins distance to one decimal ("0.0"), unlike the
              // bare integer delivery count beside it.
              value: stats.distanceKm.toStringAsFixed(1),
              unit: tr.homeDistanceUnit,
              label: tr.homeDistance,
            ),
            _ => StatTile(
              iconPath: AppAssets.icStatTime,
              value: tr.homeShiftHoursMinutes(
                stats.shiftDuration.inHours,
                stats.shiftDuration.inMinutes.remainder(60),
              ),
              unit: tr.homeOnShift,
              label: tr.homeTime,
            ),
          };
        },
      ),
    );
  }
}
