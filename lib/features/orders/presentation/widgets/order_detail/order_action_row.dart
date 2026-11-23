// lib/features/orders/presentation/widgets/order_detail/order_action_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';
import 'order_detail_metrics.dart';

/// One of the three equal-width actions above the cards.
class OrderActionItem {
  const OrderActionItem({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final Widget icon;
  final String label;

  /// Null renders the button disabled — e.g. Call before the phone number
  /// has loaded.
  final VoidCallback? onPressed;
}

/// Call / Message / Navigate, as three large equal targets.
///
/// Big and evenly split on purpose: these get hit one-handed at a kerb, and
/// equal widths mean the driver's thumb learns three fixed positions instead
/// of reading labels.
class OrderActionRow extends StatelessWidget {
  const OrderActionRow({super.key, required this.actions});

  final List<OrderActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: OrderDetailMetrics.gutter.w),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: OrderDetailMetrics.actionGap.w),
            Expanded(child: _OrderActionButton(item: actions[i])),
          ],
        ],
      ),
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({required this.item});

  final OrderActionItem item;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(OrderDetailMetrics.actionRadius.r);
    final enabled = item.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: item.label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: AppColors.surfaceCanvas,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: item.onPressed,
            child: SizedBox(
              height: OrderDetailMetrics.actionHeight.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item.icon,
                  SizedBox(height: 6.h),
                  Text(
                    item.label,
                    style: AppTextStyles.s12Bold.scaled
                        .copyWith(height: 1.4, color: AppColors.brandBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
