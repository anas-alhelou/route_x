// lib/core/widgets/routex_screen_entry.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/motion.dart';

/// Fades and slides [child] in once, when the screen is first drawn.
///
/// The app's single screen-entry transition: a 500ms fade paired with a 12%
/// upward slide, both on the curves held in [Motion]. Timings live in [Motion]
/// rather than here so tuning the app's motion stays one edit in one place, and
/// so every screen entering the same way is a rule rather than a coincidence.
///
/// Exists as a widget instead of each screen owning an [AnimationController]
/// because that boilerplate was being copied per screen: it brings a [State] it
/// otherwise does not need, and it has to re-derive the same `disableAnimations`
/// check each time.
///
/// The animation is started in a post-frame callback because starting it in
/// `initState` would set the controller's value while the tree is still
/// building. When the OS has animations switched off the child is placed
/// straight on the final frame rather than sliding in.
class RouteXScreenEntry extends StatefulWidget {
  const RouteXScreenEntry({super.key, required this.child});

  /// The screen content to animate in.
  final Widget child;

  @override
  State<RouteXScreenEntry> createState() => _RouteXScreenEntryState();
}

class _RouteXScreenEntryState extends State<RouteXScreenEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Motion.screenEntryDuration,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Motion.screenEntryFadeCurve,
    );
    _slide = Tween<Offset>(
      begin: Motion.screenEntrySlideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Motion.screenEntrySlideCurve),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
        _controller.value = 1.0;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}