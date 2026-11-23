// lib/features/orders/presentation/widgets/search/search_result_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/order_search_result_entity.dart';
import '../../../domain/entities/orders_today_entity.dart';

import '../orders_today/orders_row_tile.dart';
import '../orders_today/orders_today_metrics.dart';

/// One search hit, drawn with the same badge the order wears on the Orders
/// list — route number for today, box for new, clock for a later day — so
/// the driver recognises it without reading the subtitle.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    required this.todayLabel,
    required this.newLabel,
    this.onTap,
  });

  final OrderSearchResultEntity result;

  /// Localized "Today" for the subtitle of a stop on today's route.
  final String todayLabel;

  /// Localized "New" for the pill on an order dispatch just added.
  final String newLabel;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final day = result.isToday ? todayLabel : result.dayLabel;

    return OrdersRowTile(
      onTap: onTap,
      leading: _leading(),
      title: '${result.customerName} · #${result.orderCode}',
      subtitle: '$day · ${result.areaLabel}',
      // A new order's pill stands in for the chevron, as "On the way" does
      // on the list: the row's most important fact goes where the eye ends.
      trailing: result.isNew ? NewOrderPill(label: newLabel) : null,
    );
  }

  Widget _leading() {
    final stop = result.todayStop;
    if (stop != null) {
      final isOnTheWay = stop.status == TodayStopStatus.onTheWay;
      return OrdersRowBadge(
        background: isOnTheWay ? AppColors.brandMain : AppColors.surfaceBadge,
        child: Text(
          '${stop.sequence}',
          style: AppTextStyles.s14Bold.scaled.copyWith(
            color: isOnTheWay ? AppColors.brandBlack : AppColors.textMuted,
          ),
        ),
      );
    }

    if (result.isNew) {
      return OrdersRowBadge(
        background: AppColors.surfaceInfoSoft,
        child: Assets.icons.svg.package.svg(
          width: 20.w,
          height: 20.w,
          colorFilter: ColorFilter.mode(
            AppColors.iconBlueAccent,
            BlendMode.srcIn,
          ),
        ),
      );
    }

    return OrdersRowBadge(
      child: Assets.icons.svg.history.svg(
        width: 20.w,
        height: 20.w,
        colorFilter: ColorFilter.mode(
          AppColors.textMuted,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

/// Marks an order dispatch added since the driver last reviewed — blue, the
/// same colour as the "new orders" banner it came from.
class NewOrderPill extends StatelessWidget {
  const NewOrderPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceInfoSoft,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.s14SemiBold.scaled
            .copyWith(color: AppColors.iconBlueAccent),
      ),
    );
  }
}
