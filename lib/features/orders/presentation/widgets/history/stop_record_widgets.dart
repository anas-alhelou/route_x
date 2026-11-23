// lib/features/orders/presentation/widgets/history/stop_record_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_skeleton_box.dart';
import '../orders_today/orders_today_metrics.dart';
import 'history_metrics.dart';

/// How the outcome card is coloured.
enum StopOutcomeTone {
  /// A failure nobody has disputed yet: stated, not shouted.
  plain,

  /// Delivered — the good outcome, in brand green.
  positive,

  /// A failure now under dispute: this card is the thing being disputed.
  flagged,
}

/// How a stop ended, said once at the top: a badge, a verdict, and what
/// it means for the driver now.
class StopOutcomeCard extends StatelessWidget {
  const StopOutcomeCard({
    super.key,
    required this.badge,
    required this.title,
    required this.message,
    this.tone = StopOutcomeTone.plain,
  });

  final Widget badge;
  final String title;
  final String message;
  final StopOutcomeTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, border) = switch (tone) {
      StopOutcomeTone.plain => (
          AppColors.surfaceWhite,
          AppColors.borderDeactivated,
        ),
      StopOutcomeTone.positive => (AppColors.iconBrand, AppColors.brandMain),
      StopOutcomeTone.flagged => (AppColors.iconWarning, AppColors.iconRed),
    };

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: background,
        // Figma rounds the delivered card a little less than the others.
        borderRadius: BorderRadius.circular(
          (tone == StopOutcomeTone.positive
                  ? HistoryMetrics.cardRadius
                  : HistoryMetrics.recordCardRadius)
              .r,
        ),
        border: Border.all(color: border, width: 1.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          badge,
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s14Bold.scaled
                      .copyWith(height: 1.4, color: AppColors.brandBlack),
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: AppTextStyles.s12Regular.scaled
                      .copyWith(height: 1.4, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Takes the report button's place once the issue is sent: says it went,
/// and where the answer will come — so the driver stops checking this
/// screen for one.
///
/// Amber, the colour of things pending, not green: nothing is resolved yet.
class IssueSentCard extends StatelessWidget {
  const IssueSentCard({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.statusAmberSurface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Assets.icons.svg.timer.svg(width: 24.w, height: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.s14Bold.scaled.copyWith(
                      height: 1.4,
                      color: AppColors.statusAmber,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    message,
                    style: AppTextStyles.s12Regular.scaled
                        .copyWith(height: 1.4, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The colour of a timeline dot. Green for what went right, red for the
/// moment it went wrong, grey for everything in between — so the shape of
/// the stop reads before any line of it does.
enum StopEventTone { good, bad, neutral }

/// One line of the timeline, already localized.
class StopTimelineEntry {
  const StopTimelineEntry({
    required this.title,
    required this.time,
    required this.tone,
    this.detail,
  });

  final String title;
  final String time;
  final StopEventTone tone;
  final String? detail;
}

/// "WHAT HAPPENED" — the stop's log, oldest first, as a vertical timeline.
///
/// It exists so a driver can answer for a failed stop with facts — I was
/// there, 12 m away; I called twice; I waited — instead of memory, when
/// dispatch asks a week later.
class StopTimelineCard extends StatelessWidget {
  const StopTimelineCard({
    super.key,
    required this.label,
    required this.entries,
  });

  final String label;

  /// Null while loading: placeholder rows hold the shape.
  final List<StopTimelineEntry>? entries;

  @override
  Widget build(BuildContext context) {
    final rows = entries;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(HistoryMetrics.recordCardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTextStyles.s10Bold.scaled.copyWith(
              height: 1.4,
              color: AppColors.textMuted,
              letterSpacing: 0.2.sp,
            ),
          ),
          SizedBox(height: 10.h),
          if (rows == null)
            const _TimelineSkeleton()
          else
            for (var i = 0; i < rows.length; i++)
              _TimelineRow(entry: rows[i], isLast: i == rows.length - 1),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});

  final StopTimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (entry.tone) {
      StopEventTone.good => AppColors.brandMain,
      StopEventTone.bad => AppColors.error,
      StopEventTone.neutral => AppColors.borderDeactivated,
    };
    final detail = entry.detail;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 12.w,
            child: Column(
              children: [
                SizedBox(height: 5.h),
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // The rail runs down to the next dot, so the eye can follow
                // the stop in order without reading the times.
                if (!isLast)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Container(
                        width: 2.w,
                        color: AppColors.borderDeactivated,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              // The last row keeps its rail's 36dp in Figma, so the card does
              // not end tight under the final event.
              padding: EdgeInsets.only(bottom: isLast ? 16.h : 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: AppTextStyles.s14Bold.scaled.copyWith(
                            height: 1.4,
                            color: AppColors.brandBlack,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        entry.time,
                        style: AppTextStyles.s12Medium.scaled
                            .copyWith(height: 1.4, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (detail != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      detail,
                      style: AppTextStyles.s12Regular.scaled
                          .copyWith(height: 1.4, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return OrdersSkeletonPulse(
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 18.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrdersSkeletonBox.circle(size: 12.w),
                  SizedBox(width: 24.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrdersSkeletonBox(width: 140.w, height: 10.h, radius: 5),
                      SizedBox(height: 8.h),
                      OrdersSkeletonBox(width: 180.w, height: 10.h, radius: 5),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
