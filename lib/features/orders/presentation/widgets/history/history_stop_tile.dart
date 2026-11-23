// lib/features/orders/presentation/widgets/history/history_stop_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/history_day_stops_entity.dart';

import '../orders_today/orders_row_tile.dart';
import '../orders_today/orders_today_metrics.dart';
import 'history_rows.dart';

/// One stop of a past day. Delivered stops wear their route number in brand
/// green; a stop that failed keeps its number in grey, so the gap in the
/// green column is where the eye lands when scanning the day.
class HistoryStopTile extends StatelessWidget {
  const HistoryStopTile({
    super.key,
    required this.stop,
    required this.subtitle,
    this.inReviewLabel,
    this.onTap,
  });

  final HistoryStopEntity stop;

  /// Already localized: "#RX-1015 · 09:52 · Customer not answering".
  final String subtitle;

  /// Localized "In review"; shown in place of the chevron when the stop is
  /// still being checked.
  final String? inReviewLabel;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final delivered = stop.outcome == HistoryStopOutcome.delivered;

    return OrdersRowTile(
      onTap: onTap,
      leading: OrdersRowBadge(
        background: delivered ? AppColors.brandMain : AppColors.surfaceBadge,
        child: Text(
          '${stop.sequence}',
          style: AppTextStyles.s14Bold.scaled.copyWith(
            fontSize: 13.sp,
            height: 1.4,
            color: delivered ? AppColors.brandBlack : AppColors.textMuted,
          ),
        ),
      ),
      title: stop.addressLine,
      subtitle: subtitle,
      trailing: stop.inReview && inReviewLabel != null
          ? InReviewPill(label: inReviewLabel!)
          : null,
    );
  }
}
