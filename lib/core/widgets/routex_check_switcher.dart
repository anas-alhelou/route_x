// lib/core/widgets/routex_check_switcher.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';
import 'package:routex_mobile/core/motion.dart';

/// Swaps between two icons with a short scale-and-fade "pop".
///
/// Used for the green tick that appears when two passwords match and for each
/// password-requirement row, so a state change reads as an event rather than a
/// sudden redraw. The incoming icon overshoots slightly ([Motion.checkPopIn]).
/// With the OS "reduce motion" setting on, the swap is instant.
///
/// Both children need distinct keys so [AnimatedSwitcher] sees a change.
class RouteXCheckSwitcher extends StatelessWidget {
  const RouteXCheckSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: motionReduced(context) ? Duration.zero : Motion.checkPop,
      // The switcher's own curves must stay inside [0, 1] because they also
      // drive the fade; the overshoot is applied to the scale alone below.
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation.drive(CurveTween(curve: Motion.checkPopIn)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
