// lib/core/widgets/smart_animate_route.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/motion.dart';

/// go_router page approximating Figma's "Smart animate": the new screen fades
/// in while rising slightly, and the old one fades out underneath, instead of
/// the platform slide. Instant when the device asks for reduced motion.
class SmartAnimatePage<T> extends CustomTransitionPage<T> {
  const SmartAnimatePage({required super.child, super.key})
      : super(
          transitionDuration: Motion.smartAnimate,
          reverseTransitionDuration: Motion.smartAnimate,
          transitionsBuilder: _transition,
        );

  static Widget _transition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.of(context).disableAnimations) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Motion.smartAnimateCurve,
      reverseCurve: Motion.smartAnimateCurve.flipped,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, Motion.smartAnimateRise),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
