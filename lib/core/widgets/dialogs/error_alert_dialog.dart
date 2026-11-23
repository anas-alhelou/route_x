import 'package:flutter/material.dart';

import '../../extensions/tr_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'routex_alert_dialog.dart';

/// Failure alert with a retry â€” Figma "Error Alert" (node 3195:2829).
///
/// The only alert in the family whose dismiss action is outlined rather than
/// filled, and the only one whose two actions are separated by 16pt instead of
/// 12pt; both quirks are reproduced here so the frame matches the design.
///
/// Resolves to `true` when the user retries and `false`/null when they back out.
class ErrorAlertDialog extends StatelessWidget {
  const ErrorAlertDialog({super.key, this.title, this.message});

  /// Overrides `context.tr.errorAlertTitle`.
  final String? title;

  /// Overrides `context.tr.errIncompleteResponse`.
  final String? message;

  /// Presents the alert and resolves to `true` if the user chose to retry.
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return RouteXAlertDialog.show(
      context: context,
      title: title ?? context.tr.errorAlertTitle,
      message: message ?? context.tr.errIncompleteResponse,
      icon: Icons.cancel,
      iconColor: AppColors.iconRed,
      iconBackgroundColor: AppColors.iconWarning,
      cancelLabel: context.tr.cancel,
      confirmLabel: context.tr.tryAgain,
      cancelStyle: RouteXCancelStyle.outlined,
      buttonGap: AppSpacing.s16,
      onConfirm: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteXAlertDialog(
      title: title ?? context.tr.errorAlertTitle,
      message: message ?? context.tr.errIncompleteResponse,
      icon: Icons.cancel,
      iconColor: AppColors.iconRed,
      iconBackgroundColor: AppColors.iconWarning,
      cancelLabel: context.tr.cancel,
      confirmLabel: context.tr.tryAgain,
      cancelStyle: RouteXCancelStyle.outlined,
      buttonGap: AppSpacing.s16,
    );
  }
}

extension ErrorAlertDialogX on BuildContext {
  /// Shorthand for [ErrorAlertDialog.show].
  Future<bool?> showErrorAlertDialog({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorAlertDialog.show(
      context: this,
      title: title,
      message: message,
      onRetry: onRetry,
    );
  }
}