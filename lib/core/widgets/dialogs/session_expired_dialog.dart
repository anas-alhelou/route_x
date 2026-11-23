import 'package:flutter/material.dart';

import '../../extensions/tr_extension.dart';
import '../../theme/app_colors.dart';
import 'routex_alert_dialog.dart';

/// Forced re-authentication notice â€” Figma "Session expired" (node 3159:3042).
///
/// Non-dismissible: the session is already gone, so neither the scrim nor the
/// hardware back button may skip the "Sign in" step.
class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key, this.title, this.message});

  /// Overrides `context.tr.sessionExpiredTitle`.
  final String? title;

  /// Overrides `context.tr.sessionExpiredMessage`.
  final String? message;

  /// Presents the notice and completes once the user signs in.
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    VoidCallback? onSignIn,
  }) {
    return RouteXAlertDialog.show(
      context: context,
      title: title ?? context.tr.sessionExpiredTitle,
      message: message ?? context.tr.sessionExpiredMessage,
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.brandSecondary,
      layout: RouteXAlertLayout.inline,
      confirmLabel: context.tr.signIn,
      dismissible: false,
      onConfirm: onSignIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteXAlertDialog(
      title: title ?? context.tr.sessionExpiredTitle,
      message: message ?? context.tr.sessionExpiredMessage,
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.brandSecondary,
      layout: RouteXAlertLayout.inline,
      confirmLabel: context.tr.signIn,
      dismissible: false,
    );
  }
}

extension SessionExpiredDialogX on BuildContext {
  /// Shorthand for [SessionExpiredDialog.show].
  Future<bool?> showSessionExpiredDialog({
    String? title,
    String? message,
    VoidCallback? onSignIn,
  }) {
    return SessionExpiredDialog.show(
      context: this,
      title: title,
      message: message,
      onSignIn: onSignIn,
    );
  }
}