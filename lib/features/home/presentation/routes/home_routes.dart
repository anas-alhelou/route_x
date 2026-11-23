// lib/features/home/presentation/routes/home_routes.dart
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/home/presentation/pages/delivery_dashboard_page.dart';
import 'package:routex_mobile/features/home/presentation/pages/enter_fleet_code_page.dart';
import 'package:routex_mobile/features/home/presentation/pages/find_fleet_page.dart';
import 'package:routex_mobile/features/home/presentation/pages/home_navigation_hub_page.dart';

/// The routes Home owns, declared once.
///
/// `app_router.dart` spreads [HomeRoutes.routes] into its top-level route list,
/// so this feature decides *which* pages it exposes while the app-level router
/// only decides *how* they are mounted.
abstract final class HomeRoutes {
  const HomeRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      name: RoutersName.homeScreen,
      path: RoutersName.homeScreen,
      builder: (context, state) {
        final scenario = state.extra is DeliveryScenario
            ? state.extra as DeliveryScenario
            : null;
        return DeliveryDashboardPage(initialScenario: scenario);
      },
    ),
    GoRoute(
      name: RoutersName.findFleetScreen,
      path: RoutersName.findFleetScreen,
      builder: (context, state) => const FindFleetPage(),
    ),
    GoRoute(
      name: RoutersName.enterFleetCodeScreen,
      path: RoutersName.enterFleetCodeScreen,
      builder: (context, state) => const EnterFleetCodePage(),
    ),
    GoRoute(
      name: RoutersName.appNavigationScreen,
      path: RoutersName.appNavigationScreen,
      builder: (context, state) => const HomeNavigationHubPage(),
    ),
  ];
}
