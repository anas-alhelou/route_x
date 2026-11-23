// lib/features/home/presentation/pages/delivery_dashboard_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/features/home/presentation/bloc/delivery_dashboard_bloc.dart';
import 'package:routex_mobile/features/home/presentation/bloc/offer_alert_cubit.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/live_offer_banner.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';
import 'package:routex_mobile/features/orders/domain/usecases/order_offer_usecases.dart';
import 'package:routex_mobile/features/orders/presentation/pages/offer_one_order_page.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/delivery_header.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/home_skeleton_loader.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/in_app_notification_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/needs_attention_section.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/offline_banner.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/online_status_banner.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/today_section.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/up_next_section.dart';
import 'package:routex_mobile/features/main_layout/presentation/cubit/main_layout_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';

import 'package:routex_mobile/core/di/injection.dart';

/// Entry point for the delivery dashboard — mounts the BLoC and fires init.
///
/// Self-providing: wraps its content in a [BlocProvider] for
/// [DeliveryDashboardBloc] resolved via [getIt] according to Clean Architecture.
class DeliveryDashboardPage extends StatelessWidget {
  const DeliveryDashboardPage({this.initialScenario, super.key});

  final DeliveryScenario? initialScenario;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeliveryDashboardBloc>(
          create: (_) => getIt<DeliveryDashboardBloc>()
            ..add(
              DeliveryDashboardInitialized(initialScenario: initialScenario),
            ),
        ),
        // The offers waiting for an answer: the NF3 banner and HM8 card.
        BlocProvider<OfferAlertCubit>(
          create: (_) => OfferAlertCubit(
            getPendingOffers: getIt<GetPendingOffersUseCase>(),
          )..load(),
        ),
      ],
      child: const _DeliveryDashboardView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inner view — mounts content, floating bottom nav, and in-app overlay.
// ─────────────────────────────────────────────────────────────────────────────

class _DeliveryDashboardView extends StatefulWidget {
  const _DeliveryDashboardView();

  @override
  State<_DeliveryDashboardView> createState() => _DeliveryDashboardViewState();
}

class _DeliveryDashboardViewState extends State<_DeliveryDashboardView> {
  bool _showOverlayNotification = false;

  /// Switches the shell to the Route tab (index 1) and runs [action] on the
  /// route cubit. Outside the shell (the standalone home route used by the
  /// navigation hub) there is no tab bar or route cubit, so nothing happens.
  void _openRouteTab(void Function(RouteFleetCubit cubit) action) {
    RouteFleetCubit? routeCubit;
    MainLayoutCubit? layoutCubit;
    try {
      routeCubit = BlocProvider.of<RouteFleetCubit>(context, listen: false);
      layoutCubit = BlocProvider.of<MainLayoutCubit>(context, listen: false);
    } catch (_) {
      return; // Not inside the main shell.
    }
    action(routeCubit);
    layoutCubit.changeTab(1);
  }

  /// Switches the shell to another tab; outside the shell nothing happens.
  void _openTab(int index) {
    try {
      BlocProvider.of<MainLayoutCubit>(context, listen: false)
          .changeTab(index);
    } catch (_) {}
  }

  /// Figma HM1/HM2/HM8/HM9/NF3: opens the offer — OF1 for one order, OF2 for
  /// a group — and refreshes the banner once it is answered.
  Future<void> _openOffer(OrderOfferEntity? offer) async {
    if (offer == null) {
      _openTab(2);
      return;
    }
    context.read<OfferAlertCubit>().dismissOverlay();
    await pushOrderOffer(Navigator.of(context), offer);
  }

  /// "Needs your attention" rows (HM1 / HM2 / HM9).
  void _onAttentionTap(AttentionItem item) {
    switch (item.type) {
      case AttentionItemType.newOrders:
        _openOffer(context.read<OfferAlertCubit>().state.first);
      case AttentionItemType.cancelledOrder:
        _openTab(2); // O05 — the cancelled order lives on the Orders tab.
      case AttentionItemType.routeUpdate:
        _openTab(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryDashboardBloc, DeliveryDashboardState>(
      builder: (context, state) {
        final alert = context.watch<OfferAlertCubit>().state;
        return Scaffold(
          backgroundColor: AppColors.brandBackground,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              SizedBox(height: 45.h),
              // ── Main Body (scrollable content or skeleton) ─────────────────
              SafeArea(bottom: false, child: _buildBody(context, state)),

              // The bottom navigation bar belongs to the main shell
              // (MainLayoutScreen); Home must not draw a second one.

              // ── In-app notification overlay (HM8 & HM9, 380 x 70 at top 50) ─
              // Several orders waiting: the NF3 banner, View -> OF2.
              if (alert.hasOffers && !alert.isSingle)
                PositionedDirectional(
                  start: 16.w,
                  end: 16.w,
                  top: 50.h,
                  child: LiveOfferBanner(
                    orderCount: alert.orderCount,
                    fleetName: alert.first!.fleetName,
                    deadline: alert.firstDeadline,
                    onView: () => _openOffer(alert.first),
                    onExpired: context.read<OfferAlertCubit>().load,
                  ),
                )
              // One order just arrived: the in-app card, Review -> OF1.
              else if (alert.hasOffers && alert.overlayVisible)
                PositionedDirectional(
                  start: 16.w,
                  end: 16.w,
                  top: 50.h,
                  child: InAppNotificationCard(
                    title: context.tr.homeInAppNewOrderOffered,
                    timeAgo: context.tr.homeInAppNow,
                    subtitle:
                        '${alert.first!.orders.first.customerName}, '
                        '${alert.first!.orders.first.area} · '
                        '${context.tr.offerKm(alert.first!.orders.first.addedKm.toStringAsFixed(1))}',
                    onReviewTap: () => _openOffer(alert.first),
                    onDismiss: context.read<OfferAlertCubit>().dismissOverlay,
                  ),
                )
              // Design scenarios from the dashboard data (no real offer).
              else if (_showOverlayNotification)
                PositionedDirectional(
                  start: 16.w,
                  end: 16.w,
                  top: 50.h,
                  child: InAppNotificationCard(
                    title: context.tr.homeInAppNewOrderOffered,
                    timeAgo: context.tr.homeInAppNow,
                    subtitle: 'Ahmed Ali, Al Rawdah · 2.4 km',
                    onReviewTap: () {
                      setState(() => _showOverlayNotification = false);
                    },
                    onDismiss: () {
                      setState(() => _showOverlayNotification = false);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DeliveryDashboardState state) {
    // Skeleton, failure and content cross-fade instead of snapping, so the
    // screen settles in rather than popping. Reduced motion turns it off.
    final kind = state.status == DeliveryDashboardStatus.failure
        ? 'failure'
        : (state.status == DeliveryDashboardStatus.loading ||
                  state.dashboard == null)
            ? 'loading'
            : 'content';
    return AnimatedSwitcher(
      duration: motionReduced(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(
        key: ValueKey<String>(kind),
        child: _buildHomeContent(context, state),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, DeliveryDashboardState state) {
    // HM0 — loading skeleton (bottom nav is shown)
    if (state.status != DeliveryDashboardStatus.failure &&
        (state.status == DeliveryDashboardStatus.loading ||
            state.dashboard == null)) {
      return const HomeSkeletonLoader();
    }

    // Failure with no data
    if (state.status == DeliveryDashboardStatus.failure) {
      return _FailureView(
        message: kDebugMode
            ? (state.errorMessage ?? context.tr.somethingWentWrong)
            : context.tr.somethingWentWrong,
        onRetry: () => context.read<DeliveryDashboardBloc>().add(
          const DeliveryDashboardInitialized(),
        ),
      );
    }

    final dashboard = state.dashboard!;

    return DeliveryDashboardContentView(
      dashboard: dashboard,
      isRefreshing: state.isRefreshing,
      isNotificationOverlayVisible: _showOverlayNotification,
      onToggleNotificationOverlay: () {
        setState(() => _showOverlayNotification = !_showOverlayNotification);
      },
      onNotificationsTap: () => context.push(RoutersName.notificationsScreen),
      showIncomingOverlay: !context.watch<OfferAlertCubit>().state.hasOffers,
      onReviewTap: () =>
          _openOffer(context.read<OfferAlertCubit>().state.first),
      onAttentionTap: _onAttentionTap,
      // Figma HM1 "Start delivery" -> R02 -> R03, HM2 "Open route" -> R10.
      onStartDelivery: () =>
          _openRouteTab((cubit) => cubit.beginPlanningFromHome()),
      onOpenRoute: () => _openRouteTab((cubit) => cubit.openRouteFromHome()),
      onScenarioCycle: kDebugMode
          ? () => context.read<DeliveryDashboardBloc>().add(
              const DeliveryDashboardScenarioCycled(),
            )
          : null,
      onRefresh: () async => context.read<DeliveryDashboardBloc>().add(
        const DeliveryDashboardRefreshed(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scrollable dashboard content — section order mirrors Figma.
// ─────────────────────────────────────────────────────────────────────────────

class DeliveryDashboardContentView extends StatelessWidget {
  const DeliveryDashboardContentView({
    super.key,
    required this.dashboard,
    required this.isRefreshing,
    required this.isNotificationOverlayVisible,
    required this.onToggleNotificationOverlay,
    required this.onNotificationsTap,
    required this.onRefresh,
    this.onStartDelivery,
    this.onOpenRoute,
    this.onScenarioCycle,
    this.showIncomingOverlay = true,
    this.onReviewTap,
    this.onAttentionTap,
  });

  final DeliveryDashboard dashboard;
  final bool isRefreshing;
  final bool isNotificationOverlayVisible;
  final VoidCallback onToggleNotificationOverlay;
  final VoidCallback onNotificationsTap;
  final Future<void> Function() onRefresh;
  final VoidCallback? onStartDelivery;
  final VoidCallback? onOpenRoute;
  final VoidCallback? onScenarioCycle;

  /// False while a real offer is on screen, so the two cards never stack.
  final bool showIncomingOverlay;

  /// "Review" on the in-app card -> OF1.
  final VoidCallback? onReviewTap;

  /// A "needs your attention" row was tapped.
  final ValueChanged<AttentionItem>? onAttentionTap;

  @override
  Widget build(BuildContext context) {
    final scenario = dashboard.scenario;
    final isOffline =
        dashboard.isOffline || scenario == DeliveryScenario.offline;
    final isFirstDay =
        scenario == DeliveryScenario.firstDay ||
        scenario == DeliveryScenario.newOrderFirstDay;
    final showTodaySection = dashboard.today != null && !isFirstDay;
    final showUpNext =
        scenario == DeliveryScenario.readyToStart ||
        scenario == DeliveryScenario.onRoute ||
        scenario == DeliveryScenario.newOrderOnRoute ||
        scenario == DeliveryScenario.allCaughtUp ||
        scenario == DeliveryScenario.noOrdersToday ||
        scenario == DeliveryScenario.noOrders ||
        isOffline;

    final Widget scrollContent = RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.brandMain,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.screenGutter.w),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          // 6px gap under 52 status bar so Header starts at top 58
          SizedBox(height: 6.h),

          // ── Header (360 x 55 at top 58) ───────────────────────────────
          DeliveryHeader(
            driverName: dashboard.driverName,
            profileImagePath: dashboard.profileImagePath,
            dateLabel: dashboard.dateLabel,
            userLocation: dashboard.userLocation,
            onNotificationsTap: onNotificationsTap,
            onScenarioCycleTap: onScenarioCycle,
            onToggleNotificationOverlay: onToggleNotificationOverlay,
          ),

          // ── Space below Header — measured per state from the design:
          //    offline banner starts 13 below, the first-day card 23.5 below,
          //    the TODAY card 46.5 below the 55-high header row. ──────────
          SizedBox(
            height: isOffline ? 13.h : (isFirstDay ? 23.5.h : 46.5.h),
          ),

          // ── Offline banner (HM4: 360 x 84) ────────────────────────────
          if (isOffline) ...[const OfflineBanner(), SizedBox(height: 16.h)],

          // ── First-day content (HM5 / HM8) ─────────────────────────────
          if (isFirstDay) ...[
            OnlineStatusBanner(dashboard: dashboard),
            SizedBox(height: 16.h),
          ],

          // ── TODAY section (360 x 208, HM1–HM4, HM6, HM9) ──────────────
          if (showTodaySection) ...[
            TodaySection(today: dashboard.today!),
            SizedBox(height: 16.h),
          ],

          // ── UP NEXT section (188h ready/route/offline, 129h caught-up) ─
          if (showUpNext) ...[
            UpNextSection(
              scenario: scenario,
              isOffline: isOffline,
              readyOrderCount: dashboard.readyOrderCount,
              companyName: dashboard.companyName,
              nextStop: dashboard.nextStop,
              onStartDelivery: onStartDelivery,
              onOpenRoute: onOpenRoute,
            ),
            SizedBox(height: 30.h),
          ],

          // ── NEEDS YOUR ATTENTION section (HM1, HM2, HM4, HM9) ─────────
          if (dashboard.attentionItems.isNotEmpty) ...[
            NeedsAttentionSection(
              items: dashboard.attentionItems,
              onItemTap: onAttentionTap,
            ),
            SizedBox(height: 16.h),
          ],

          // Bottom inset so last card clears the floating nav bar
          SizedBox(height: AppSizes.homeBottomInset.h),
        ],
      ),
    );

    if (dashboard.incomingOrderNotification != null && showIncomingOverlay) {
      return Stack(
        children: [
          scrollContent,
          PositionedDirectional(
            start: 16.w,
            end: 16.w,
            top: 50.h,
            child: InAppNotificationCard(
              title: dashboard.incomingOrderNotification!.title,
              timeAgo: dashboard.incomingOrderNotification!.timeAgo,
              subtitle: dashboard.incomingOrderNotification!.subtitle,
              onReviewTap: onReviewTap ?? () {},
              onDismiss: () {},
            ),
          ),
        ],
      );
    }

    return scrollContent;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Failure view
// ─────────────────────────────────────────────────────────────────────────────

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48.r,
              color: AppColors.textHint,
            ),
            SizedBox(height: AppSpacing.s16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.s14Regular.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: AppSpacing.s20.h),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandMain,
                foregroundColor: AppColors.onBrand,
              ),
              child: Text(context.tr.retry),
            ),
          ],
        ),
      ),
    );
  }
}
