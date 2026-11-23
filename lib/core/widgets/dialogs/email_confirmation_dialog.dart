import 'package:flutter/material.dart';

import '../../extensions/tr_extension.dart';
import '../../theme/app_colors.dart';
import 'routex_alert_dialog.dart';

/// Address confirmation shown before a verification code is sent â€” Figma
/// "Email Confirmation" (node 3226:451).
///
/// The only alert with a [RouteXAlertDialog.detail]: the address is echoed back
/// on its own plate so the user can catch a typo before the code goes out.
/// Resolves to `true` when the user asked for the code.
class EmailConfirmationDialog extends StatelessWidget {
  const EmailConfirmationDialog({
    super.key,
    required this.email,
    this.title,
    this.message,
  });

  /// The address to echo back. Never localised â€” it is user data.
  final String email;

  /// Overrides `context.tr.confirmYourEmailTitle`.
  final String? title;

  /// Overrides `context.tr.confirmYourEmailMessage`.
  final String? message;

  /// Presents the confirmation and resolves to `true` if the code was requested.
  static Future<bool?> show({
    required BuildContext context,
    required String email,
    String? title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    return RouteXAlertDialog.show(
      context: context,
      title: title ?? context.tr.confirmYourEmailTitle,
      message: message ?? context.tr.confirmYourEmailMessage,
      detail: email,
      icon: Icons.mark_email_read,
      iconColor: AppColors.brandSecondary,
      cancelLabel: context.tr.cancel,
      confirmLabel: context.tr.sendCode,
      onConfirm: onConfirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteXAlertDialog(
      title: title ?? context.tr.confirmYourEmailTitle,
      message: message ?? context.tr.confirmYourEmailMessage,
      detail: email,
      icon: Icons.mark_email_read,
      iconColor: AppColors.brandSecondary,
      cancelLabel: context.tr.cancel,
      confirmLabel: context.tr.sendCode,
    );
  }
}

extension EmailConfirmationDialogX on BuildContext {
  /// Shorthand for [EmailConfirmationDialog.show].
  Future<bool?> showEmailConfirmationDialog({
    required String email,
    String? title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    return EmailConfirmationDialog.show(
      context: this,
      email: email,
      title: title,
      message: message,
      onConfirm: onConfirm,
    );
  }
}