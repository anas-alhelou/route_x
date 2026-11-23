// lib/core/widgets/routex_loading_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

/// Full-screen blocking overlay for the duration of an auth network request.
///
/// Auth pages used to pass `isLoading` to their submit button only, which left
/// every other control live: the text fields still accepted keystrokes, the
/// footer links still navigated and the system back gesture still popped the
/// screen while a request was in flight. This widget puts a non-dismissible
/// [ModalBarrier] over the whole page and locks the route's back gesture, so
/// the only thing left to do while loading is wait.
///
/// It does not time anything out on its own: the request budget lives in
/// `ApiTimeouts.requestTimeout`, and the resulting failure (now surfaced as a
/// dialog, not a SnackBar) is raised by the page's own bloc listener, which is
/// what takes the page out of its loading state and removes this overlay.
///
/// Every page that talks to the API wraps its body in this widget, so any new
/// one gets the identical busy state without re-deriving it. Wrap the body
/// rather than placing this as a sibling — [Stack] children paint in order, so
/// an overlay listed first ends up *behind* the content it is meant to cover.
class RouteXLoadingOverlay extends StatefulWidget {
  const RouteXLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  /// Whether a request is currently in flight.
  final bool isLoading;

  /// The page content rendered underneath the overlay.
  final Widget child;

  @override
  State<RouteXLoadingOverlay> createState() => _RouteXLoadingOverlayState();
}

class _RouteXLoadingOverlayState extends State<RouteXLoadingOverlay> {
  /// Edge length of the blocking spinner.
  static const double _spinnerSize = 40;

  /// Spinner stroke width, matching the in-button spinner.
  static const double _spinnerStroke = 2.5;

  /// How much of the page the scrim hides while loading. The scrim is the
  /// theme's white surface (dark card colour in dark mode), not black.
  static const double _scrimOpacity = 0.92;

  @override
  void didUpdateWidget(RouteXLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A text field keeps its focus (and the keyboard with it) behind the
    // barrier otherwise, so dismissing it is part of blocking input.
    if (!oldWidget.isLoading && widget.isLoading) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isLoading,
      child: Stack(
        // Passthrough so the barrier spans the whole page even when the content
        // it wraps is shorter than the screen.
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (widget.isLoading) ...[
            Positioned.fill(
              // `dismissible: false` makes this a pure blocker: the barrier's
              // opaque box absorbs every pointer aimed at the page beneath it.
              child: ModalBarrier(
                dismissible: false,
                color: AppColors.surfaceWhite.withValues(alpha: _scrimOpacity),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: _spinnerSize.w,
                    height: _spinnerSize.w,
                    child: CircularProgressIndicator(
                      color: AppColors.brandMain,
                      strokeWidth: _spinnerStroke,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
