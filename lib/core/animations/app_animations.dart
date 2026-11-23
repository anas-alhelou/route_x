import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Page Route Animations
// ─────────────────────────────────────────────────────────────────────────────

/// Custom PageRouteBuilder combining SlideTransition and FadeTransition.
/// Duration: 280ms (forward), 220ms (reverse).
/// Curve: Curves.easeOutCubic.
class AppCustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool slideVertical;

  AppCustomPageRoute({required this.page, this.slideVertical = false})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            // Reduced motion: fade only, nothing travels.
            if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
              return FadeTransition(opacity: curvedAnimation, child: child);
            }
            return SlideTransition(
              position: Tween<Offset>(
                begin: slideVertical ? const Offset(0.0, 0.04) : const Offset(0.05, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
        );
}

/// Alias for backward compatibility across the app.
class FadeSlidePageRoute<T> extends AppCustomPageRoute<T> {
  FadeSlidePageRoute({required super.page, super.slideVertical});
}

/// Custom PageTransitionsBuilder for app-wide ThemeData integration.
class AppCustomPageTransitionBuilder extends PageTransitionsBuilder {
  const AppCustomPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    // Reduced motion: fade only, nothing travels.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return FadeTransition(opacity: curvedAnimation, child: child);
    }
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: child,
      ),
    );
  }
}
