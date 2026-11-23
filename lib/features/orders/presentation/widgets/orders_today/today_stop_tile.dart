// lib/features/orders/presentation/widgets/orders_today/today_stop_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/orders_today_entity.dart';

import 'orders_row_tile.dart';
import 'orders_today_metrics.dart';

/// One undelivered stop on today's route.
///
/// The stop the driver is currently driving to is the only green badge and
/// the only row with a pill instead of a chevron — two signals for the same
/// fact, so it survives sunlight, a dirty screen and a glance.
class TodayStopTile extends StatelessWidget {
  const TodayStopTile({
    super.key,
    required this.stop,
    required this.onTheWayLabel,
    required this.cancelledLabel,
    required this.returnToDepotLabel,
    this.onTap,
  });

  final TodayStopEntity stop;

  /// Localized copy for the active stop's pill. Passed in rather than read
  /// from context here so the tile stays a pure presentation widget.
  final String onTheWayLabel;

  /// Localized copy for a cancelled stop's pill and its subtitle.
  final String cancelledLabel;
  final String returnToDepotLabel;

  /// Ignored for a cancelled stop: there is nothing left to open.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = stop.status;
    final isCancelled = status == TodayStopStatus.cancelled;

    return OrdersRowTile(
      onTap: isCancelled ? null : onTap,
      muted: isCancelled,
      leading: OrdersRowBadge(
        background: switch (status) {
          TodayStopStatus.onTheWay => AppColors.brandMain,
          TodayStopStatus.upNext => AppColors.surfaceBadge,
          TodayStopStatus.cancelled => AppColors.surfaceAction,
        },
        child: Text(
          '${stop.sequence}',
          style: AppTextStyles.s14Bold.scaled.copyWith(
            fontSize: 13.sp,
            height: 1.4,
            color: switch (status) {
              TodayStopStatus.onTheWay => AppColors.brandBlack,
              TodayStopStatus.upNext => AppColors.brandBlack,
              TodayStopStatus.cancelled => AppColors.iconHint,
            },
          ),
        ),
      ),
      title: stop.customerName,
      // The time window no longer applies; what the driver needs instead is
      // where the package goes now.
      subtitle: isCancelled
          ? '${stop.area} · $returnToDepotLabel'
          : '${stop.area} · ${stop.timeWindow}',
      trailing: switch (status) {
        TodayStopStatus.onTheWay => OnTheWayPill(label: onTheWayLabel),
        TodayStopStatus.cancelled => CancelledPill(label: cancelledLabel),
        TodayStopStatus.upNext => null,
      },
    );
  }
}

/// Replaces the chevron on a cancelled stop. Grey, not red: the cancellation
/// is already announced in the notice above, and the row only has to say
/// "not yours any more" without competing with it.
class CancelledPill extends StatelessWidget {
  const CancelledPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceAction,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block_rounded, size: 18.w, color: AppColors.textMuted),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.s14Medium.scaled
                .copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Marks the one stop the driver is currently driving to.
class OnTheWayPill extends StatelessWidget {
  const OnTheWayPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.iconBrand,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.brandMain, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.svg.navigateBrand.svg(width: 16.w, height: 16.w),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.s11Bold.scaled
                .copyWith(height: 1.4, color: AppColors.brandMain),
          ),
        ],
      ),
    );
  }
}
