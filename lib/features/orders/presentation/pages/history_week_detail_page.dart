// lib/features/orders/presentation/pages/history_week_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/order_history_entity.dart';
import '../widgets/history/history_breakdown_card.dart';
import '../widgets/history/history_metrics.dart';
import '../widgets/history/history_period_chart_card.dart';
import '../widgets/order_detail/order_detail_header.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import 'package:routex_mobile/features/main_layout/presentation/widgets/shell_nav_bar.dart';

/// The History summary opened up: the period bar by bar against the
/// driver's usual, and every figure with what it is made of.
///
/// Takes the [history] the History tab already loaded rather than fetching
/// again — it is the same period, and opening it should be instant.
///
/// Named for the week, its default, but worded for whichever period it is
/// given: "This week", "Today", "This month".
class HistoryWeekDetailPage extends StatelessWidget {
  const HistoryWeekDetailPage({super.key, required this.history});

  final OrderHistoryEntity history;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final period = history.period.name;
    final gutter = EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w);
    final fleet = history.fleetName;

    return Scaffold(
      bottomNavigationBar: const ShellNavBar(),
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OrderDetailBackButton(
              label: l10n.ordersSegmentHistory,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 6.h,
                  bottom: HistoryMetrics.bottomPadding.h +
                      MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: gutter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.historyDetailTitle(period),
                            style: AppTextStyles.s28Bold.scaled.copyWith(
                              height: 1.15,
                              letterSpacing: -0.28.sp,
                              color: AppColors.brandBlack,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _versusUsual(l10n, history),
                            style: AppTextStyles.s14Regular.scaled.copyWith(
                              height: 1.4,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Padding(
                      padding: gutter,
                      child: HistoryPeriodChartCard(
                        bars: history.bars,
                        usualPerBar: history.usualPerBar,
                        unitLabel: l10n.historyDeliveredUnitShort,
                        usualLabel: l10n.historyUsualPerBar(
                          period,
                          history.usualPerBar.toStringAsFixed(1),
                        ),
                      ),
                    ),
                    SizedBox(height: HistoryMetrics.cardGap.h),
                    Padding(
                      padding: gutter,
                      child: HistoryBreakdownCard(rows: _rows(l10n)),
                    ),
                    SizedBox(height: 18.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: Text(
                        fleet == null || fleet.isEmpty
                            ? l10n.historyPrivacy
                            : l10n.historyPrivacyFleet(fleet),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.s12Regular.scaled
                            .copyWith(height: 1.4, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<HistoryBreakdownRow> _rows(AppLocalizations l10n) {
    final kmPerDay = history.workedDays > 0
        ? (history.distanceKm / history.workedDays).round()
        : null;

    return [
      HistoryBreakdownRow(
        title: l10n.historyStatDelivered,
        value: l10n.historyPercent(history.deliveredPercent),
        detail: history.assignedCount > 0
            ? HistoryBreakdownNote(
                l10n.historyDeliveredOfAssigned(
                  history.deliveries,
                  history.assignedCount,
                ),
              )
            : null,
      ),
      HistoryBreakdownRow(
        title: l10n.historyStatOnTheRoad,
        value: _duration(l10n, history.minutesOnRoad),
        detail: HistoryTimeSplit(
          drivingMinutes: history.drivingMinutes,
          stopMinutes: history.stopMinutes,
          caption: [
            l10n.historyDriving(_duration(l10n, history.drivingMinutes)),
            l10n.historyAtStops(_duration(l10n, history.stopMinutes)),
          ].join(' · '),
        ),
      ),
      HistoryBreakdownRow(
        title: l10n.historyDistanceTitle,
        value: l10n.historyKm(history.distanceKm),
        detail: kmPerDay == null
            ? null
            : HistoryBreakdownNote(l10n.historyKmPerDay(kmPerDay)),
      ),
      if (history.failedCount > 0)
        HistoryBreakdownRow(
          title: l10n.historyCouldNotDeliverTitle,
          value: '${history.failedCount}',
          detail: history.failures.isEmpty
              ? null
              : HistoryReasonList(
                  reasons: [
                    for (final f in history.failures)
                      (_sentenceCase(_reason(l10n, f.reason)), f.count),
                  ],
                ),
        ),
    ];
  }
}

/// "You delivered 31 orders, 4 more than your usual week."
String _versusUsual(AppLocalizations l10n, OrderHistoryEntity history) {
  final period = history.period.name;
  final orders = l10n.ordersDayOrdersCount(history.deliveries);
  final diff = history.deliveries - history.usualTotal;
  if (diff > 0) return l10n.historyDetailMore(orders, diff, period);
  if (diff < 0) return l10n.historyDetailFewer(orders, -diff, period);
  return l10n.historyDetailSame(orders, period);
}

String _duration(AppLocalizations l10n, int totalMinutes) => l10n
    .historyDuration(
      totalMinutes ~/ 60,
      (totalMinutes % 60).toString().padLeft(2, '0'),
    );

String _reason(AppLocalizations l10n, DeliveryFailureReason reason) =>
    switch (reason) {
      DeliveryFailureReason.customerNotAnswering => l10n.historyReasonNoAnswer,
      DeliveryFailureReason.addressNotFound => l10n.historyReasonAddress,
      DeliveryFailureReason.refused => l10n.historyReasonRefused,
    };

/// The reasons are written mid-sentence ("Most common: customer not
/// answering"); as a list item they start with a capital. Arabic has no
/// case, so this leaves it untouched.
String _sentenceCase(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
