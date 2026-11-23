// lib/features/orders/presentation/widgets/orders_today/orders_segmented_control.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/orders_today_entity.dart';

import 'orders_today_metrics.dart';

/// Two-up switch between the live day plan and the delivered archive.
///
/// The selected thumb slides rather than cutting, because the driver taps
/// this while moving and the motion is what tells them the tap landed.
class OrdersSegmentedControl extends StatelessWidget {
  const OrdersSegmentedControl({
    super.key,
    required this.segment,
    required this.ordersLabel,
    required this.historyLabel,
    required this.onChanged,
  });

  final OrdersTodaySegment segment;
  final String ordersLabel;
  final String historyLabel;
  final ValueChanged<OrdersTodaySegment> onChanged;

  @override
  Widget build(BuildContext context) {
    const inset = 3.0;
    final height = OrdersTodayMetrics.segmentedHeight.h;
    final isOrders = segment == OrdersTodaySegment.orders;

    return Container(
      height: height,
      padding: EdgeInsets.all(inset.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceBadge,
        borderRadius:
            BorderRadius.circular(OrdersTodayMetrics.segmentedRadius.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbWidth = constraints.maxWidth / 2;

          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                start: isOrders ? 0 : thumbWidth,
                top: 0,
                bottom: 0,
                width: thumbWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.brandMain,
                    borderRadius: BorderRadius.circular(
                      (OrdersTodayMetrics.segmentedRadius - 2).r,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14222222),
                        offset: Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _Segment(
                      label: ordersLabel,
                      selected: isOrders,
                      onTap: () => onChanged(OrdersTodaySegment.orders),
                    ),
                  ),
                  Expanded(
                    child: _Segment(
                      label: historyLabel,
                      selected: !isOrders,
                      onTap: () => onChanged(OrdersTodaySegment.history),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: (selected
                    ? AppTextStyles.s14Bold
                    : AppTextStyles.s14Medium)
                .scaled
                .copyWith(
                  height: 1.4,
                  color:
                      selected ? AppColors.brandBlack : AppColors.textMuted,
                ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
