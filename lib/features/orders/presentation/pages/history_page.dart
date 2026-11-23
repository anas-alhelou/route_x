// lib/features/orders/presentation/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

import '../../domain/entities/order_history_entity.dart';
import '../controllers/order_history_cubit.dart';
import '../controllers/order_history_state.dart';
import '../widgets/history/history_format.dart';
import '../widgets/history/history_metrics.dart';
import '../widgets/history/history_period_chips.dart';
import '../widgets/history/history_rows.dart';
import '../widgets/history/history_skeleton.dart';
import '../widgets/history/history_summary_card.dart';
import '../widgets/orders_empty_state.dart';
import '../widgets/orders_today/offline_notice.dart';
import '../widgets/orders_today/orders_card.dart';
import '../widgets/orders_today/orders_section_label.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import 'history_day_page.dart';
import 'history_first_week_empty_page.dart';
import 'history_this_month_page.dart';
import 'history_waiting_to_sync_page.dart';
import 'history_week_detail_page.dart';

/// The History tab's body: what the driver has done over a period, under
/// the same header and segmented control as Orders.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderHistoryCubit(
        getOrderHistoryUseCase: getIt(),
        networkInfo: getIt(),
      )..load(),
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Outside the scroll view: switching period should never need
            // a scroll back up.
            HistoryPeriodChips(
              period: state.period,
              labels: {
                HistoryPeriod.today: l10n.historyPeriodToday,
                HistoryPeriod.week: l10n.historyPeriodWeek,
                HistoryPeriod.month: l10n.historyPeriodMonth,
              },
              onChanged: context.read<OrderHistoryCubit>().selectPeriod,
            ),
            // Owns the gap under the chips: the plain 18 when live, the
            // "Showing saved history" line when not.
            OfflineNotice(
              visible:
                  state.status == OrderHistoryStatus.loaded && state.isOffline,
              label: state.updatedAt == null
                  ? ''
                  : l10n.historyOfflineNotice(
                      historyClockTime(state.updatedAt!),
                    ),
              top: HistoryMetrics.chipsToOfflineNotice,
              bottom: HistoryMetrics.offlineNoticeToSummary,
              hiddenHeight: HistoryMetrics.chipsToSummary,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom:
                      HistoryMetrics.bottomPadding.h +
                      MediaQuery.paddingOf(context).bottom,
                ),
                child: switch (state.status) {
                  OrderHistoryStatus.loading => const HistorySkeleton(),
                  OrderHistoryStatus.failed => const _LoadFailed(),
                  OrderHistoryStatus.loaded when state.data!.hasNoDeliveries =>
                    HistoryFirstWeekEmptyPage(data: state.data!),
                  OrderHistoryStatus.loaded
                      when state.period == HistoryPeriod.month =>
                    HistoryThisMonthPage(
                      data: state.data!,
                      pendingSyncCount: state.pendingSyncCount,
                      onOpenPending: () => _openPending(context),
                      onOpenCurrentWeek: () => context
                          .read<OrderHistoryCubit>()
                          .selectPeriod(HistoryPeriod.week),
                      retrying: state.refreshing,
                      onRetry: context.read<OrderHistoryCubit>().refresh,
                    ),
                  OrderHistoryStatus.loaded => _Loaded(
                    data: state.data!,
                    pendingSyncCount: state.pendingSyncCount,
                    retrying: state.refreshing,
                    onRetry: context.read<OrderHistoryCubit>().refresh,
                  ),
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Opens the updates waiting to sync. If they all went up from there, the
/// numbers here are stale: refresh in place.
Future<void> _openPending(BuildContext context) async {
  final cubit = context.read<OrderHistoryCubit>();
  final synced = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const HistoryWaitingToSyncPage()),
  );
  if (synced ?? false) cubit.refresh();
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.data,
    required this.onRetry,
    this.pendingSyncCount = 0,
    this.retrying = false,
  });

  final OrderHistoryEntity data;

  /// Stop updates on this phone not uploaded yet; counted in [data].
  final int pendingSyncCount;

  /// Fetches the period again — Retry on a summary that did not load.
  final VoidCallback onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final period = data.period.name;
    final gutter = EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w);
    final failure = data.mostCommonFailure;

    // Both cards open the same detail: the failures are one of its rows,
    // and splitting them into a screen of their own would hide the context
    // — 2 failed out of how many — that makes them readable.
    void openDetail() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryWeekDetailPage(history: data),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: gutter,
          child: data.hasSummary
              ? _summary(l10n, period, openDetail)
              : HistorySummaryErrorCard(
                  title: l10n.historySummaryFailedTitle(period),
                  message: l10n.historySummaryFailedBody(period),
                  retryLabel: l10n.historyRetry,
                  onRetry: onRetry,
                  retrying: retrying,
                ),
        ),
        if (pendingSyncCount > 0) ...[
          SizedBox(height: HistoryMetrics.cardGap.h),
          Padding(
            padding: gutter,
            child: HistorySyncCard(
              title: l10n.historyWaitingToSync(pendingSyncCount),
              subtitle: l10n.historyWaitingToSyncBody(pendingSyncCount),
              onTap: () => _openPending(context),
            ),
          ),
        ],
        if (data.failedCount > 0) ...[
          SizedBox(height: HistoryMetrics.cardGap.h),
          Padding(
            padding: gutter,
            child: HistoryFailuresCard(
              title: l10n.historyCouldNotDeliver(data.failedCount),
              subtitle: failure == null
                  ? null
                  : l10n.historyMostCommon(historyReason(l10n, failure)),
              // The detail is the summary opened up; without one there is
              // nothing behind the row yet.
              onTap: data.hasSummary ? openDetail : null,
            ),
          ),
        ],
        if (data.days.isNotEmpty) ...[
          SizedBox(height: HistoryMetrics.cardToDaysLabel.h),
          OrdersSectionLabel(label: l10n.historySectionDays),
          SizedBox(height: HistoryMetrics.labelToList.h),
          Padding(
            padding: gutter,
            child: OrdersCard(
              children: [
                for (final day in data.days)
                  HistoryDayTile(
                    day: day,
                    subtitle: _daySubtitle(l10n, day),
                    inReviewLabel: day.inReviewCount > 0
                        ? l10n.historyInReview(day.inReviewCount)
                        : null,
                    // The whole row, its "1 in review" pill included, opens
                    // the day; a day off is made inert by the tile itself.
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HistoryDayPage(day: day),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _summary(
    AppLocalizations l10n,
    String period,
    VoidCallback openDetail,
  ) {
    return HistorySummaryCard(
      heading: l10n.historyHeading(period),
      rangeLabel: data.rangeLabel,
      figure: data.deliveries,
      unit: l10n.historyDeliveriesUnit(data.deliveries),
      sentence: switch (data.comparison) {
        HistoryComparison.busier => l10n.historyBusier(period),
        HistoryComparison.usual => l10n.historyUsual(period),
        HistoryComparison.quieter => l10n.historyQuieter(period),
      },
      bars: data.bars,
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
      onTap: openDetail,
    );
  }
}

String _daySubtitle(AppLocalizations l10n, HistoryDayEntity day) {
  const dot = ' · ';
  return switch (day.kind) {
    HistoryDayKind.dayOff => l10n.historyDayOff,
    HistoryDayKind.inProgress => [
      l10n.historyDeliveredSoFar(day.delivered),
      l10n.historyKm(day.distanceKm),
    ].join(dot),
    HistoryDayKind.worked => [
      l10n.historyDeliveredOfTotal(day.delivered, day.total),
      historyDuration(l10n, day.minutesOnRoad),
      l10n.historyKm(day.distanceKm),
    ].join(dot),
  };
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed();

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return Padding(
      padding: EdgeInsets.only(top: OrdersTodayMetrics.emptyTop.h),
      child: OrdersEmptyState(
        tone: OrdersEmptyStateTone.error,
        icon: Assets.icons.svg.offline.svg(
          width: 32.w,
          height: 32.w,
          colorFilter: const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
        ),
        title: l10n.ordersLoadFailedTitle,
        message: l10n.ordersLoadFailedMessage,
        actionLabel: l10n.ordersTryAgain,
        onAction: context.read<OrderHistoryCubit>().load,
      ),
    );
  }
}
