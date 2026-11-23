import 'package:flutter/material.dart';

import '../../extensions/tr_extension.dart';
import '../../theme/app_colors.dart';
import 'routex_alert_dialog.dart';

/// Save confirmation â€” Figma "Profile updated" (node 3142:2406).
///
/// Inline layout: the badge sits beside the copy rather than above it, which
/// keeps the card short enough for a toast-style confirmation. Acknowledged
/// with a single full-width action.
class ProfileUpdatedDialog extends StatelessWidget {
  const ProfileUpdatedDialog({super.key, this.title, this.message});

  /// Overrides `context.tr.profileUpdatedTitle`.
  final String? title;

  /// Overrides `context.tr.profileUpdatedMessage`.
  final String? message;

  /// Presents the confirmation and completes once it is acknowledged.
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    VoidCallback? onDone,
  }) {
    return RouteXAlertDialog.show(
      context: context,
      title: title ?? context.tr.profileUpdatedTitle,
      message: message ?? context.tr.profileUpdatedMessage,
      icon: Icons.check_rounded,
      iconColor: AppColors.brandSecondary,
      layout: RouteXAlertLayout.inline,
      confirmLabel: context.tr.done,
      onConfirm: onDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteXAlertDialog(
      title: title ?? context.tr.profileUpdatedTitle,
      message: message ?? context.tr.profileUpdatedMessage,
      icon: Icons.check_rounded,
      iconColor: AppColors.brandSecondary,
      layout: RouteXAlertLayout.inline,
      confirmLabel: context.tr.done,
    );
  }
}

extension ProfileUpdatedDialogX on BuildContext {
  /// Shorthand for [ProfileUpdatedDialog.show].
  Future<bool?> showProfileUpdatedDialog({
    String? title,
    String? message,
    VoidCallback? onDone,
  }) {
    return ProfileUpdatedDialog.show(
      context: this,
      title: title,
      message: message,
      onDone: onDone,
    );
  }
}