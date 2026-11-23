import 'package:flutter/material.dart';

import '../../extensions/tr_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'routex_alert_dialog.dart';

/// Destructive "you will lose your edits" prompt â€” Figma "Discard Alert"
/// (node 3159:2958).
///
/// Uses a bare exclamation glyph rather than a framed icon, matching the frame.
/// Resolves to `true` when the user confirms the discard.
class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key, this.title, this.message});

  /// Overrides `context.tr.discardChangesTitle`.
  final String? title;

  /// Overrides `context.tr.discardChangesMessage`.
  final String? message;

  /// Presents the prompt and resolves to `true` if the edits were discarded.
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
  }) {
    return RouteXAlertDialog.show(
      context: context,
      title: title ?? context.tr.discardChangesTitle,
      message: message ?? context.tr.discardChangesMessage,
      icon: Icons.priority_high_rounded,
      iconColor: AppColors.iconRed,
      iconBackgroundColor: AppColors.iconWarning,
      // Figma's glyph is 20x61 inside a 72pt badge, so it renders larger than
      // the 36pt icons used by the rest of the family.
      iconSize: 44,
      cancelLabel: context.tr.cancel,
      confirmLabel: context.tr.discard,
      buttonGap: AppSpacing.s16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RouteXAlertDialog(
      title: title ?? context.tr.discardChangesTitle,
      message: message ?? context.tr.discardChangesMessage,
      icon: Icons.priority_high_rounded,
      iconColor: AppColors.iconRed,
      iconBackgroundColor: AppColors.iconWarning,
      iconSize: 44,
      cancelLabel: context.tr.cancel,
      confirmLabel: context.tr.discard,
      buttonGap: AppSpacing.s16,
    );
  }
}

extension DiscardChangesDialogX on BuildContext {
  /// Shorthand for [DiscardChangesDialog.show].
  Future<bool?> showDiscardChangesDialog({String? title, String? message}) {
    return DiscardChangesDialog.show(
      context: this,
      title: title,
      message: message,
    );
  }
}