import 'package:flutter/widgets.dart';

/// Direction-aware helpers for the shared RouteX UI components.
///
/// Every arrow and chevron in the design is drawn pointing right. That is a
/// statement about the Latin layout only: in Arabic the same glyph has to point
/// the other way, or a "next" affordance reads as "back". Rather than shipping a
/// mirrored copy of every icon, the widgets ask for a mirror at the point of
/// use and get the same asset back in both directions.
extension DirectionalMirror on Widget {
  /// Flips this widget horizontally when the ambient direction is RTL.
  ///
  /// Deliberately a no-op in LTR, so a caller can wrap unconditionally instead
  /// of branching on the locale at every call site.
  Widget mirroredInRtl(BuildContext context) {
    if (Directionality.of(context) != TextDirection.rtl) return this;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(-1, 1, 1),
      child: this,
    );
  }

  /// Whether the ambient direction is right-to-left.
  ///
  /// Read through this rather than `Directionality.of(context) == ...` so the
  /// comparison is spelled the same way in every widget.
  static bool isRtl(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;
}
