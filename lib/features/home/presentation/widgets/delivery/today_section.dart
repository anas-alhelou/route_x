// lib/features/home/presentation/widgets/delivery/today_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

/// "TODAY" card — Figma HM1–HM4 & HM6 section (360 x 208, inner padding 21).
///
/// Row 1 (17 high): "TODAY" small uppercase label on left, percentage text ("40% done") on right.
/// Delivered block: big number (53 high) followed on baseline by "of 5 delivered".
/// Progress bar: 318 wide x 6 high, 5 separate rounded segments (about 60.4 wide, 4 gap).
/// Stats row: 318 x 42 split into three columns:
/// - Distance: 96 wide
/// - On route: 111 wide with 15 left inset
/// - Couldn't deliver: 111 wide with 15 left inset
class TodaySection extends StatelessWidget {
  const TodaySection({required this.today, super.key});

  final TodaySummary today;

  @override
  Widget build(BuildContext context) {
    final int percent = (today.progressPercent * 100).round();

    final String rightLabel = today.totalOrders == 0
        ? context.tr.homeNoOrdersYet
        : context.tr.homePercentDone(percent);

    final String distanceStr = today.distanceKm == 0
        ? '0'
        : today.distanceKm.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 208.h),
      // 21 from the outer edge in the design = 1 border + 20 padding.
      padding: EdgeInsets.all((AppSizes.cardInnerPad21 - 1).r),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: "TODAY" + "40% done" / "No orders yet" ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr.homeToday,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                  height: 17 / 11,
                ),
              ),
              Text(
                rightLabel,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 17 / 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 17.5.h),

          // ── Delivered block: big number (48sp, 53h) + "of X delivered"
          //    (16sp) bottom-aligned next to it ─────────────────────────────
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${today.deliveredCount}',
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 53 / 48,
                  ),
                ),
                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Text(
                    context.tr.homeOfDelivered(today.totalOrders),
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 22 / 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // ── Progress bar (318w x 6h, 5 segments of 60 with 4.5 gaps) ───────
          SizedBox(
            height: 6.h,
            child: _SegmentedProgressBar(
              segments: today.totalOrders,
              filled: today.deliveredCount,
              failed: today.couldNotDeliver,
            ),
          ),
          SizedBox(height: 16.h),

          // ── Stats row (318w x 42h) ─────────────────────────────────────────
          Container(
            constraints: BoxConstraints(minHeight: 42.h),
            child: Row(
              children: [
                // Col 1: Distance (96 wide)
                SizedBox(
                  width: 96.w,
                  child: _StatColumn(
                    value: '$distanceStr ${context.tr.homeDistanceUnit}',
                    caption: context.tr.homeDistanceLabel,
                  ),
                ),

                // Hairline divider
                Container(
                  width: 1,
                  height: 42.h,
                  color: AppColors.dividerSubtle,
                ),

                // Col 2: On route (111 wide with 15 left inset)
                Container(
                  width: 111.w,
                  padding: EdgeInsetsDirectional.only(start: 15.w),
                  child: _StatColumn(
                    value: today.onRouteTime,
                    caption: context.tr.homeOnRouteLabel,
                  ),
                ),

                // Hairline divider
                Container(
                  width: 1,
                  height: 42.h,
                  color: AppColors.dividerSubtle,
                ),

                // Col 3: Couldn't deliver (110 wide with 15 left inset)
                Expanded(
                  child: Container(
                    padding: EdgeInsetsDirectional.only(start: 15.w),
                    child: _StatColumn(
                      value: '${today.couldNotDeliver}',
                      caption: context.tr.homeCouldNotDeliverLabel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontFamilyFallback: AppFonts.fontFamilyFallback,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 23 / 18,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          caption,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontFamilyFallback: AppFonts.fontFamilyFallback,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            height: 17 / 12,
            color: AppColors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SegmentedProgressBar extends StatelessWidget {
  const _SegmentedProgressBar({
    required this.segments,
    required this.filled,
    this.failed = 0,
  });

  final int segments;
  final int filled;
  final int failed;

  @override
  Widget build(BuildContext context) {
    // If no orders assigned today (HM6), show one continuous light-gray bar
    if (segments <= 0) {
      return Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: AppColors.progressUnfilled,
          borderRadius: BorderRadius.circular(3.r),
        ),
      );
    }

    final count = segments.clamp(1, 10);
    final children = <Widget>[];
    for (var i = 0; i < count; i++) {
      if (i > 0) children.add(SizedBox(width: 4.5.w));
      {
        Color color;
        if (i < filled) {
          color = AppColors.brandMain;
        } else if (i < filled + failed) {
          color = AppColors.progressFailed;
        } else {
          color = AppColors.progressUnfilled;
        }

        children.add(
          Expanded(
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        );
      }
    }
    return Row(children: children);
  }
}
