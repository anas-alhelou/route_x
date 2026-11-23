// lib/features/orders/presentation/pages/history_day_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/history_day_stops_entity.dart';
import '../../domain/entities/order_history_entity.dart';
import '../controllers/history_day_cubit.dart';
import '../controllers/history_day_state.dart';
import '../widgets/history/history_metrics.dart';
import '../widgets/history/history_stop_tile.dart';
import '../widgets/history/history_summary_card.dart';
import '../widgets/order_detail/order_detail_header.dart';
import '../widgets/orders_empty_state.dart';
import '../widgets/orders_today/orders_card.dart';
import '../widgets/orders_today/orders_section_label.dart';
import '../widgets/orders_today/orders_skeleton_box.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import 'history_stop_record_delivered_page.dart';
import 'history_stop_record_page.dart';
import 'package:routex_mobile/features/main_layout/presentation/widgets/shell_nav_bar.dart';

/// One past day, stop by stop.
///
/// The title and the three figures come with [day] from the History tab, so
/// they paint at once; only the stops are fetched, and only their list
/// waits on a skeleton.
class HistoryDayPage extends StatelessWidget {
  const HistoryDayPage({super.key, required this.day});

  final HistoryDayEntity day;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryDayCubit(
        getHistoryDayStopsUseCase: getIt(),
        dayId: day.id,
      )..load(),
      child: HistoryDayView(day: day),
    );
  }
}

class HistoryDayView extends StatelessWidget {
  const HistoryDayView({super.key, required this.day});

  final HistoryDayEntity day;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final gutter = EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w);

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
              child: BlocBuilder<HistoryDayCubit, HistoryDayState>(
                builder: (context, state) {
                  final data = state.data;
                  return SingleChildScrollView(
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
                          child: Text(
                            day.heading,
                            style: AppTextStyles.s28Bold.scaled.copyWith(
                              height: 1.15,
                              letterSpacing: -0.28.sp,
                              color: AppColors.brandBlack,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Padding(
                          padding: gutter,
                          child: HistoryStatsRow(stats: _stats(l10n)),
                        ),
                        SizedBox(height: 20.h),
                        OrdersSectionLabel(
                          label: l10n.historySectionStops,
                          trailing: data == null ||
                                  data.shiftStart.isEmpty ||
                                  data.shiftEnd.isEmpty
                              ? null
                              : '${data.shiftStart} — ${data.shiftEnd}',
                        ),
                        SizedBox(height: HistoryMetrics.labelToList.h),
                        switch (state.status) {
                          HistoryDayStatus.loading => const _StopsSkeleton(),
                          HistoryDayStatus.failed => const _LoadFailed(),
                          HistoryDayStatus.loaded => Padding(
                              padding: gutter,
                              child: _StopsList(day: day, stops: data!.stops),
                            ),
                        },
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<HistoryStat> _stats(AppLocalizations l10n) {
    return [
      HistoryStat(
        // A day still running has no total yet: just the count so far.
        value: day.total > 0
            ? l10n.historyOfTotal(day.delivered, day.total)
            : '${day.delivered}',
        label: l10n.historyStatDelivered,
      ),
      if (day.minutesOnRoad > 0)
        HistoryStat(
          value: l10n.historyDuration(
            day.minutesOnRoad ~/ 60,
            (day.minutesOnRoad % 60).toString().padLeft(2, '0'),
          ),
          label: l10n.historyStatOnTheRoad,
        ),
      HistoryStat(
        value: l10n.historyKm(day.distanceKm),
        label: l10n.historyStatDriven,
      ),
    ];
  }
}

class _StopsList extends StatelessWidget {
  const _StopsList({required this.day, required this.stops});

  final HistoryDayEntity day;

  final List<HistoryStopEntity> stops;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return OrdersCard(
      children: [
        for (final stop in stops)
          HistoryStopTile(
            stop: stop,
            subtitle: [
              '#${stop.orderCode}',
              stop.time,
              if (stop.failureReason != null)
                _sentenceCase(_reason(l10n, stop.failureReason!)),
            ].join(' · '),
            inReviewLabel: l10n.historyStopInReview,
            // Every stop opens its record: delivered ones with their proof,
            // failed ones — like the one under review — with what went
            // wrong.
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => stop.outcome == HistoryStopOutcome.delivered
                    ? HistoryStopRecordDeliveredPage(
                        stop: stop,
                        dayLabel: day.dateLabel,
                        totalStops: stops.length,
                      )
                    : HistoryStopRecordPage(
                        stop: stop,
                        dayLabel: day.dateLabel,
                        totalStops: stops.length,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

String _reason(AppLocalizations l10n, DeliveryFailureReason reason) =>
    switch (reason) {
      DeliveryFailureReason.customerNotAnswering => l10n.historyReasonNoAnswer,
      DeliveryFailureReason.addressNotFound => l10n.historyReasonAddress,
      DeliveryFailureReason.refused => l10n.historyReasonRefused,
    };

/// The reasons are stored mid-sentence; after a bullet they start a clause
/// of their own. Arabic has no case, so this leaves it untouched.
String _sentenceCase(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

class _StopsSkeleton extends StatelessWidget {
  const _StopsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: HistoryMetrics.gutter.w),
      child: OrdersSkeletonPulse(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(HistoryMetrics.cardRadius.r),
            border:
                Border.all(color: AppColors.borderDeactivated, width: 1.w),
          ),
          child: Column(
            children: [
              for (var i = 0; i < 4; i++)
                SizedBox(
                  height: 60.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        OrdersSkeletonBox.circle(
                          size: OrdersTodayMetrics.leadingBadgeSize.w,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OrdersSkeletonBox(
                              width: 150.w,
                              height: 10.h,
                              radius: 5,
                            ),
                            SizedBox(height: 8.h),
                            OrdersSkeletonBox(
                              width: 110.w,
                              height: 10.h,
                              radius: 5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed();

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: OrdersEmptyState(
        tone: OrdersEmptyStateTone.error,
        icon: Assets.icons.svg.offline.svg(
          width: 32.w,
          height: 32.w,
          colorFilter: const ColorFilter.mode(
            AppColors.error,
            BlendMode.srcIn,
          ),
        ),
        title: l10n.ordersLoadFailedTitle,
        message: l10n.ordersLoadFailedMessage,
        actionLabel: l10n.ordersTryAgain,
        onAction: context.read<HistoryDayCubit>().load,
      ),
    );
  }
}
