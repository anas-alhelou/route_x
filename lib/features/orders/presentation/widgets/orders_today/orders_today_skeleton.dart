// lib/features/orders/presentation/widgets/orders_today/orders_today_skeleton.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

import 'orders_skeleton_box.dart';
import 'orders_today_metrics.dart';

/// The 1500 ms placeholder for the day's plan.
///
/// It reserves the same vertical rhythm as the loaded screen — same gutters,
/// same gaps, four rows in the same card — so the real content lands in
/// place instead of pushing the page around under the driver's thumb.
///
/// Only the parts that are genuinely unknown are greyed. The title, the
/// search button and the segmented control render for real above this, since
/// they are already actionable.
class OrdersTodaySkeleton extends StatelessWidget {
  const OrdersTodaySkeleton({super.key});

  /// Width pairs for each placeholder row's two text lines, varied so the
  /// block reads as text rather than as a grid.
  static const List<List<double>> _rowLineWidths = [
    [150, 170],
    [120, 190],
    [150, 170],
    [120, 190],
  ];

  @override
  Widget build(BuildContext context) {
    return OrdersSkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stands in for the "new orders" banner.
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: OrdersTodayMetrics.gutter.w,
            ),
            child: OrdersSkeletonBox(
              height: 72.h,
              radius: OrdersTodayMetrics.cardRadius,
            ),
          ),
          SizedBox(height: OrdersTodayMetrics.bannerToTodayLabel.h),

          _LabelPlaceholder(width: 70.w),
          // Figma O00: 12 from the grey label to the card.
          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: OrdersTodayMetrics.gutter.w,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius:
                    BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
                border:
                    Border.all(color: AppColors.borderDeactivated, width: 1.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final widths in _rowLineWidths)
                    _RowPlaceholder(
                      firstLineWidth: widths[0],
                      secondLineWidth: widths[1],
                    ),
                ],
              ),
            ),
          ),
          // Figma O00: 24 below the list; the grey label is 10 tall, not
          // the real 17dp label, so the real 7dp gap would read too tight.
          SizedBox(height: 24.h),

          _LabelPlaceholder(width: 90.w),
          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: OrdersTodayMetrics.gutter.w,
            ),
            child: OrdersSkeletonBox(
              height: 64.h,
              radius: OrdersTodayMetrics.cardRadius,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelPlaceholder extends StatelessWidget {
  const _LabelPlaceholder({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: OrdersTodayMetrics.labelGutter.w,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: OrdersSkeletonBox(width: width, height: 10.h, radius: 5),
      ),
    );
  }
}

class _RowPlaceholder extends StatelessWidget {
  const _RowPlaceholder({
    required this.firstLineWidth,
    required this.secondLineWidth,
  });

  final double firstLineWidth;
  final double secondLineWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            OrdersSkeletonBox.circle(
              size: OrdersTodayMetrics.leadingBadgeSize.w,
            ),
            SizedBox(width: 12.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrdersSkeletonBox(
                  width: firstLineWidth.w,
                  height: 10.h,
                  radius: 5,
                ),
                SizedBox(height: 8.h),
                OrdersSkeletonBox(
                  width: secondLineWidth.w,
                  height: 10.h,
                  radius: 5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
