// lib/core/animations/routex_overlays.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/motion.dart';

/// True when the device asks apps to cut down on motion (Android "Remove
/// animations", iOS "Reduce Motion").
bool motionReduced(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Every bottom sheet in the app opens through here, so they all move the same
/// way: the sheet slides up from the bottom edge and leaves the same way.
///
/// This wraps [showModalBottomSheet], so dragging the sheet down to dismiss it
/// keeps Flutter's own physics; only the durations are tuned ([Motion]). With
/// reduced motion on, the sheet still opens but in a fraction of the time.
Future<T?> showRoutexSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
  ShapeBorder? shape,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
}) {
  final reduced = motionReduced(context);
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    shape: shape,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    sheetAnimationStyle: AnimationStyle(
      duration: reduced ? Motion.reduced : Motion.sheetEnter,
      reverseDuration: reduced ? Motion.reduced : Motion.sheetExit,
    ),
  );
}

/// Every dialog in the app opens through here: it fades in while growing from
/// 96% of its size, around its centre, and leaves faster than it came. With
/// reduced motion on it only fades.
///
/// Mirrors [showDialog] (root navigator, scrim, theme capture, semantics).
Future<T?> showRoutexDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  return navigator.push<T>(
    _RoutexDialogRoute<T>(
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: themes.wrap(Builder(builder: builder)),
      ),
      reduced: motionReduced(context),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      barrierLabel:
          barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      settings: routeSettings,
    ),
  );
}

class _RoutexDialogRoute<T> extends RawDialogRoute<T> {
  _RoutexDialogRoute({
    required super.pageBuilder,
    required bool reduced,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
    super.settings,
  })  : _reduced = reduced,
        super(
          transitionDuration: reduced ? Motion.reduced : Motion.dialogEnter,
          transitionBuilder: _transition(reduced),
        );

  final bool _reduced;

  @override
  Duration get reverseTransitionDuration =>
      _reduced ? Motion.reduced : Motion.dialogExit;

  static RouteTransitionsBuilder _transition(bool reduced) {
    return (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Motion.dialogCurve,
        reverseCurve: Motion.dialogExitCurve,
      );
      final faded = FadeTransition(opacity: curved, child: child);
      if (reduced) return faded;
      return ScaleTransition(
        scale: Tween<double>(begin: Motion.dialogStartScale, end: 1).animate(curved),
        child: faded,
      );
    };
  }
}
