import 'package:flutter/material.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// The press feedback shared by every large RouteX button.
///
/// Scales its child down slightly while held down and springs back on release.
/// Extracted from `RouteXMainButton` so the newer call-to-action components
/// inherit exactly the same feel instead of each re-deriving a duration and a
/// scale factor — a button that reacts differently from its neighbour is the
/// kind of difference nobody notices until both are on screen together.
///
/// Disabled entirely rather than dimmed on tap: a control that is not accepting
/// the gesture must not animate as though it were.
class RouteXPressable extends StatefulWidget {
  const RouteXPressable({
    required this.child,
    super.key,
    this.onTap,
    this.isEnabled = true,
    this.borderRadius,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool isEnabled;
  final BorderRadius? borderRadius;
  final double pressedScale;

  @override
  State<RouteXPressable> createState() => _RouteXPressableState();
}

class _RouteXPressableState extends State<RouteXPressable> {
  static const Duration _pressDuration = Duration(milliseconds: 120);

  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // Reduced motion: no scaling at all (a disabled control never animates).
    if (!widget.isEnabled || widget.onTap == null || motionReduced(context)) {
      return widget.child;
    }

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1,
        duration: _pressDuration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A drop-in replacement for a tappable [GestureDetector] that adds the same
/// press feedback as [RouteXPressable]: the child shrinks slightly while held
/// and springs back on release.
///
/// Use it for isolated buttons, option tiles and links that otherwise give no
/// visual response. Not for rows in long lists, tab bars, or anything that
/// already animates its own press. With no [onTap], or with reduced motion on,
/// it behaves exactly like a plain [GestureDetector].
class RouteXTapScale extends StatefulWidget {
  const RouteXTapScale({
    super.key,
    required this.onTap,
    required this.child,
    this.behavior,
    this.pressedScale = 0.97,
  });

  final VoidCallback? onTap;
  final Widget child;
  final HitTestBehavior? behavior;
  final double pressedScale;

  @override
  State<RouteXTapScale> createState() => _RouteXTapScaleState();
}

class _RouteXTapScaleState extends State<RouteXTapScale> {
  static const Duration _duration = Duration(milliseconds: 120);

  bool _pressed = false;

  void _set(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final animate = widget.onTap != null && !motionReduced(context);
    return GestureDetector(
      onTap: widget.onTap,
      behavior: widget.behavior,
      onTapDown: animate ? (_) => _set(true) : null,
      onTapUp: animate ? (_) => _set(false) : null,
      onTapCancel: animate ? () => _set(false) : null,
      child: animate
          ? AnimatedScale(
              scale: _pressed ? widget.pressedScale : 1,
              duration: _duration,
              curve: Curves.easeOut,
              child: widget.child,
            )
          : widget.child,
    );
  }
}
