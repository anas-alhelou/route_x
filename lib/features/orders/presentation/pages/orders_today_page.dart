// lib/features/orders/presentation/pages/orders_today_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/orders_today_entity.dart';
import '../../domain/entities/orders_today_snapshot.dart';
import '../controllers/orders_today_cubit.dart';
import '../controllers/orders_today_state.dart';
import '../widgets/history/history_metrics.dart';
import '../widgets/orders_empty_state.dart';
import '../widgets/orders_today/cancellation_notice_banner.dart';
import '../widgets/orders_today/connection_lost_banner.dart';
import '../widgets/orders_today/delivered_today_tile.dart';
import '../widgets/orders_today/new_orders_banner.dart';
import '../widgets/orders_today/offline_notice.dart';
import '../widgets/orders_today/orders_arrival_toast.dart';
import '../widgets/orders_today/orders_card.dart';
import '../widgets/orders_today/orders_section_label.dart';
import '../widgets/orders_today/orders_segmented_control.dart';
import '../widgets/orders_today/orders_today_header.dart';
import '../widgets/orders_today/orders_today_metrics.dart';
import '../widgets/orders_today/orders_today_skeleton.dart';
import '../widgets/orders_today/today_stop_tile.dart';
import '../widgets/orders_today/upcoming_day_tile.dart';
import '../../domain/entities/order_offer_entity.dart';
import '../controllers/order_offers_cubit.dart';
import '../widgets/offers/offers_tab_widgets.dart';
import 'offer_one_order_page.dart';
import 'history_page.dart';
import 'order_detail_page.dart';
import 'search_page.dart';

/// A driver's day, in reading order: what dispatch changed, what is left
/// today, and what is coming.
class OrdersTodayPage extends StatelessWidget {
  const OrdersTodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OrdersTodayCubit(
            getOrdersTodayUseCase: getIt(),
            networkInfo: getIt(),
          )..load(),
        ),
        BlocProvider(
          create: (_) => OrderOffersCubit(
            getPendingOffersUseCase: getIt(),
            undoDeclineOfferUseCase: getIt(),
          )..load(),
        ),
      ],
      child: const OrdersTodayView(),
    );
  }
}

class OrdersTodayView extends StatelessWidget {
  const OrdersTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<OrdersTodayCubit, OrdersTodayState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header and segmented control stay put across every state:
                // they are already actionable while the plan loads.
                OrdersTodayHeader(
                  title: l10n.ordersTitle,
                  searchLabel: l10n.ordersSearchLabel,
                  compactSearch: state is! OrdersTodayLoaded &&
                      state is! OrdersTodayError,
                  onSearchPressed: () async {
                    final cubit = context.read<OrdersTodayCubit>();
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SearchPage(),
                      ),
                    );
                    // O06/O07 Cancel -> O01, whichever tab Search came from.
                    cubit.changeSegment(OrdersTodaySegment.orders);
                  },
                ),
                SizedBox(height: OrdersTodayMetrics.titleToSegmented.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: OrdersTodayMetrics.gutter.w,
                  ),
                  child: OrdersSegmentedControl(
                    segment: state.segment,
                    ordersLabel: l10n.ordersSegmentOrders,
                    historyLabel: l10n.ordersSegmentHistory,
                    onChanged: context.read<OrdersTodayCubit>().changeSegment,
                  ),
                ),
                if (state.segment == OrdersTodaySegment.history)
                  // History brings its own period chips, set closer in.
                  SizedBox(height: HistoryMetrics.segmentedToChips.h)
                else
                  // Weak signal only. With no connection at all, the card in
                  // the banner slot says it louder, and both would be noise.
                  OfflineNotice(
                    visible: state is OrdersTodayLoaded &&
                        state.offline == OfflineReason.weakSignal,
                    label: state is OrdersTodayLoaded
                        ? l10n.ordersOfflineNotice(
                            _clockTime(state.updatedAt),
                          )
                        : '',
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: _Body(state: state)),
                      // Floats over the list rather than pushing it, so the
                      // driver's thumb does not land on a row that moved.
                      Positioned(
                        left: OrdersTodayMetrics.gutter.w,
                        right: OrdersTodayMetrics.gutter.w,
                        bottom: OrdersTodayMetrics.arrivalToastBottom.h,
                        child: Center(
                          child: _ArrivalToast(state: state),
                        ),
                      ),
                      Positioned(
                        left: OrdersTodayMetrics.gutter.w,
                        right: OrdersTodayMetrics.gutter.w,
                        bottom: OrdersTodayMetrics.arrivalToastBottom.h,
                        child: const _DeclinedToast(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// `9:42`, `12:05` — the same unpadded 24-hour form the delivery windows
/// use, so "Updated 9:42" reads against "10:00 — 12:00" without converting.
String _clockTime(DateTime time) =>
    '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final OrdersTodayState state;

  @override
  Widget build(BuildContext context) {
    final current = state;

    if (current.segment == OrdersTodaySegment.history) {
      return const HistoryPage();
    }

    // Nothing loaded and nothing saved — typically opening the app with no
    // signal. Unlike a lost connection mid-route, there is no list to fall
    // back on, so the whole body becomes the way out.
    if (current is OrdersTodayError) {
      return const _LoadFailed();
    }

    final isLoaded = current is OrdersTodayLoaded;

    final scrollable = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: OrdersTodayMetrics.bottomPadding.h +
            MediaQuery.paddingOf(context).bottom,
      ),
      child: switch (current) {
        OrdersTodayLoaded(:final data) when data.isEmpty =>
          _NoOrders(fleetName: data.fleetName),
        OrdersTodayLoaded() => _LoadedContent(state: current),
        _ => const OrdersTodaySkeleton(),
      },
    );

    // Only the loaded screen can be pulled to refresh — pulling on the
    // skeleton would queue a second request behind the one in flight.
    if (!isLoaded) return scrollable;

    return RefreshIndicator(
      color: AppColors.brandBlack,
      backgroundColor: AppColors.surfaceWhite,
      onRefresh: context.read<OrdersTodayCubit>().refresh,
      child: scrollable,
    );
  }
}

class _ArrivalToast extends StatelessWidget {
  const _ArrivalToast({required this.state});

  final OrdersTodayState state;

  @override
  Widget build(BuildContext context) {
    final current = state;
    final arrival = current is OrdersTodayLoaded ? current.arrival : null;
    final l10n = context.tr;
    final dayName = arrival?.dayName;

    return OrdersArrivalToast(
      arrivalId: arrival?.id,
      label: arrival == null
          ? ''
          : dayName == null
              ? l10n.ordersArrived(arrival.count)
              : l10n.ordersArrivedOnDay(arrival.count, dayName),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed();

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: OrdersTodayMetrics.emptyTop.h,
        bottom: OrdersTodayMetrics.bottomPadding.h +
            MediaQuery.paddingOf(context).bottom,
      ),
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
        // load, not refresh: there is no list to keep, and the skeleton is
        // the visible proof that the tap did something.
        onAction: context.read<OrdersTodayCubit>().load,
      ),
    );
  }
}

/// A day with nothing assigned. Still pull-to-refresh: checking for new
/// orders is exactly what a driver looking at this screen will try.
class _NoOrders extends StatelessWidget {
  const _NoOrders({required this.fleetName});

  final String? fleetName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final fleet = fleetName;

    return Padding(
      padding: EdgeInsets.only(top: OrdersTodayMetrics.emptyTop.h),
      child: OrdersEmptyState(
        // Two-tone on purpose — the dark tape is part of the drawing, so no
        // colour filter flattens it.
        icon: Assets.icons.svg.package2.svg(width: 48.w, height: 48.w),
        title: l10n.ordersEmptyTitle,
        message: fleet == null || fleet.isEmpty
            ? l10n.ordersEmptyMessage
            : l10n.ordersEmptyMessageFleet(fleet),
        actionIcon: Assets.icons.svg.history.svg(
          width: 24.w,
          height: 24.w,
          colorFilter: ColorFilter.mode(
            AppColors.brandBlack,
            BlendMode.srcIn,
          ),
        ),
        actionLabel: l10n.ordersSeePastOrders,
        onAction: () => context
            .read<OrdersTodayCubit>()
            .changeSegment(OrdersTodaySegment.history),
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.state});

  final OrdersTodayLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    const gutter = OrdersTodayMetrics.gutter;
    final data = state.data;
    final notice = state.visibleNotice;
    final offers = context.watch<OrderOffersCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // One banner at a time. Lost connection first: it qualifies every
        // line below it, and Review could not load anyway. Then the
        // cancellation, which changes what the driver must do with a package
        // already in the van; new orders only change tomorrow.
        if (state.isDisconnected) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter.w),
            child: ConnectionLostBanner(
              title: l10n.ordersConnectionLostTitle,
              message: l10n.ordersConnectionLostMessage,
              retryLabel: l10n.ordersTryAgain,
              onRetry: context.read<OrdersTodayCubit>().refresh,
            ),
          ),
          SizedBox(height: OrdersTodayMetrics.bannerToTodayLabel.h),
        ] else if (notice != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter.w),
            child: CancellationNoticeBanner(
              title: l10n.ordersCancelledTitle(notice.customerName),
              body: l10n.ordersCancelledBody(
                notice.orderCode,
                notice.cancelledAt,
              ),
              okLabel: l10n.ordersCancelledOk,
              onOk: () => context
                  .read<OrdersTodayCubit>()
                  .acknowledgeNotice(notice.orderId),
            ),
          ),
          SizedBox(height: OrdersTodayMetrics.bannerToTodayLabel.h),
        ] else if (offers.offers.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter.w),
            child: OffersWaitingBanner(
              title: l10n.offersWaitingTitle(offers.waitingOrders),
              subtitleFor: l10n.offersWaitingBody,
              actionLabel: l10n.offersView,
              deadline: offers.firstDeadline,
              onExpired: context.read<OrderOffersCubit>().load,
              onView: () => openOrderOffer(context, offers.offers.first),
            ),
          ),
          SizedBox(height: OrdersTodayMetrics.bannerToTodayLabel.h),
        ] else if (data.newOrdersCount > 0) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter.w),
            child: NewOrdersBanner(
              title: l10n.ordersNewOrdersTitle(data.newOrdersCount),
              subtitle: l10n.ordersNewOrdersSubtitle,
              actionLabel: l10n.ordersReview,
              onReviewPressed: () {},
            ),
          ),
          SizedBox(height: OrdersTodayMetrics.bannerToTodayLabel.h),
        ],
        OrdersSectionLabel(
          label: l10n.ordersSectionToday,
          trailing: data.remainingCount > 0
              ? l10n.ordersTodaySummary(
                  data.remainingCount,
                  data.estimatedFinishTime,
                )
              : null,
        ),
        SizedBox(height: OrdersTodayMetrics.todayLabelToList.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter.w),
          child: _TodayCard(data: data),
        ),
        if (data.upcomingDays.isNotEmpty) ...[
          SizedBox(height: OrdersTodayMetrics.todayListToUpcomingLabel.h),
          OrdersSectionLabel(label: l10n.ordersSectionUpcoming),
          SizedBox(height: OrdersTodayMetrics.upcomingLabelToList.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter.w),
            child: OrdersCard(
              children: [
                for (final day in data.upcomingDays)
                  UpcomingDayTile(
                    day: day,
                    ordersCountLabel:
                        l10n.ordersDayOrdersCount(day.ordersCount),
                    newCountLabel: day.newOrdersCount > 0
                        ? l10n.ordersDayNewCount(day.newOrdersCount)
                        : null,
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.data});

  final OrdersTodayEntity data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    if (data.todayStops.isEmpty && data.deliveredTodayCount == 0) {
      return OrdersCard(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Text(
              l10n.ordersTodayEmpty,
              textAlign: TextAlign.center,
              style: AppTextStyles.s14Regular.scaled
                  .copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      );
    }

    return OrdersCard(
      children: [
        for (final stop in data.todayStops)
          TodayStopTile(
            stop: stop,
            onTheWayLabel: l10n.ordersOnTheWay,
            cancelledLabel: l10n.ordersStatusCancelled,
            returnToDepotLabel: l10n.ordersReturnToDepot,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => OrderDetailPage(stop: stop),
              ),
            ),
          ),
        // Last row of the same card: finished work is context for the work
        // that is left, not a section of its own.
        if (data.deliveredTodayCount > 0)
          DeliveredTodayTile(
            title: l10n.ordersDeliveredToday(data.deliveredTodayCount),
            subtitle: l10n.ordersSeeThemInHistory,
            onTap: () => context
                .read<OrdersTodayCubit>()
                .changeSegment(OrdersTodaySegment.history),
          ),
      ],
    );
  }
}

/// Opens an offer, then brings the Orders tab up to date with the answer:
/// a decline shows the toast with Undo, an accept reloads the day, and an
/// offer that ran out or was taken back simply drops off.
Future<void> openOrderOffer(
  BuildContext context,
  OrderOfferEntity offer,
) async {
  final offers = context.read<OrderOffersCubit>();
  final today = context.read<OrdersTodayCubit>();
  final outcome = await Navigator.of(context).push<OrderOfferOutcome>(
    MaterialPageRoute(builder: (_) => OrderOfferPage(offer: offer)),
  );
  switch (outcome) {
    case OrderOfferOutcome.declined:
      offers.offerDeclined(offer);
    case OrderOfferOutcome.accepted:
      offers.offerAnswered(offer);
      today.refresh();
    case null:
      offers.load();
  }
}

class _DeclinedToast extends StatelessWidget {
  const _DeclinedToast();

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;

    return BlocBuilder<OrderOffersCubit, OrderOffersState>(
      builder: (context, state) {
        final declined = state.declined;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: declined == null
              ? const SizedBox.shrink()
              : OfferDeclinedToast(
                  key: ValueKey(state.declinedId),
                  title: l10n.offerDeclinedTitle(declined.orders.length),
                  message: l10n.offerDeclinedBody(
                    declined.orders.length,
                    declined.fleetName,
                  ),
                  undoLabel: l10n.offerUndo,
                  undoing: state.undoing,
                  onUndo: context.read<OrderOffersCubit>().undo,
                ),
        );
      },
    );
  }
}
