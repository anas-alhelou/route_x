// lib/features/home/presentation/navigation/home_navigator.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';

/// Every destination reachable from Home, in one place.
///
/// The Home page would otherwise carry three identical `context.push` calls
/// with route strings scattered through its widget tree; routing them through
/// here keeps the dashboard from depending on *how* a destination is reached.
class HomeNavigator {
  const HomeNavigator();

  /// Opens fleet search. Reached from "Find a fleet", "Enter fleet code" and
  /// "See all".
  void toFindFleet(BuildContext context) {
    context.pushNamed(RoutersName.findFleetScreen);
  }

  /// Opens notifications. Reached from the header bell.
  void toNotifications(BuildContext context) {
    context.pushNamed(RoutersName.notificationsScreen);
  }

  /// Opens the fleet code entry flow. Reached from quick action, find fleet footer, or bottom sheet.
  void toEnterFleetCode(BuildContext context) {
    context.pushNamed(RoutersName.enterFleetCodeScreen);
  }
}
