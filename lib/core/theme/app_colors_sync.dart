import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Status-bar style that stays readable on the page background of the current
/// theme: dark icons on light pages, light icons on dark pages.
SystemUiOverlayStyle pageSystemUiOverlayStyle() => SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          AppColors.isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: AppColors.isDark ? Brightness.dark : Brightness.light,
    );

/// Keeps [AppColors.isDark] in step with the resolved theme brightness.
///
/// Place it once, under `MaterialApp` (its `builder`), so [Theme.of] already
/// reflects the user's choice (light / dark / system, including the phone's own
/// switch). When the brightness changes it flips [AppColors.isDark] and asks
/// every mounted widget to rebuild once: widgets that read [AppColors] directly
/// (not through [Theme]) would otherwise keep the old colours until their next
/// unrelated rebuild.
class AppColorsSync extends StatefulWidget {
  const AppColorsSync({super.key, required this.child});

  final Widget child;

  @override
  State<AppColorsSync> createState() => _AppColorsSyncState();
}

class _AppColorsSyncState extends State<AppColorsSync> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final changed = AppColors.isDark != dark;
    AppColors.isDark = dark;
    // Pages that do not set their own style follow the theme's status bar.
    SystemChrome.setSystemUIOverlayStyle(pageSystemUiOverlayStyle());
    if (changed) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _rebuildAll());
    }
  }

  void _rebuildAll() {
    void visit(Element element) {
      element.markNeedsBuild();
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
