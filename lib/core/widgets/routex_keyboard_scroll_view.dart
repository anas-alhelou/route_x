// lib/core/widgets/routex_keyboard_scroll_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Lays a form out at its natural size and scrolls it, instead of scaling it
/// down when it does not fit.
///
/// This is the replacement for the `FittedBox(fit: BoxFit.scaleDown)` wrapper
/// the signup steps used to have. A `FittedBox` shrinks **everything** —
/// fonts, paddings, hit targets — as soon as the available height drops, which
/// is exactly what happens when the soft keyboard opens: the whole form became
/// smaller the moment the user started typing. Here the content keeps its real
/// size and the scroll view takes over, so the focused field stays visible (the
/// framework reveals the caret's rect) and a drag dismisses the keyboard.
///
/// The layout is what it was with the keyboard closed:
///  * [LayoutBuilder] still decides the `compact` flag from the available
///    height, so every screen keeps its existing compact paddings/sizes.
///  * The content is pinned to [contentWidth] (the viewport width minus
///    [horizontalPadding]) exactly as the old `SizedBox` did — a `Column` in a
///    vertical scroll view otherwise sizes itself to its widest child instead
///    of filling the width.
///  * `ConstrainedBox(minHeight: constraints.maxHeight)` keeps the viewport
///    height meaningful without stretching anything: a `Column` still hugs its
///    children, so a form that fits renders pixel-identically to the old
///    non-scrolling layout.
///
/// Note the keyboard is **not** accounted for with `viewInsets` here: every
/// host is a `Scaffold` with the default `resizeToAvoidBottomInset: true`, so
/// the body is already resized above the keyboard. Adding `viewInsets` on top
/// of that would shrink (or double-shift) the form a second time.
class RouteXKeyboardScrollView extends StatelessWidget {
  const RouteXKeyboardScrollView({
    super.key,
    required this.builder,
    this.horizontalPadding = 0,
    this.compactHeight = 680,
  });

  /// Builds the scrollable content.
  ///
  /// Receives the incoming [constraints], the resolved [isCompact] flag (and so
  /// the screen's existing compact-mode branches keep working) and the
  /// [contentWidth] the content is pinned to.
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    bool isCompact,
    double contentWidth,
  )
  builder;

  /// Horizontal inset applied to the content; the content width is derived
  /// from it, so the two can never disagree.
  final double horizontalPadding;

  /// Available height below which the content is laid out in its compact
  /// variant. The signup steps use 680; the password form uses 700.
  final double compactHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < compactHeight;
        final contentWidth = constraints.maxWidth - horizontalPadding * 2;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                (isCompact ? 8 : 12).h,
                horizontalPadding,
                (isCompact ? 8 : 12).h,
              ),
              child: SizedBox(
                width: contentWidth,
                child: builder(context, constraints, isCompact, contentWidth),
              ),
            ),
          ),
        );
      },
    );
  }
}
