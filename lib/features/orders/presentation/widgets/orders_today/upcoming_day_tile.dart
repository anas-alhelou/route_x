// lib/features/orders/presentation/widgets/orders_today/upcoming_day_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/orders_today_entity.dart';

import 'orders_row_tile.dart';
import 'orders_today_metrics.dart';

/// A future day, collapsed to one row.
///
/// Upcoming days get no stop numbers and no status colour — nothing here is
/// actionable yet, and colouring it would compete with today's list for the
/// driver's attention. The one exception is the "N new" pill: a changed day
/// is the thing the driver needs to find on this list, so it alone is green.
class UpcomingDayTile extends StatelessWidget {
  const UpcomingDayTile({
    super.key,
    required this.day,
    required this.ordersCountLabel,
    this.newCountLabel,
    this.onTap,
  });

  final UpcomingDayEntity day;

  /// Localized "N orders", passed in so the tile stays presentation-only.
  final String ordersCountLabel;

  /// Localized "N new"; null hides the pill.
  final String? newCountLabel;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final areas = day.areas.join(', ');

    return OrdersRowTile(
      onTap: onTap,
      leading: OrdersRowBadge(
        child: Assets.icons.svg.history.svg(width: 22.w, height: 22.w),
      ),
      title: day.title,
      subtitle:
          areas.isEmpty ? ordersCountLabel : '$ordersCountLabel · $areas',
      // Beside the chevron, not instead of it: the row still opens.
      trailing: newCountLabel == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NewCountPill(label: newCountLabel!),
                SizedBox(width: 6.w),
                const OrdersRowChevron(),
              ],
            ),
    );
  }
}

/// "2 new" on a day that dispatch just added to.
class NewCountPill extends StatelessWidget {
  const NewCountPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.iconBrand,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.brandMain, width: 1.2.w),
      ),
      child: Text(
        label,
        style: AppTextStyles.s14SemiBold.scaled
            .copyWith(color: AppColors.brandMain),
      ),
    );
  }
}
