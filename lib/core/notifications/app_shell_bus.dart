// lib/core/notifications/app_shell_bus.dart
import 'package:flutter/foundation.dart';

/// A small bridge between things that happen outside the widget tree (a tap on
/// a system notification) and the main shell (bottom tabs, route cubit).
///
/// The shell registers itself while it is on screen; until then
/// [isReady] is false and callers queue what they wanted to do.
class AppShellBus {
  AppShellBus._();

  static final AppShellBus instance = AppShellBus._();

  ValueChanged<int>? _openTab;
  VoidCallback? _openRoute;

  /// Bumped every time an offer is answered or arrives, so the screens that
  /// show offers (Home banner, Orders tab) know to ask again.
  final ValueNotifier<int> offersRevision = ValueNotifier<int>(0);

  bool get isReady => _openTab != null;

  void attach({
    required ValueChanged<int> openTab,
    required VoidCallback openRoute,
  }) {
    _openTab = openTab;
    _openRoute = openRoute;
  }

  void detach() {
    _openTab = null;
    _openRoute = null;
  }

  /// 0 Home, 1 Route, 2 Orders, 3 Settings.
  void openTab(int index) => _openTab?.call(index);

  /// Figma R35 -> R10: bring the Route tab up with the route running.
  void openRoute() => _openRoute?.call();

  void offersChanged() => offersRevision.value++;
}
