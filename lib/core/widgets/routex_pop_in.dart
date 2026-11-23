// lib/core/widgets/routex_pop_in.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';
import 'package:routex_mobile/core/motion.dart';

/// Brings [child] in once, when it is first drawn: a fade while growing from
/// 90% to full size ([Motion.popIn]).
///
/// For the rare, emotional moments only: the badge on a success screen, the
/// illustration of an empty state. Not for working UI that is seen many times
/// a day. With reduced motion on, the child is simply there.
class RouteXPopIn extends StatelessWidget {
  const RouteXPopIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (motionReduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Motion.popIn,
      curve: Motion.popInCurve,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: Motion.popInStartScale + (1 - Motion.popInStartScale) * t,
          child: child,
        ),
      ),
    );
  }
}
