// lib/features/orders/presentation/widgets/history/history_breakdown_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';
import 'history_metrics.dart';

/// One figure explained: a title and its value on one line, then what it is
/// made of underneath.
class HistoryBreakdownRow {
  const HistoryBreakdownRow({
    required this.title,
    required this.value,
    this.detail,
  });

  final String title;
  final String value;

  /// Whatever explains the value — a sentence, a split bar, a list.
  final Widget? detail;
}

/// The summary's figures, each with the reasoning behind it, in one card.
///
/// Every number here is one a driver could be asked to account for, so each
/// carries its own explanation underneath rather than leaving the driver to
/// reconstruct it: what was not counted, where the hours went, why orders
/// failed.
class HistoryBreakdownCard extends StatelessWidget {
  const HistoryBreakdownCard({super.key, required this.rows});

  final List<HistoryBreakdownRow> rows;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: HistoryMetrics.cardPadding.w,
            ),
            child: Divider(
              height: 1.h,
              thickness: 1.h,
              color: AppColors.borderDeactivated,
            ),
          ),
        );
      }
      children.add(_Row(row: rows[i]));
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(HistoryMetrics.cardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});

  final HistoryBreakdownRow row;

  @override
  Widget build(BuildContext context) {
    final heading = AppTextStyles.s14Bold.scaled.copyWith(
      height: 1.4,
      color: AppColors.brandBlack,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: HistoryMetrics.cardPadding.w,
        vertical: 14.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(row.title, style: heading)),
              SizedBox(width: 12.w),
              Text(row.value, style: heading),
            ],
          ),
          if (row.detail != null) ...[
            SizedBox(height: 4.h),
            row.detail!,
          ],
        ],
      ),
    );
  }
}

/// The explaining sentence under a figure.
class HistoryBreakdownNote extends StatelessWidget {
  const HistoryBreakdownNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.s12Regular.scaled
          .copyWith(height: 1.4, color: AppColors.textMuted),
    );
  }
}

/// Time on the road as one bar: green for driving, grey for parked at
/// stops. The proportion answers "was it the traffic or the doorsteps"
/// before the minutes underneath are read.
class HistoryTimeSplit extends StatelessWidget {
  const HistoryTimeSplit({
    super.key,
    required this.drivingMinutes,
    required this.stopMinutes,
    required this.caption,
  });

  final int drivingMinutes;
  final int stopMinutes;

  /// "15h 10m driving · 6h 30m at stops".
  final String caption;

  @override
  Widget build(BuildContext context) {
    final total = drivingMinutes + stopMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (total > 0) ...[
          SizedBox(
            height: 8.h,
            child: Row(
              // The segments have no content of their own; without stretch
              // they collapse to zero height and the bar disappears.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (drivingMinutes > 0)
                  Expanded(
                    flex: drivingMinutes,
                    child: _Segment(color: AppColors.brandMain),
                  ),
                if (drivingMinutes > 0 && stopMinutes > 0)
                  SizedBox(width: 4.w),
                if (stopMinutes > 0)
                  Expanded(
                    flex: stopMinutes,
                    child: _Segment(color: AppColors.borderDeactivated),
                  ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
        ],
        HistoryBreakdownNote(caption),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

/// "Customer not answering — 1", one line per reason.
class HistoryReasonList extends StatelessWidget {
  const HistoryReasonList({super.key, required this.reasons});

  /// Label and count, already localized.
  final List<(String, int)> reasons;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.s14Regular.scaled.copyWith(
      fontSize: 13.sp,
      height: 1.4,
      color: AppColors.textMuted,
    );
    final count = AppTextStyles.s14Medium.scaled.copyWith(
      fontSize: 13.sp,
      height: 1.4,
      color: AppColors.textMuted,
    );

    return Column(
      children: [
        for (var i = 0; i < reasons.length; i++) ...[
          if (i > 0) SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(child: Text(reasons[i].$1, style: style)),
              Text('${reasons[i].$2}', style: count),
            ],
          ),
        ],
      ],
    );
  }
}
