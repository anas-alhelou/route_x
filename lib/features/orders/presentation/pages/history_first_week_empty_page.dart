// lib/features/orders/presentation/pages/history_first_week_empty_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/order_history_entity.dart';
import '../widgets/history/history_metrics.dart';
import '../widgets/orders_today/orders_today_metrics.dart';

/// The History tab when the period has nothing in it yet — a new driver,
/// the first day of a week, a week without orders.
///
/// It keeps the tab's shape rather than blanking it: the summary card is
/// there, with its heading and dates, and flat bars where the week will
/// fill in. A driver opening History for the first time sees what the
/// screen *will* show, not an error.
///
/// Like [HistoryPage], this is the tab's body, under the header and the
/// period chips.
class HistoryFirstWeekEmptyPage extends StatelessWidget {
  const HistoryFirstWeekEmptyPage({super.key, required this.data});

  final OrderHistoryEntity data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final period = data.period.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w),
          child: _NotEnoughDataCard(
            heading: l10n.historyHeading(period),
            rangeLabel: data.rangeLabel,
            title: l10n.historyNotEnoughData,
            message: l10n.historyNotEnoughDataBody(period),
            slots: data.bars.length,
          ),
        ),
        SizedBox(height: 40.h),
        _NoDaysYet(
          title: l10n.historyEmptyDaysTitle,
          message: l10n.historyEmptyDaysBody,
        ),
      ],
    );
  }
}

class _NotEnoughDataCard extends StatelessWidget {
  const _NotEnoughDataCard({
    required this.heading,
    required this.rangeLabel,
    required this.title,
    required this.message,
    required this.slots,
  });

  final String heading;
  final String rangeLabel;
  final String title;
  final String message;

  /// How many flat bars to draw — one per day of the week, week of the
  /// month — so the card is the same chart, just not filled in yet.
  final int slots;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(HistoryMetrics.cardPadding.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(HistoryMetrics.summaryRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  heading,
                  style: AppTextStyles.s10Bold.scaled.copyWith(
                    height: 1.4,
                    color: AppColors.textMuted,
                    letterSpacing: 0.2.sp,
                  ),
                ),
              ),
              Text(
                rangeLabel,
                style: AppTextStyles.s12Medium.scaled
                    .copyWith(height: 1.4, color: AppColors.textMuted),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: AppTextStyles.s24Bold.scaled.copyWith(
              fontSize: 22.sp,
              height: 1.4,
              letterSpacing: -0.22.sp,
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: AppTextStyles.s14Regular.scaled
                .copyWith(height: 1.4, color: AppColors.textMuted),
          ),
          SizedBox(height: HistoryMetrics.sentenceToChart.h),
          // The chart's own footprint, empty: the card keeps the height it
          // will have once there is something to draw.
          SizedBox(
            height: HistoryMetrics.chartHeight.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < slots; i++)
                  Container(
                    width: HistoryMetrics.barWidth.w,
                    height: HistoryMetrics.barMinHeight.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBadge,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Where the day rows will be. No button: there is nothing to do yet but
/// drive.
class _NoDaysYet extends StatelessWidget {
  const _NoDaysYet({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final well = 56.w;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 56.w),
      child: Column(
        children: [
          Container(
            width: well,
            height: well,
            decoration: BoxDecoration(
              color: AppColors.surfaceCanvas,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Assets.icons.svg.history28.svg(width: 28.w, height: 28.w),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.s16Bold.scaled.copyWith(
              height: 1.4,
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.s14Regular.scaled
                .copyWith(height: 1.4, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
