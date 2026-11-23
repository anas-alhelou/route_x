// lib/features/orders/presentation/widgets/history/history_period_chips.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/order_history_entity.dart';

import '../orders_today/orders_today_metrics.dart';
import 'history_metrics.dart';

/// Today / Week / Month. Lighter than the search filter chips — no outline
/// on the unselected ones — because this sits directly under the segmented
/// control, and two outlined rows stacked would read as one control.
class HistoryPeriodChips extends StatelessWidget {
  const HistoryPeriodChips({
    super.key,
    required this.period,
    required this.labels,
    required this.onChanged,
  });

  final HistoryPeriod period;
  final Map<HistoryPeriod, String> labels;
  final ValueChanged<HistoryPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w),
      child: Row(
        children: [
          for (final value in HistoryPeriod.values) ...[
            if (value != HistoryPeriod.values.first)
              SizedBox(width: HistoryMetrics.chipGap.w),
            _PeriodChip(
              label: labels[value] ?? value.name,
              selected: value == period,
              onTap: () => onChanged(value),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.brandBlack : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: HistoryMetrics.chipHeight.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.s14SemiBold.scaled.copyWith(
                fontSize: 13.sp,
                height: 1.4,
                color: selected ? AppColors.surfaceWhite : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
