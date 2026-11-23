import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// The two card templates the RouteX alert family ships with.
///
/// Both render on a 340pt-wide card with a 16pt corner radius over
/// [AppColors.surfaceBackground], matching the alert frames in the
/// "RouteX-For-TaQat" Figma file.
enum RouteXAlertLayout {
  /// A 72pt badge above a centred title/message pair, closed by a row of two
  /// equal-width actions.
  ///
  /// Figma: "Error Alert" (3195:2829), "Discard Alert" (3159:2958),
  /// "Log out" (3159:3010), "Email Confirmation" (3226:451).
  centered,

  /// A 64pt badge on the leading edge of a start-aligned title/message pair,
  /// closed by a single full-width action.
  ///
  /// Figma: "Profile updated" (3142:2406), "Session expired" (3159:3042),
  /// "Enable location" (3159:3059).
  ///
  /// Because the badge is laid out with [Row], it sits on the right-hand edge
  /// under Arabic without any extra branching.
  inline,
}

/// Treatment of the leading (dismiss) action in a two-action row.
enum RouteXCancelStyle {
  /// Solid [AppColors.surfaceEmpty] fill. Used by every alert except the
  /// Figma "Error Alert".
  filled,

  /// Transparent fill with a [AppColors.borderDeactivated] hairline. Figma
  /// "Error Alert".
  outlined,
}

/// Shared card behind every alert, confirmation and status dialog in the app.
///
/// Handles the chrome common to all seven Figma frames (card geometry, badge,
/// title/message hierarchy, action row, scrim) so the concrete dialogs only
/// have to supply an icon, a tone and — where the design varies — a label.
///
/// Prefer the ready-made dialogs in this folder ([ErrorAlertDialog],
/// [LogoutDialog], [SessionExpiredDialog], ...) over constructing this
/// directly; reach for it only for a flow that has no design of its own.
class RouteXAlertDialog extends StatelessWidget {
  const RouteXAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.layout = RouteXAlertLayout.centered,
    this.iconBackgroundColor,
    this.iconSize,
    this.detail,
    this.cancelLabel,
    this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    this.dismissible = true,
    this.buttonGap = AppSpacing.s12,
    this.cancelStyle = RouteXCancelStyle.filled,
    this.actionRadius = 6,
    this.barrierColor,
  });

  /// Figma frame width; the card shrinks below this on narrow screens.
  static const double cardMaxWidth = 340;

  /// Figma corner radius of the card and of every action.
  static const double cardRadius = 16;

  /// `#000000` at 18%, offset y=8, blur 40 — the drop shadow Figma applies to
  /// the "Log out" and "Email Confirmation" frames.
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x2E000000),
      offset: Offset(0, 8),
      blurRadius: 40,
    ),
  ];

  /// Which of the two templates to render.
  final RouteXAlertLayout layout;

  /// Badge size: 72pt for [RouteXAlertLayout.centered], 64pt for
  /// [RouteXAlertLayout.inline].
  double get _badgeSize =>
      layout == RouteXAlertLayout.inline ? 64 : 72;

  /// Headline of the dialog. 24pt bold; centred or start-aligned per layout.
  final String title;

  /// Supporting copy under the title. 14pt regular.
  final String message;

  /// Glyph rendered inside the badge.
  final IconData icon;

  /// Glyph colour, which also sets the alert's tone.
  final Color iconColor;

  /// Badge fill. Defaults to the brand green tint [AppColors.iconBrand]; the
  /// destructive alerts in Figma use [AppColors.iconWarning] with a red
  /// [AppColors.iconColor].
  /// Badge fill; null follows the theme ([AppColors.iconBrand]).
  final Color? iconBackgroundColor;

  /// Optional glyph size override. Defaults to 36pt, matching Figma's 36pt
  /// icon frames; lower it for glyphs whose intrinsic aspect is narrower than
  /// square (the location pin is 25x36).
  final double? iconSize;

  /// Optional emphasised value rendered on its own row below [message], on a
  /// [AppColors.brandWhite] plate. Figma uses it for the address in "Email
  /// Confirmation".
  final String? detail;

  /// Label of the leading action. When `null` the dialog shows a single
  /// full-width [confirmLabel] instead of a two-action row.
  final String? cancelLabel;

  /// Label of the trailing / sole action.
  final String? confirmLabel;

  /// Invoked when [cancelLabel] is tapped. Defaults to dismissing the dialog.
  final VoidCallback? onCancel;

  /// Invoked when [confirmLabel] is tapped. Defaults to dismissing the dialog.
  final VoidCallback? onConfirm;

  /// Whether tapping the scrim or the system back gesture closes the dialog.
  ///
  /// Set to `false` for dialogs the user has to answer (session expiry), which
  /// also installs a [PopScope] so the hardware back button cannot bypass it.
  final bool dismissible;

  /// Horizontal gap between the two actions in a two-action row.
  final double buttonGap;

  /// Treatment of the leading action.
  final RouteXCancelStyle cancelStyle;

  /// Corner radius of the actions.
  final double actionRadius;

  /// Scrim colour behind the card. `null` keeps the Material default.
  final Color? barrierColor;

  /// Presents the dialog.
  ///
  /// Resolves to `true` when [confirmLabel] was tapped, `false` when
  /// [cancelLabel] was, and `null` when the dialog was dismissed by the scrim or
  /// the system back gesture — so callers can tell "declined" apart from
  /// "dismissed" with a plain `??`.
  ///
  /// Every parameter mirrors the matching constructor argument, so callers can
  /// override copy without losing the design-system chrome.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    RouteXAlertLayout layout = RouteXAlertLayout.centered,
    Color? iconBackgroundColor,
    double? iconSize,
    String? detail,
    String? cancelLabel,
    String? confirmLabel,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool dismissible = true,
    double buttonGap = AppSpacing.s12,
    RouteXCancelStyle cancelStyle = RouteXCancelStyle.filled,
    double actionRadius = 6,
    Color? barrierColor,
  }) {
    return showRoutexDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: barrierColor,
      builder: (_) => RouteXAlertDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        layout: layout,
        iconBackgroundColor: iconBackgroundColor,
        iconSize: iconSize,
        detail: detail,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        onCancel: onCancel,
        onConfirm: onConfirm,
        dismissible: dismissible,
        buttonGap: buttonGap,
        cancelStyle: cancelStyle,
        actionRadius: actionRadius,
        barrierColor: barrierColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInline = layout == RouteXAlertLayout.inline;
    final NavigatorState navigator = Navigator.of(context);

    // The Figma frames pin the card at 340pt; below that the dialog has to give
    // way, so the width is capped rather than fixed and the content scrolls.
    final Widget card = Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s24.w,
        vertical: AppSpacing.s24.h,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardMaxWidth.w),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius.r),
            boxShadow: _cardShadow,
          ),
          child: Material(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(cardRadius.r),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: (isInline ? AppSpacing.s28 : AppSpacing.s24).w,
                  right: (isInline ? AppSpacing.s28 : AppSpacing.s24).w,
                  top: (isInline ? AppSpacing.s32 : AppSpacing.s28).h,
                  bottom: (isInline ? AppSpacing.s24 : AppSpacing.s28).h,
                ),
                child: isInline
                    ? _buildInlineBody(context, theme)
                    : _buildCenteredBody(context, theme, navigator),
              ),
            ),
          ),
        ),
      ),
    );

    // A dialog the user must answer cannot be escaped with the back button.
    if (dismissible) return card;
    return PopScope(canPop: false, child: card);
  }

  /// 72pt badge, centred title and message, optional detail plate, two actions.
  Widget _buildCenteredBody(
    BuildContext context,
    ThemeData theme,
    NavigatorState navigator,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _AlertBadge(
          size: _badgeSize,
          icon: icon,
          iconColor: iconColor,
          backgroundColor: iconBackgroundColor ?? AppColors.iconBrand,
          iconSize: iconSize,
        ),
        SizedBox(height: AppSpacing.s16.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            height: 33 / 24,
          ),
        ),
        SizedBox(height: AppSpacing.s8.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 23 / 14,
          ),
        ),
        // Figma leaves no gap between the message and the detail plate.
        if (detail != null)
          _AlertDetailPlate(
            detail: detail!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.brandDeepBlack,
              fontWeight: FontWeight.w700,
              height: 23 / 14,
            ),
          ),
        SizedBox(
          height: (detail != null ? AppSpacing.s24 : AppSpacing.s16).h,
        ),
        _buildActions(context, theme, navigator),
      ],
    );
  }

  /// 64pt badge beside a start-aligned title and message, one full-width action.
  Widget _buildInlineBody(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AlertBadge(
              size: _badgeSize,
              icon: icon,
              iconColor: iconColor,
              backgroundColor: iconBackgroundColor ?? AppColors.iconBrand,
              iconSize: iconSize,
            ),
            SizedBox(width: AppSpacing.s18.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 30 / 24,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s6.h),
                  Text(
                    message,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 21 / 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s20.h),
        _AlertAction(
          label: confirmLabel ?? '',
          radius: actionRadius,
          height: 52,
          filled: true,
          labelStyle: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.brandBlack,
            height: 22 / 16,
            letterSpacing: 0.16,
          ),
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  /// A row of two equal-width actions, or a single full-width one when the
  /// dialog has no leading action.
  Widget _buildActions(
    BuildContext context,
    ThemeData theme,
    NavigatorState navigator,
  ) {
    final TextStyle? labelStyle = theme.textTheme.titleLarge?.copyWith(
      color: AppColors.brandBlack,
      height: 22 / 16,
      letterSpacing: 0.16,
    );

    if (cancelLabel == null) {
      return _AlertAction(
        label: confirmLabel ?? '',
        radius: actionRadius,
        height: 54,
        filled: true,
        labelStyle: labelStyle,
        onPressed: () {
          onConfirm?.call();
          navigator.pop(true);
        },
      );
    }

    return Row(
      children: [
        Expanded(
          child: _AlertAction(
            label: cancelLabel!,
            radius: actionRadius,
            height: 54,
            filled: cancelStyle == RouteXCancelStyle.filled,
            outlined: cancelStyle == RouteXCancelStyle.outlined,
            onPressed: () {
              onCancel?.call();
              navigator.pop(false);
            },
          ),
        ),
        SizedBox(width: buttonGap.w),
        Expanded(
          child: _AlertAction(
            label: confirmLabel ?? '',
            radius: actionRadius,
            height: 54,
            labelStyle: labelStyle,
            filled: true,
            onPressed: () {
              onConfirm?.call();
              navigator.pop(true);
            },
          ),
        ),
      ],
    );
  }
}

/// Circular badge holding the alert's glyph.
class _AlertBadge extends StatelessWidget {
  const _AlertBadge({
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.iconSize,
  });

  final double size;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  /// Glyph size override; defaults to 36pt scaled off the badge.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      // A single `.w` on both axes keeps the badge perfectly circular on any
      // aspect ratio, which per-axis scaling would not.
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: (iconSize ?? 36).w, color: iconColor),
    );
  }
}

/// The 39pt white plate Figma uses to echo a value back at the user.
class _AlertDetailPlate extends StatelessWidget {
  const _AlertDetailPlate({required this.detail, required this.style});

  final String detail;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 39.h,
      color: AppColors.brandWhite,
      alignment: Alignment.center,
      child: Text(
        detail,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}

/// One dialog action: brand-green fill, or the neutral/secondary treatments.
class _AlertAction extends StatelessWidget {
  const _AlertAction({
    required this.label,
    required this.radius,
    required this.height,
    required this.filled,
    required this.onPressed,
    this.outlined = false,
    this.labelStyle,
  });

  final String label;
  final double radius;

  /// Figma height: 54pt on the centred alerts, 52pt on the inline ones.
  final double height;

  /// `true` paints the brand-green confirm fill; `false` paints the neutral
  /// grey used for a dismiss action.
  final bool filled;

  /// Draws a hairline border instead of a grey fill.
  final bool outlined;

  final TextStyle? labelStyle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style =
        labelStyle ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.brandBlack,
          height: 22 / 16,
          letterSpacing: 0.16,
        );

    return SizedBox(
      height: height.h,
      child: filled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandMain,
                foregroundColor: AppColors.onBrand,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12.w,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius.r),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: style,
              ),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: outlined
                    ? Colors.transparent
                    : AppColors.surfaceEmpty,
                foregroundColor: AppColors.textPrimary,
                side: outlined
                    ? BorderSide(
                        color: AppColors.borderDeactivated,
                        width: 1.2.w,
                      )
                    : BorderSide.none,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12.w,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius.r),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
    );
  }
}