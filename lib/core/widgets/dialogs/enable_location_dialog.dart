import 'package:flutter/material.dart';

import '../../extensions/tr_extension.dart';
import '../../theme/app_colors.dart';
import 'routex_alert_dialog.dart';

/// Location permission rationale â€” Figma "Enable location" (node 3159:3059).
///
/// Shows what RouteX needs the fix for before the OS prompt appears. Dismissible
/// so the user can defer; [onAllow] is where the geolocator request belongs.
class EnableLocationDialog extends StatelessWidget {
  const EnableLocationDialog({super.key, this.title, this.message});

  /// Overrides `context.tr.enableLocationTitle`.
  final String? title;

  /// Overrides `context.tr.enableLocationMessage`.
  final String? message;

  /// Presents the rationale and completes once the user makes a choice.
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    VoidCallback? onAllow,
  }) {
    return RouteXAlertDialog.show(
      context: context,
      title: title ?? context.tr.enableLocationTitle,
      message: message ?? context.tr.enableLocationMessage,
      icon: Icons.location_on_rounded,
      iconColor: AppColors.brandSecondary,
      // Figma's pin is 25x36 rather than square; shrinking it keeps its optical
      // weight level with the 36pt icons in the other inline alerts.
      iconSize: 32,
      layout: RouteXAlertLayout.inline,
      confirmLabel: context.tr.allowAccess,
      onConfirm: onAllow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteXAlertDialog(
      title: title ?? context.tr.enableLocationTitle,
      message: message ?? context.tr.enableLocationMessage,
      icon: Icons.location_on_rounded,
      iconColor: AppColors.brandSecondary,
      iconSize: 32,
      layout: RouteXAlertLayout.inline,
      confirmLabel: context.tr.allowAccess,
    );
  }
}

extension EnableLocationDialogX on BuildContext {
  /// Shorthand for [EnableLocationDialog.show].
  Future<bool?> showEnableLocationDialog({
    String? title,
    String? message,
    VoidCallback? onAllow,
  }) {
    return EnableLocationDialog.show(
      context: this,
      title: title,
      message: message,
      onAllow: onAllow,
    );
  }
}