// lib/features/orders/presentation/pages/history_this_month_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';

import '../../domain/entities/order_history_entity.dart';
import '../widgets/history/history_format.dart';
import '../widgets/history/history_metrics.dart';
import '../widgets/history/history_month_widgets.dart';
import '../widgets/history/history_rows.dart';
import '../widgets/history/history_summary_card.dart';
import '../widgets/orders_today/orders_card.dart';
import '../widgets/orders_today/orders_section_label.dart';

/// The History tab on Month: the month so far as a bar a day, one thing
/// worth knowing about it, and its weeks.
///
/// Where Week lists days, Month lists weeks — thirty rows would be a log,
/// not a summary. Failures aren't a card of their own here either: over a
/// month the count matters less than whether it is drifting from the
/// driver's norm, which is what "Worth a look" says, and only when it is.
///
/// Like [HistoryFirstWeekEmptyPage], this is the tab's body, under the
/// header and the period chips.
class HistoryThisMonthPage extends StatelessWidget {
  const HistoryThisMonthPage({
    super.key,
    required this.data,
    this.pendingSyncCount = 0,
    this.onOpenPending,
    this.onOpenCurrentWeek,
    this.onRetry,
    this.retrying = false,
  });

  final OrderHistoryEntity data;

  /// Stop updates on this phone not uploaded yet; counted in [data].
  final int pendingSyncCount;

  /// Opens where the waiting updates came from. Null leaves the card
  /// inert.
  final VoidCallback? onOpenPending;

  /// Opens the week under way — the Week tab already shows it.
  final VoidCallback? onOpenCurrentWeek;

  /// Fetches the month again — Retry on a summary that did not load.
  final VoidCallback? onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final gutter = EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w);
    final insight = _insight(l10n, data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: gutter,
          child: !data.hasSummary
              ? HistorySummaryErrorCard(
                  title: l10n.historySummaryFailedTitle(data.period.name),
                  message: l10n.historySummaryFailedBody(data.period.name),
                  retryLabel: l10n.historyRetry,
                  onRetry: onRetry ?? () {},
                  retrying: retrying,
                )
              : HistorySummaryCard(
                  heading: l10n.historyHeading(data.period.name),
                  rangeLabel: data.rangeLabel,
                  figure: data.deliveries,
                  unit: l10n.historyDeliveriesUnit(data.deliveries),
                  sentence: l10n.historyMonthComparison(data.comparison.name),
                  bars: data.bars,
                  chart: HistoryMonthChart(bars: data.bars),
                  note: pendingSyncCount > 0
                      ? l10n.historyIncludesUnsynced(pendingSyncCount)
                      : null,
                  stats: [
                    HistoryStat(
                      value: l10n.historyPercent(data.deliveredPercent),
                      label: l10n.historyStatDelivered,
                    ),
                    HistoryStat(
                      value: l10n.historyKm(data.distanceKm),
                      label: l10n.historyStatDriven,
                    ),
                    HistoryStat(
                      value: historyDuration(l10n, data.minutesOnRoad),
                      label: l10n.historyStatOnTheRoad,
                    ),
                  ],
                ),
        ),
        if (pendingSyncCount > 0) ...[
          SizedBox(height: HistoryMetrics.cardGap.h),
          Padding(
            padding: gutter,
            child: HistorySyncCard(
              title: l10n.historyWaitingToSync(pendingSyncCount),
              subtitle: l10n.historyWaitingToSyncBody(pendingSyncCount),
              onTap: onOpenPending,
            ),
          ),
        ],
        if (insight != null) ...[
          SizedBox(height: HistoryMetrics.cardGap.h),
          Padding(
            padding: gutter,
            child: HistoryInsightCard(
              title: l10n.historyWorthALook,
              message: insight,
            ),
          ),
        ],
        if (data.weeks.isNotEmpty) ...[
          SizedBox(height: HistoryMetrics.insightToWeeksLabel.h),
          OrdersSectionLabel(label: l10n.historySectionWeeks),
          SizedBox(height: HistoryMetrics.labelToList.h),
          Padding(
            padding: gutter,
            child: OrdersCard(
              children: [
                for (final week in data.weeks)
                  HistoryWeekTile(
                    title: week.isCurrent
                        ? l10n.historyThisWeekRange(week.rangeLabel)
                        : week.rangeLabel,
                    subtitle: [
                      l10n.historyCountDelivered(week.delivered),
                      if (week.failed > 0)
                        l10n.historyCouldNotDeliver(week.failed),
                    ].join(' · '),
                    // A past week has no screen yet; it opens once the
                    // API can serve one week by its id.
                    onTap: week.isCurrent ? onOpenCurrentWeek : null,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// "Delivered is at 92%, a little under your usual 96%. Most misses this
/// month: customer not answering (3). Calling before you arrive can help."
/// Null when the month is on or above the driver's norm.
String? _insight(AppLocalizations l10n, OrderHistoryEntity data) {
  final reason = data.mostCommonFailure;
  if (!data.deliveredBelowUsual || reason == null) return null;

  return [
    l10n.historyDeliveredBelowUsual(
      data.deliveredPercent,
      data.usualDeliveredPercent,
    ),
    l10n.historyMostMissesThisMonth(
      historyReason(l10n, reason),
      data.mostCommonFailureCount,
    ),
    l10n.historyMissTip(reason.name),
  ].where((s) => s.isNotEmpty).join(' ');
}
