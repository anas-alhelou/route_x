import 'package:flutter/material.dart';
import 'package:routex_mobile/core/motion.dart';

/// Reusable horizontal shake animation widget for error states (e.g. invalid OTP or fleet code).
///
/// Replicates the shake behavior from `AuthOtpView`:
/// - 400ms duration ([Motion.shakeDuration])
/// - 5 equal-weight items on X offset: 0 -> -10 -> 10 -> -10 -> 10 -> 0
/// - Triggers with `forward(from: 0.0)` whenever [hasError] transitions from `false` to `true`.
/// - Respects [MediaQueryData.disableAnimations].
class RouteXShake extends StatefulWidget {
  const RouteXShake({
    super.key,
    required this.child,
    required this.hasError,
    this.onShakeCompleted,
  });

  final Widget child;
  final bool hasError;
  final VoidCallback? onShakeCompleted;

  @override
  State<RouteXShake> createState() => _RouteXShakeState();
}

class _RouteXShakeState extends State<RouteXShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: Motion.shakeDuration,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onShakeCompleted?.call();
      }
    });

    if (widget.hasError) {
      _triggerShake();
    }
  }

  void _triggerShake() {
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      widget.onShakeCompleted?.call();
      return;
    }
    _shakeController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(RouteXShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.hasError && widget.hasError) {
      _triggerShake();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}
