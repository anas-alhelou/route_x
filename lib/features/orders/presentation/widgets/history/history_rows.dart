// lib/features/orders/presentation/widgets/history/history_rows.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/order_history_entity.dart';

import '../orders_today/orders_card.dart';
import '../orders_today/orders_row_tile.dart';
import '../orders_today/orders_today_metrics.dart';

/// "2 couldn't deliver — most common: customer not answering". Its own card,
/// between the summary and the days, because failures are what a driver gets
/// asked about; they should not have to add them up from the day rows.
class HistoryFailuresCard extends StatelessWidget {
  const HistoryFailuresCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final String title;

  /// The most common reason; null when none stands out.
  final String? subtitle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OrdersCard(
      children: [
        OrdersRowTile(
          onTap: onTap,
          leading: const HistoryFailureBadge(),
          title: title,
          subtitle: subtitle ?? '',
          trailing: onTap == null ? const SizedBox.shrink() : null,
        ),
      ],
    );
  }
}

/// "2 updates waiting to sync — saved on this phone, they'll upload on
/// their own". Amber, not red: nothing is lost and nothing needs doing; the
/// card is there so a driver who sees the numbers lag the server's isn't
/// left wondering where their stops went.
class HistorySyncCard extends StatelessWidget {
  const HistorySyncCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OrdersCard(
      children: [
        OrdersRowTile(
          onTap: onTap,
          leading: OrdersRowBadge(
            background: AppColors.statusAmberSurface,
            borderColor: AppColors.statusAmber,
            child: Assets.icons.svg.sync.svg(width: 14.w, height: 14.w),
          ),
          title: title,
          subtitle: subtitle,
          trailing: onTap == null ? const SizedBox.shrink() : null,
        ),
      ],
    );
  }
}

/// A box with a cross, in the red well the app uses for things that went
/// wrong — the delivered icon's opposite.
class HistoryFailureBadge extends StatelessWidget {
  const HistoryFailureBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return OrdersRowBadge(
      background: AppColors.statusDangerSurface,
      borderColor: AppColors.iconRed,
      child: Assets.icons.svg.failed.svg(width: 22.w, height: 22.w),
    );
  }
}

/// One day of the period. Working days wear the route mark in brand green;
/// a day off is greyed and inert — listed so a gap reads as rest, not as
/// missing data.
class HistoryDayTile extends StatelessWidget {
  const HistoryDayTile({
    super.key,
    required this.day,
    required this.subtitle,
    this.inReviewLabel,
    this.onTap,
  });

  final HistoryDayEntity day;

  /// Already localized: "7 of 8 delivered · 4h 05m · 38 km", or "Day off".
  final String subtitle;

  /// Localized "1 in review"; null hides the pill.
  final String? inReviewLabel;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDayOff = day.kind == HistoryDayKind.dayOff;

    return OrdersRowTile(
      onTap: isDayOff ? null : onTap,
      muted: isDayOff,
      leading: isDayOff
          ? OrdersRowBadge(
              child: Assets.icons.svg.history.svg(width: 22.w, height: 22.w),
            )
          : OrdersRowBadge(
              background: AppColors.brandMain,
              child: Assets.icons.svg.route.svg(width: 20.w, height: 20.w),
            ),
      title: day.title,
      subtitle: subtitle,
      trailing: isDayOff
          // Nothing to open on a day off, so no chevron promising otherwise.
          ? const SizedBox.shrink()
          : inReviewLabel == null
              ? null
              : InReviewPill(label: inReviewLabel!),
    );
  }
}

/// Deliveries dispatch is still checking. Grey and quiet: nothing for the
/// driver to do, only something not to be surprised by later.
class InReviewPill extends StatelessWidget {
  const InReviewPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceBadge,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.svg.review.svg(width: 12.w, height: 12.w),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.s10Bold.scaled
                .copyWith(height: 1.4, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
