// lib/features/notifications/presentation/routes/notifications_routes.dart
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/notifications/presentation/pages/notifications_page.dart';

/// The routes Notifications owns.
///
/// `app_router.dart` spreads [NotificationsRoutes.routes] into its top-level
/// route list, so this feature decides which pages it exposes while the
/// app-level router only decides how they are mounted.
abstract final class NotificationsRoutes {
  const NotificationsRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      name: RoutersName.notificationsScreen,
      path: RoutersName.notificationsScreen,
      builder: (context, state) {
        final startEmpty = state.extra is bool ? state.extra as bool : false;
        return NotificationsPage(startEmpty: startEmpty);
      },
    ),
  ];
}
