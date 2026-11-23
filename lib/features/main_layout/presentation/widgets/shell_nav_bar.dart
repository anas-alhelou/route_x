// lib/features/main_layout/presentation/widgets/shell_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/notifications/app_shell_bus.dart';
import 'package:routex_mobile/features/main_layout/presentation/widgets/custom_bottom_navigation_bar.dart';

/// The bottom navigation bar for screens opened on top of the main shell
/// (order detail, history detail, stop records…). The prototype keeps the bar
/// on them: a tap closes the stack and opens that tab.
class ShellNavBar extends StatelessWidget {
  const ShellNavBar({super.key, this.currentIndex = 2});

  /// 0 Home · 1 Route · 2 Orders · 3 Settings.
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
        AppShellBus.instance.openTab(index);
      },
    );
  }
}
