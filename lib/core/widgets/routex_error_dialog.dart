import 'package:flutter/material.dart';

import '../extensions/tr_extension.dart';
import '../theme/app_colors.dart';
import 'dialogs/routex_alert_dialog.dart';

/// Single-action error alert for API and validation failures.
///
/// This is the dialog the auth flow calls from ten sites, so it keeps the
/// original `show(context:, message:, title:)` contract while dropping the
/// hand-rolled card it used to draw: it now renders through
/// [RouteXAlertDialog], which means the shared geometry, the design-system
/// colours and â€” unlike the version it replaces â€” a localized title and button
/// instead of the hardcoded "Error" / "OK".
///
/// For the two-action retry prompt ("Try again") use `ErrorAlertDialog`.
class RouteXErrorDialog extends StatelessWidget {
  const RouteXErrorDialog({super.key, required this.message, this.title});

  /// Body copy, already localized by the caller.
  final String message;

  /// Headline. Defaults to `context.tr.errorAlertTitle`.
  final String? title;

  /// Presents the alert and completes once it is dismissed.
  static Future<bool?> show({
    required BuildContext context,
    required String message,
    String? title,
  }) {
    return RouteXAlertDialog.show(
      context: context,
      title: title ?? context.tr.errorAlertTitle,
      message: message,
      icon: Icons.cancel,
      iconColor: AppColors.iconRed,
      iconBackgroundColor: AppColors.iconWarning,
      confirmLabel: context.tr.done,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteXAlertDialog(
      title: title ?? context.tr.errorAlertTitle,
      message: message,
      icon: Icons.cancel,
      iconColor: AppColors.iconRed,
      iconBackgroundColor: AppColors.iconWarning,
      confirmLabel: context.tr.done,
    );
  }
}