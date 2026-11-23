// lib/features/orders/presentation/widgets/orders_today/orders_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

import 'orders_today_metrics.dart';

/// The bordered white container both lists share, with hairline dividers
/// drawn between its children.
///
/// The dividers are inset to the row's text column rather than run edge to
/// edge: a full-bleed rule would read as a break between cards, and these
/// rows are one card.
class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key, required this.children, this.dividerInset = 16});

  final List<Widget> children;
  final double dividerInset;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dividerInset.w),
            child: Divider(
              height: 1.h,
              thickness: 1.h,
              color: AppColors.borderDeactivated,
            ),
          ),
        );
      }
      rows.add(children[i]);
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Padding(
        // Figma: 4 above the first row and below the last, on top of the
        // rows' own 12.
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}
