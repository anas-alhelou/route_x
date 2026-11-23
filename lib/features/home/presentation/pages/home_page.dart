// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_error_dialog.dart';
import 'package:routex_mobile/core/widgets/routex_load_failed.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:routex_mobile/features/home/presentation/navigation/home_navigator.dart';
import 'package:routex_mobile/features/home/presentation/widgets/driver_header.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_sheet.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_fleets_near_you_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_get_started_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_quick_actions_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_today_overview.dart';
import 'package:routex_mobile/features/home/presentation/widgets/new_order_offer_banner.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';
import 'package:routex_mobile/features/orders/presentation/pages/offer_one_order_page.dart';

// Preview data for the new-order-offer banner (from feature/orders).
const _sampleOrderOffer = OrderOfferEntity(
  id: 'home-offer-preview',
  fleetName: 'Red Sea Express',
  deadlineLabel: '09:58',
  stopsCount: 3,
  distanceLabel: '+6.8 km',
  timeLabel: '+36 min',
  note: 'Customer asked you to call when you arrive.',
  orders: [
    OfferOrderEntity(
      id: 'offer-order-1',
      customerName: 'Ahmed Ali',
      orderCode: 'RX-1052',
      area: 'Al Rawdah',
      timeWindow: '09:00 — 11:00',
      distanceKm: '+2.4 km',
      packagesCount: 1,
      addressDetails: 'Building 7, 3rd floor, flat 12',
      instructions: 'Signature needed at the door',
      deliveryDateLabel: 'Tomorrow, Mon 12 Oct',
      routePosition: 3,
    ),
    OfferOrderEntity(
      id: 'offer-order-2',
      customerName: 'Sara Hassan',
      orderCode: 'RX-1053',
      area: 'Al Nahda',
      timeWindow: '09:00 — 11:00',
      distanceKm: '+2.0 km',
      packagesCount: 1,
    ),
    OfferOrderEntity(
      id: 'offer-order-3',
      customerName: 'Omar Khalid',
      orderCode: 'RX-1054',
      area: 'Al Zahra',
      timeWindow: '09:00 — 11:00',
      distanceKm: '+2.4 km',
      packagesCount: 1,
    ),
  ],
);

/// The driver dashboard — Figma `Home First Run` (5222:8139).
///
/// Hosted inside MainLayout's `IndexedStack`, so this page draws no app bar of
/// its own: the layout owns the chrome. The layout's floating bottom bar
/// overlays this tab, so the list ends with enough space to clear it.
///
/// Self-providing: wraps its content in a [BlocProvider] for [HomeBloc] so the
/// page never depends on an ancestor to supply the bloc. This keeps
/// `MainLayoutScreen` untouched (hard constraint) and lets the page be used
/// both inside the `IndexedStack` and in tests without extra setup.
///
/// Composition only. Every section is a widget in its own file, so this page is
/// the list of what Home contains and in what order, and nothing else — which is
/// the only thing that changes when the design's section order does.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: const _HomeView(),
    );
  }
}

/// Inner view that assumes a [HomeBloc] is available above it.
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      // Fires only for an error that has appeared, or for a blocked-reason
      // signal that has appeared. Without this the listener would also run when
      // either was cleared, and the sheet would re-open as it dismissed itself.
      listenWhen: (previous, current) =>
          (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null) ||
          current.blockedReason != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          RouteXErrorDialog.show(
            context: context,
            message: context.translateValidationKey(state.errorMessage!),
          );
          context.read<HomeBloc>().add(const HomeErrorDismissed());
        } else if (state.blockedReason != null) {
          final reason = state.blockedReason!;
          context.read<HomeBloc>().add(const HomeBlockedReasonDismissed());
          showGoOnlineSheet(context, reason: reason, overview: state.overview);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceCanvas,
          body: SafeArea(
            bottom: false,
            child: switch (state.status) {
              HomeStatus.initial || HomeStatus.loading => const RouteXLoadingOverlay(
                isLoading: true,
                child: SizedBox.expand(),
              ),
              HomeStatus.failure => RouteXLoadFailed(
                onRetry: () =>
                    context.read<HomeBloc>().add(const HomeStarted()),
              ),
              HomeStatus.success => _HomeContent(
                state: state,
                onRefresh: () async =>
                    context.read<HomeBloc>().add(const HomeRefreshed()),
              ),
            },
          ),
        );
      },
    );
  }
}

/// The scrollable dashboard: header, then the four sections in design order.
///
/// Reads the whole [HomeState] rather than the individual pieces it forwards,
/// because the sections are all derived from one snapshot — passing
/// `availability`, `stats`, `setup` and `fleets` separately would invite the four
/// arguments to come from different moments.
class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state, required this.onRefresh});

  /// The state to render.
  final HomeState state;

  /// Pull-to-refresh handler.
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final overview = state.overview!;
    final bloc = context.read<HomeBloc>();
    const navigator = HomeNavigator();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          // Always scrollable so a short list can still be pulled to refresh;
          // bouncing because the dashboard is drawn on the same near-white
          // canvas as the screens it links to.
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24.w),
        children: [
          NewOrderOfferBanner(
            orderCount: _sampleOrderOffer.orders.length,
            fleetName: _sampleOrderOffer.fleetName,
            deadline: _sampleOrderOffer.deadlineLabel,
            onView: () => Navigator.of(context).push<OrderOfferOutcome>(
              MaterialPageRoute(
                builder: (_) => OfferOneOrderPage(
                  offer: _sampleOrderOffer,
                  order: _sampleOrderOffer.orders.first,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.s14.h),
          DriverHeader(
            profile: overview.profile,
            isOnline: overview.availability.isOnline,
            canToggleOnline: state.canToggleOnline,
            // The avatar wears the brand ring while the driver is waiting on a
            // dispatcher, whatever the outcome will be — pending and declined
            // both mean "someone owes you an answer".
            hasGreenBorder:
                overview.fleetRequest?.status == FleetRequestStatus.pending ||
                overview.fleetRequest?.status == FleetRequestStatus.declined,
            onOnlineChanged: (value) =>
                bloc.add(HomeOnlineToggled(isOnline: value)),
            onLockedOnlineTap: () => bloc.add(const HomeOnlineBlockedTapped()),
            // Debug gesture: cycles the request through every status so all
            // three Go Online frames can be reviewed without a backend.
            //
            // The handler is null in release, not merely ignored: leaving a
            // long-press wired to a handler that does nothing would still show
            // the platform's press feedback and imply the gesture works.
            onSwitchLongPress: kDebugMode
                ? () => _cycleRequestStatus(bloc, overview)
                : null,
            onNotificationsTap: () => navigator.toNotifications(context),
          ),
          SizedBox(height: AppSpacing.s30.h),
          HomeTodayOverview(overview: overview),
          SizedBox(height: AppSpacing.s14.w),
          HomeGetStartedCard(
            progress: overview.setup,
            // The setup gate and the quick action below are the same journey —
            // both send the driver to fleet search — so they share one target
            // rather than the card pretending to have a screen of its own.
            onTap: () => const HomeNavigator().toFindFleet(context),
          ),
          SizedBox(height: AppSpacing.s14.w),
          HomeQuickActionsCard(
            onFindFleet: () => navigator.toFindFleet(context),
            onEnterFleetCode: () => navigator.toEnterFleetCode(context),
          ),
          SizedBox(height: AppSpacing.s14.w),
          HomeFleetsNearYouCard(
            fleets: overview.nearbyFleets,
            isJoining: state.isSubmitting,
            hasPendingRequest:
                overview.fleetRequest?.status == FleetRequestStatus.pending,
            onJoin: (fleetId) =>
                bloc.add(HomeFleetJoinRequested(fleetId: fleetId)),
            onSeeAll: () => navigator.toFindFleet(context),
          ),
          // Clears the floating bottom bar: 64.h bar + 26.h screen margin.
          SizedBox(height: 64.h + 26.h + AppSpacing.s14.h),
        ],
      ),
    );
  }

  /// Advances the request one step around none → pending → declined → approved.
  ///
  /// Debug-only; the caller checks [kDebugMode]. The cycle returns to `none`
  /// rather than stopping at `approved` so a reviewer can reach the first frame
  /// again without restarting the app.
  void _cycleRequestStatus(HomeBloc bloc, HomeOverview overview) {
    final current = overview.fleetRequest?.status ?? FleetRequestStatus.none;
    final next = switch (current) {
      FleetRequestStatus.none => FleetRequestStatus.pending,
      FleetRequestStatus.pending => FleetRequestStatus.declined,
      FleetRequestStatus.declined => FleetRequestStatus.approved,
      FleetRequestStatus.approved => FleetRequestStatus.none,
    };
    bloc.add(HomeDebugRequestStatusChanged(status: next));
  }
}
