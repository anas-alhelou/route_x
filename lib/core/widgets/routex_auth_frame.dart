// lib/core/widgets/routex_auth_frame.dart
import 'package:flutter/material.dart';

/// Body wrapper shared by every login / signup / password-reset screen.
///
/// Gives the screen a [SafeArea] and keeps its content at most [maxWidth] wide,
/// centred, so on a tablet or in landscape the form stays a readable column
/// instead of stretching edge to edge with the heading far from the fields.
/// On a phone (narrower than [maxWidth]) it is a plain [SafeArea]: nothing
/// changes.
///
/// The child still receives the full height, so screens built around an
/// `Expanded` scroll area keep working.
class RouteXAuthFrame extends StatelessWidget {
  const RouteXAuthFrame({super.key, required this.child});

  /// Widest the content may grow, in logical pixels.
  static const double maxWidth = 480;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
