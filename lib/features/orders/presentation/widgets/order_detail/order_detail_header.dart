// lib/features/orders/presentation/widgets/order_detail/order_detail_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';
import 'order_detail_metrics.dart';

/// "‹ Orders" — the way back to the list this screen was opened from.
///
/// Pinned above the scroll view: on a screen this long the driver should
/// never have to scroll up to leave.
class OrderDetailBackButton extends StatelessWidget {
  const OrderDetailBackButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: OrderDetailMetrics.backTop.h,
        // The chevron glyph carries ~6dp of air on its leading side; pull
        // the box in so the visible stroke sits on the gutter.
        start: (OrderDetailMetrics.gutter - 6).w,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              height: OrderDetailMetrics.backHeight.h,
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: 8.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.flip(
                      flipX: isRtl,
                      child: Assets.icons.svg.back.svg(
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      label,
                      style: AppTextStyles.s14Bold.scaled.copyWith(
                        fontSize: 15.sp,
                        height: 1.4,
                        color: AppColors.brandBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Status pill, order code, customer name and route position.
///
/// Name and status come from the Today row that was tapped, so they paint on
/// the first frame; [orderCode] and [routePosition] arrive with the detail
/// and slot in without moving the name.
class OrderDetailHero extends StatelessWidget {
  const OrderDetailHero({
    super.key,
    required this.statusLabel,
    required this.isOnTheWay,
    required this.customerName,
    this.orderCode,
    this.routePosition,
  });

  final String statusLabel;
  final bool isOnTheWay;
  final String customerName;

  /// Already formatted without the `#`; null while loading.
  final String? orderCode;

  /// "Stop 4 of 5 · Today"; null while loading.
  final String? routePosition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: OrderDetailMetrics.gutter.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OrderStatusPill(label: statusLabel, isOnTheWay: isOnTheWay),
              if (orderCode != null) ...[
                SizedBox(width: 8.w),
                Text(
                  '#$orderCode',
                  style: AppTextStyles.s12Medium.scaled
                      .copyWith(height: 1.4, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
          SizedBox(height: OrderDetailMetrics.statusToName.h),
          Text(
            customerName,
            style: AppTextStyles.s28Bold.scaled.copyWith(
              height: 1.15,
              letterSpacing: -0.28.sp,
              color: AppColors.brandBlack,
            ),
          ),
          // Reserve the line while loading so the action row below does not
          // jump when the detail lands.
          Text(
            routePosition ?? '',
            style: AppTextStyles.s14Regular.scaled
                .copyWith(height: 1.4, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Where the stop stands: "To do" in neutral grey, or "On the way" in the
/// same green the Today list uses for the current stop.
class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({
    super.key,
    required this.label,
    required this.isOnTheWay,
  });

  final String label;
  final bool isOnTheWay;

  @override
  Widget build(BuildContext context) {
    final ink = isOnTheWay ? AppColors.brandMain : AppColors.brandBlack;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isOnTheWay ? AppColors.iconBrand : AppColors.surfaceCanvas,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: isOnTheWay
              ? AppColors.brandMain
              : AppColors.borderDeactivated,
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOnTheWay) ...[
            Assets.icons.svg.navigateBrand.svg(width: 16.w, height: 16.w),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: AppTextStyles.s11Bold.scaled.copyWith(height: 1.4, color: ink),
          ),
        ],
      ),
    );
  }
}
