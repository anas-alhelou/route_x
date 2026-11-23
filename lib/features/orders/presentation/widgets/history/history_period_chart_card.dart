// lib/features/orders/presentation/widgets/history/history_period_chart_card.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/order_history_entity.dart';

import '../orders_today/orders_today_metrics.dart';
import 'history_metrics.dart';

/// The period bar by bar, against the driver's own usual. Tap a bar to read
/// it: the heading and the big figure follow the selection.
///
/// The dashed line is the point of the chart. A bare bar says "7"; a bar
/// standing well over the line says "a big day for you" without a number
/// being read at all.
class HistoryPeriodChartCard extends StatefulWidget {
  const HistoryPeriodChartCard({
    super.key,
    required this.bars,
    required this.usualPerBar,
    required this.unitLabel,
    required this.usualLabel,
  });

  final List<HistoryBarEntity> bars;

  /// Where the dashed line sits, in deliveries.
  final double usualPerBar;

  /// Localized "delivered", after the big figure.
  final String unitLabel;

  /// Localized "Your usual day: 4.4", beside the legend dash.
  final String usualLabel;

  /// Taller than the summary's chart: here the chart is the content, not a
  /// thumbnail of it.
  static const double chartHeight = 130;

  @override
  State<HistoryPeriodChartCard> createState() => _HistoryPeriodChartCardState();
}

class _HistoryPeriodChartCardState extends State<HistoryPeriodChartCard> {
  /// Opens on the current slot — today, this week — the one the driver most
  /// likely came to check.
  late int _selected = _initialSelection();

  int _initialSelection() {
    final current = widget.bars.indexWhere((b) => b.isCurrent);
    return current >= 0 ? current : widget.bars.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final bars = widget.bars;
    if (bars.isEmpty) return const SizedBox.shrink();
    final selected = bars[_selected.clamp(0, bars.length - 1)];

    return Container(
      padding: EdgeInsets.all(HistoryMetrics.cardPadding.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(HistoryMetrics.summaryRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selected.heading.toUpperCase(),
            style: AppTextStyles.s10Bold.scaled.copyWith(
              height: 1.4,
              color: AppColors.textMuted,
              letterSpacing: 0.2.sp,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${selected.deliveries}',
                style: AppTextStyles.s32Bold.scaled.copyWith(
                  height: 1.15,
                  letterSpacing: -0.64.sp,
                  color: AppColors.brandMain,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                widget.unitLabel,
                style: AppTextStyles.s14Medium.scaled
                    .copyWith(height: 1.4, color: AppColors.textMuted),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          _Chart(
            bars: bars,
            usual: widget.usualPerBar,
            selected: _selected,
            onSelect: (i) => setState(() => _selected = i),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(
                width: 16.w,
                child: CustomPaint(
                  size: Size(16.w, 1.h),
                  painter: _DashPainter(color: AppColors.textMuted),
                ),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  widget.usualLabel,
                  style: AppTextStyles.s12Medium.scaled
                      .copyWith(height: 1.4, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({
    required this.bars,
    required this.usual,
    required this.selected,
    required this.onSelect,
  });

  final List<HistoryBarEntity> bars;
  final double usual;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final height = HistoryPeriodChartCard.chartHeight.h;
    final minHeight = HistoryMetrics.barMinHeight.h;
    // Scale to whichever is higher, the busiest bar or the usual line, so
    // the line is never drawn off the top of the chart.
    final top = math.max(
      bars.fold<int>(0, (m, b) => math.max(m, b.deliveries)).toDouble(),
      usual,
    );

    double heightOf(int deliveries) =>
        top == 0 ? minHeight : math.max(minHeight, height * deliveries / top);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < bars.length; i++)
                    _Bar(
                      bar: bars[i],
                      height: heightOf(bars[i].deliveries),
                      selected: i == selected,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
              if (usual > 0 && top > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: height * usual / top,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: Size(double.infinity, 1.h),
                      painter: _DashPainter(color: AppColors.textMuted),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: HistoryMetrics.barToLabel.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < bars.length; i++)
              SizedBox(
                // Same width as a bar's tap column, so each label centres
                // under its own bar.
                width: HistoryMetrics.barWidth.w + 8.w,
                child: Text(
                  bars[i].label,
                  textAlign: TextAlign.center,
                  style: (i == selected
                          ? AppTextStyles.s11Bold
                          : AppTextStyles.s11Medium)
                      .scaled
                      .copyWith(
                        height: 1.4,
                        color: i == selected
                            ? AppColors.brandBlack
                            : AppColors.textMuted,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.bar,
    required this.height,
    required this.selected,
    required this.onTap,
  });

  final HistoryBarEntity bar;
  final double height;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${bar.heading}: ${bar.deliveries}',
      excludeSemantics: true,
      child: GestureDetector(
        // The whole column is the target, not just the bar: a zero day is a
        // 4dp sliver nobody could hit.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: HistoryMetrics.barWidth.w + 8.w,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: HistoryMetrics.barWidth.w,
              height: height,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.brandMain
                    : AppColors.borderDeactivated,
                borderRadius: BorderRadius.circular(
                  math.min(HistoryMetrics.barRadius.r, height / 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal dashed rule, 4dp on and 4dp off.
class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + dash, size.width), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
