import 'package:flutter/material.dart';

import '../../extensions/tr_extension.dart';
import '../../theme/app_colors.dart';
import 'routex_alert_dialog.dart';

/// Sign-out confirmation â€” Figma "Log out" (node 3159:3010).
///
/// One of the two frames the design carries a drop shadow on; the shell applies
/// it to every alert. Resolves to `true` when the user confirms.
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key, this.title, this.message});

  /// Overrides `context.tr.logOutTitle`.
  final String? title;

  /// Overrides `context.tr.logOutMessage`.
  final String? message;

  /// Presents the confirmation and resolves to `true` if the user signed out.
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    return RouteXAlertDialog.show(
      context: context,
      title: title ?? context.tr.logOutTitle,
      message: message ?? context.tr.logOutMessage,
      icon: Icons.logout,
      iconColor: AppColors.brandSecondary,
      cancelLabel: context.tr.cancel,
      confirmLabel: context.tr.logOut,
      onConfirm: onConfirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteXAlertDialog(
      title: title ?? context.tr.logOutTitle,
      message: message ?? context.tr.logOutMessage,
      icon: Icons.logout,
      iconColor: AppColors.brandSecondary,
      cancelLabel: context.tr.cancel,
      confirmLabel: context.tr.logOut,
    );
  }
}

extension LogoutDialogX on BuildContext {
  /// Shorthand for [LogoutDialog.show].
  Future<bool?> showLogoutDialog({
    String? title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    return LogoutDialog.show(
      context: this,
      title: title,
      message: message,
      onConfirm: onConfirm,
    );
  }
}