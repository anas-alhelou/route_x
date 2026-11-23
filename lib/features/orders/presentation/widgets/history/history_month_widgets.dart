// lib/features/orders/presentation/widgets/history/history_month_widgets.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../../domain/entities/order_history_entity.dart';
import '../orders_today/orders_row_tile.dart';
import '../orders_today/orders_today_metrics.dart';
import 'history_metrics.dart';

/// The month as a bar a day. Thirty-odd bars can't each carry a label, so
/// only the first of every week does — 1, 8, 15, 22, 29 — and days with
/// nothing (a day off, or still to come) sit on the axis as dashes, so the
/// month's length is visible from its first day.
class HistoryMonthChart extends StatelessWidget {
  const HistoryMonthChart({super.key, required this.bars});

  final List<HistoryBarEntity> bars;

  /// Every seventh day gets its number under it.
  static const int labelEvery = 7;

  static const double barWidth = 6;
  static const double dashHeight = 3;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) return const SizedBox.shrink();

    final busiest = bars.fold<int>(0, (top, b) => math.max(top, b.deliveries));
    final chartHeight = HistoryMetrics.chartHeight.h;
    final labelStyle = AppTextStyles.s11Medium.scaled
        .copyWith(height: 1.4, color: AppColors.textMuted);

    return LayoutBuilder(
      builder: (context, constraints) {
        final slot = constraints.maxWidth / bars.length;
        // Figma lines each number up with the left edge of its bar.
        final barInset = (slot - barWidth.w) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final bar in bars)
                    SizedBox(
                      width: slot,
                      child: Semantics(
                        label: '${bar.heading}: ${bar.deliveries}',
                        excludeSemantics: true,
                        child: Center(
                          heightFactor: 1,
                          child: _bar(bar, busiest, chartHeight),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: HistoryMetrics.barToLabel.h),
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Gives the row a line's height; the labels are placed
                // over it.
                Text(' ', style: labelStyle),
                for (var i = 0; i < bars.length; i += labelEvery)
                  PositionedDirectional(
                    start: slot * i + barInset,
                    child: Text(
                      bars[i].label,
                      maxLines: 1,
                      softWrap: false,
                      style: labelStyle,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _bar(HistoryBarEntity bar, int busiest, double chartHeight) {
    final width = barWidth.w;

    if (bar.deliveries == 0 || busiest == 0) {
      return Container(
        width: width,
        height: dashHeight.h,
        decoration: BoxDecoration(
          color: AppColors.borderDeactivated,
          borderRadius: BorderRadius.circular(dashHeight.h / 2),
        ),
      );
    }

    final height = math.max(
      HistoryMetrics.barMinHeight.h,
      chartHeight * bar.deliveries / busiest,
    );
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bar.isCurrent ? AppColors.brandMain : AppColors.borderDeactivated,
        borderRadius: BorderRadius.circular(width / 2),
      ),
    );
  }
}

/// One observation the driver can act on, in plain words — "Delivered is
/// at 92%, a little under your usual 96%…". Not tappable: the advice is
/// the whole of it.
class HistoryInsightCard extends StatelessWidget {
  const HistoryInsightCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(HistoryMetrics.cardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.s14Bold.scaled
                .copyWith(height: 1.4, color: AppColors.brandBlack),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: AppTextStyles.s14Regular.scaled.copyWith(
              fontSize: 13.sp,
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// One week of the month, in the same route-green shape as a day row.
class HistoryWeekTile extends StatelessWidget {
  const HistoryWeekTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  /// Already localized: "This week · 5 — 11 Oct", or the range alone.
  final String title;

  /// "31 delivered · 2 couldn't deliver".
  final String subtitle;

  /// Null leaves the row inert and drops its chevron.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OrdersRowTile(
      onTap: onTap,
      leading: OrdersRowBadge(
        background: AppColors.brandMain,
        child: Assets.icons.svg.route.svg(width: 20.w, height: 20.w),
      ),
      title: title,
      subtitle: subtitle,
      trailing: onTap == null ? const SizedBox.shrink() : null,
    );
  }
}
