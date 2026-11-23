// lib/features/orders/presentation/widgets/orders_today/orders_row_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today_metrics.dart';

/// The shared skeleton of every row inside an [OrdersCard]: a leading badge,
/// a two-line text column, and a trailing affordance.
///
/// Every row on this screen is the same shape so the driver's eye can run
/// straight down the leading badges without re-reading the layout; only what
/// sits in each slot changes.
class OrdersRowTile extends StatelessWidget {
  const OrdersRowTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.muted = false,
  });

  final Widget leading;
  final String title;
  final String subtitle;

  /// Defaults to a chevron when omitted.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// Greys both lines for a row that is still listed but no longer work —
  /// a cancelled stop. Keeps the shape so the list does not reflow.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: OrdersTodayMetrics.rowMinHeight.h,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                leading,
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.s14Bold.scaled.copyWith(
                          height: 1.4,
                          color: muted
                              ? AppColors.textGray
                              : AppColors.brandBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: AppTextStyles.s12Regular.scaled.copyWith(
                          height: 1.4,
                          color:
                              muted ? AppColors.iconHint : AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                trailing ?? const OrdersRowChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The default trailing affordance: "there is a screen behind this row".
///
/// Points the way the reader is travelling, so it still means "forward" in
/// Arabic rather than "back".
class OrdersRowChevron extends StatelessWidget {
  const OrdersRowChevron({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Transform.flip(
      flipX: isRtl,
      child: Assets.icons.svg.chevron.svg(width: 24.w, height: 24.w),
    );
  }
}

/// A circular well for the row's leading slot.
class OrdersRowBadge extends StatelessWidget {
  const OrdersRowBadge({
    super.key,
    required this.child,
    this.background,
    this.borderColor,
  });

  final Widget child;
  /// Fill; null follows the theme ([AppColors.surfaceBadge]).
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final size = OrdersTodayMetrics.leadingBadgeSize.w;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? AppColors.surfaceBadge,
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1.w),
      ),
      child: Center(child: child),
    );
  }
}
