// lib/features/orders/presentation/widgets/history/history_summary_card.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/order_history_entity.dart';

import '../orders_today/orders_today_metrics.dart';
import 'history_metrics.dart';

/// One figure under a stat column: "94%" over "Delivered".
class HistoryStat {
  const HistoryStat({required this.value, required this.label});
  final String value;
  final String label;
}

/// The period at a glance: one big number, one sentence that says what the
/// number means for this driver, the shape of the period as bars, and the
/// three figures a driver is paid or judged on.
///
/// The sentence carries the weight. "31 deliveries" alone means nothing to
/// someone without their own average to hand; "a bit busier than your usual
/// week" is the comparison they would have had to make themselves.
class HistorySummaryCard extends StatelessWidget {
  const HistorySummaryCard({
    super.key,
    required this.heading,
    required this.rangeLabel,
    required this.figure,
    required this.unit,
    required this.sentence,
    required this.bars,
    required this.stats,
    this.chart,
    this.note,
    this.onTap,
  });

  final String heading;
  final String rangeLabel;
  final int figure;
  final String unit;
  final String sentence;
  final List<HistoryBarEntity> bars;
  final List<HistoryStat> stats;

  /// Replaces the default [HistoryBarChart] — the month draws a bar a day.
  final Widget? chart;

  /// A caveat under the sentence, in warning amber with a sync mark —
  /// "Includes 2 stops not synced yet". Null shows nothing.
  final String? note;

  /// Opens the period's detail.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HistoryMetrics.summaryRadius.r),
        side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(HistoryMetrics.cardPadding.w),
          child: _content(),
        ),
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                heading,
                style: AppTextStyles.s10Bold.scaled.copyWith(
                  height: 1.4,
                  color: AppColors.textMuted,
                  letterSpacing: 0.2.sp,
                ),
              ),
            ),
            Text(
              rangeLabel,
              style: AppTextStyles.s12Medium.scaled.copyWith(
                height: 1.4,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: HistoryMetrics.headingToFigure.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$figure',
              style: AppTextStyles.s36Bold.scaled.copyWith(
                fontSize: 48.sp,
                height: 1.15,
                letterSpacing: -0.96.sp,
                color: AppColors.brandMain,
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                unit,
                style: AppTextStyles.s16Medium.scaled.copyWith(
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: HistoryMetrics.figureToSentence.h),
        Text(
          sentence,
          style: AppTextStyles.s14Medium.scaled.copyWith(
            height: 1.4,
            color: AppColors.brandBlack,
          ),
        ),
        if (note != null) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.svg.sync.svg(width: 14.w, height: 14.w),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  note!,
                  style: AppTextStyles.s12Medium.scaled.copyWith(
                    height: 1.4,
                    color: AppColors.statusAmber,
                  ),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: HistoryMetrics.sentenceToChart.h),
        chart ?? HistoryBarChart(bars: bars),
        SizedBox(height: HistoryMetrics.chartToDivider.h),
        Divider(
          height: 1.h,
          thickness: 1.h,
          color: AppColors.borderDeactivated,
        ),
        SizedBox(height: HistoryMetrics.dividerToStats.h),
        HistoryStatsRow(stats: stats),
      ],
    );
  }
}

/// Bars scaled to the period's busiest slot. The current slot is the only
/// green one, so "where am I in this week" is answered before any label is
/// read.
class HistoryBarChart extends StatelessWidget {
  const HistoryBarChart({super.key, required this.bars});

  final List<HistoryBarEntity> bars;

  @override
  Widget build(BuildContext context) {
    final busiest = bars.fold<int>(0, (top, b) => math.max(top, b.deliveries));
    final chartHeight = HistoryMetrics.chartHeight.h;
    final minHeight = HistoryMetrics.barMinHeight.h;

    double heightOf(HistoryBarEntity bar) => busiest == 0
        ? minHeight
        : math.max(minHeight, chartHeight * bar.deliveries / busiest);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final bar in bars)
          Semantics(
            label: '${bar.label}: ${bar.deliveries}',
            excludeSemantics: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: chartHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: HistoryMetrics.barWidth.w,
                      height: heightOf(bar),
                      decoration: BoxDecoration(
                        color: bar.isCurrent
                            ? AppColors.brandMain
                            : AppColors.borderDeactivated,
                        borderRadius: BorderRadius.circular(
                          // Never rounder than the bar is tall, or a short
                          // bar renders as a pill floating off the axis.
                          math.min(
                            HistoryMetrics.barRadius.r,
                            heightOf(bar) / 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: HistoryMetrics.barToLabel.h),
                Text(
                  bar.label,
                  style:
                      (bar.isCurrent
                              ? AppTextStyles.s11Bold
                              : AppTextStyles.s11Medium)
                          .scaled
                          .copyWith(
                            height: 1.4,
                            color: bar.isCurrent
                                ? AppColors.brandBlack
                                : AppColors.textMuted,
                          ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Figures side by side between hairline dividers — on the summary card,
/// and at the top of a single day.
class HistoryStatsRow extends StatelessWidget {
  const HistoryStatsRow({super.key, required this.stats});

  final List<HistoryStat> stats;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              VerticalDivider(
                width: 1.w,
                thickness: 1.w,
                color: AppColors.borderDeactivated,
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        stats[i].value,
                        style: AppTextStyles.s16Bold.scaled.copyWith(
                          fontSize: 18.sp,
                          height: 1.4,
                          color: AppColors.brandBlack,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      stats[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s12Regular.scaled.copyWith(
                        height: 1.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// In the summary's place when the server sent the days but not the
/// figures — "This week's summary didn't load. Your days below are up to
/// date." Amber, not red: nothing the driver did is lost, and the list
/// under it is right.
class HistorySummaryErrorCard extends StatelessWidget {
  const HistorySummaryErrorCard({
    super.key,
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.retrying = false,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  /// Retry is running: a spinner in its place, and no second tap.
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final well = 36.w;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            width: well,
            height: well,
            decoration: BoxDecoration(
              color: AppColors.statusAmberSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.statusAmber, width: 1.w),
            ),
            child: Center(
              child: Assets.icons.svg.offlineAmber.svg(
                width: 20.w,
                height: 20.w,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s14Bold.scaled.copyWith(
                    height: 1.4,
                    color: AppColors.brandBlack,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: AppTextStyles.s12Regular.scaled.copyWith(
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Material(
            color: AppColors.surfaceBadge,
            borderRadius: BorderRadius.circular(999.r),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: retrying ? null : onRetry,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: retrying
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.brandBlack,
                        ),
                      )
                    : Text(
                        retryLabel,
                        style: AppTextStyles.s14Bold.scaled.copyWith(
                          fontSize: 13.sp,
                          height: 1.4,
                          color: AppColors.brandBlack,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
