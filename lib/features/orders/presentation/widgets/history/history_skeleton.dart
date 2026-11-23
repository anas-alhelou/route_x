// lib/features/orders/presentation/widgets/history/history_skeleton.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

import '../orders_today/orders_skeleton_box.dart';
import 'history_metrics.dart';

/// The 1500 ms placeholder for a period's history: the summary card with
/// grey bars where the chart will be, then a section label and three rows.
///
/// The chips above it render for real — the driver can switch period
/// before this one has finished loading.
class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key});

  /// Varied so the placeholder reads as a chart, not a grid of blocks.
  static const List<double> _barHeights = [40, 30, 56, 24, 10, 60, 20];

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(HistoryMetrics.cardRadius.r),
      border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
    );

    return OrdersSkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w),
            child: Container(
              padding: EdgeInsets.all(HistoryMetrics.cardPadding.w),
              decoration: cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrdersSkeletonBox(width: 80.w, height: 10.h, radius: 5),
                  SizedBox(height: 18.h),
                  OrdersSkeletonBox(width: 140.w, height: 36.h, radius: 12),
                  SizedBox(height: 14.h),
                  OrdersSkeletonBox(width: 220.w, height: 12.h, radius: 6),
                  SizedBox(height: 26.h),
                  SizedBox(
                    height: 60.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final h in _barHeights)
                          OrdersSkeletonBox(
                            width: HistoryMetrics.barWidth.w,
                            height: h.h,
                            radius: HistoryMetrics.barRadius,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: HistoryMetrics.cardToDaysLabel.h),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: HistoryMetrics.labelGutter.w,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: OrdersSkeletonBox(width: 60.w, height: 10.h, radius: 5),
            ),
          ),
          // Figma H00: the grey label is 10 tall, so 12 to the card.
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              decoration: cardDecoration,
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++) const _RowPlaceholder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowPlaceholder extends StatelessWidget {
  const _RowPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            OrdersSkeletonBox.circle(size: 32.w),
            SizedBox(width: 12.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrdersSkeletonBox(width: 130.w, height: 10.h, radius: 5),
                SizedBox(height: 8.h),
                OrdersSkeletonBox(width: 190.w, height: 10.h, radius: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
