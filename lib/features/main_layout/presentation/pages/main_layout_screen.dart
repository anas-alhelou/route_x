// lib/features/main_layout/presentation/pages/main_layout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/notifications/app_shell_bus.dart';
import 'package:routex_mobile/core/notifications/notification_preferences.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:routex_mobile/core/notifications/notification_action_handler.dart';
import 'package:routex_mobile/features/main_layout/presentation/cubit/main_layout_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/notifications/route_notification_sync.dart';
import 'package:routex_mobile/features/main_layout/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:routex_mobile/features/home/presentation/pages/delivery_dashboard_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/orders_today_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/settings_page.dart';
import 'package:routex_mobile/features/route_fleet/presentation/pages/route_fleet_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MainLayoutScreen — provides [MainLayoutCubit] and mounts [_MainLayoutView].
// ─────────────────────────────────────────────────────────────────────────────

/// Root shell for the authenticated area of the app.
///
/// Provides [MainLayoutCubit] (default tab = 1/Route) and delegates
/// rendering to [_MainLayoutView].
class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainLayoutCubit>(
      create: (_) => MainLayoutCubit(),
      child: const _MainLayoutView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MainLayoutView — reads state and renders the UI.
// ─────────────────────────────────────────────────────────────────────────────

/// The four top-level pages rendered inside an animated switcher.
final List<Widget> _kPages = [
  const DeliveryDashboardPage(),
  const RouteFleetPage(),
  const OrdersTodayPage(),
  const SettingsPage(),
];

class _MainLayoutView extends StatefulWidget {
  const _MainLayoutView();

  @override
  State<_MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<_MainLayoutView> {
  RouteNotificationSync? _routeNotification;

  /// Tabs opened at least once; only these are built.
  final Set<int> _visited = <int>{};

  @override
  void initState() {
    super.initState();
    // Unread dot on the Home bell.
    getIt<GetNotificationsUseCase>()(const NoParams()).then((result) {
      result.fold(
        (_) {},
        (items) => NotificationInboxBadge.unread.value =
            items.where((n) => !n.isRead).length,
      );
    });
    // Lets a tap on a system notification reach the tabs and the route.
    AppShellBus.instance.attach(
      openTab: (index) => context.read<MainLayoutCubit>().changeTab(index),
      openRoute: _openRouteFromNotification,
    );
    // R35: the ongoing "On a route" notification follows the route.
    // (The developer hub opens the shell without a route cubit; skip it there.)
    RouteFleetCubit? routeCubit;
    try {
      routeCubit = context.read<RouteFleetCubit>();
    } catch (_) {}
    if (routeCubit != null) {
      _routeNotification = RouteNotificationSync(routeCubit);
    }
    // A notification tapped before the shell existed is handled now.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => NotificationActionHandler.instance.shellReady(),
    );
  }

  /// Figma R35 -> R10: the Route tab, driving.
  void _openRouteFromNotification() {
    try {
      context.read<RouteFleetCubit>().openRouteFromHome();
    } catch (_) {}
    context.read<MainLayoutCubit>().changeTab(1);
  }

  @override
  void dispose() {
    AppShellBus.instance.detach();
    _routeNotification?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutState = context.watch<MainLayoutCubit>().state;
    final currentIndex = layoutState.currentTabIndex;
    final isBottomNavVisible = layoutState.isBottomNavVisible;
    _visited.add(currentIndex);

    return Scaffold(
      // Remove the default bottom padding so the floating bar overlays content.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Page content ──
          // Tabs are built the first time they are opened and then kept alive,
          // so switching tabs is instant and never re-fetches the data (the
          // old switcher rebuilt every page and hit the API on each tap).
          IndexedStack(
            index: currentIndex,
            children: [
              for (var i = 0; i < _kPages.length; i++)
                _visited.contains(i) ? _kPages[i] : const SizedBox.shrink(),
            ],
          ),

          // ── Floating pill bottom navigation bar ────────────────────────────
          // The bar is shown on every tab, Home included, unless a child
          // screen hides it (e.g. the route camera / proof flows).
          if (isBottomNavVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) =>
                  context.read<MainLayoutCubit>().changeTab(index),
            ),
          ),
        ],
      ),
    );
  }
}
