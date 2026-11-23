import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

/// ----------------------------------------------------------------
/// Status mark states corresponding to the 3 Figma variants.
/// Note: We used 'initial' instead of 'default' because 'default'
/// is a reserved keyword in Dart.
/// ----------------------------------------------------------------
enum StatusMarkState {
  /// Property 1 = Default (Empty circle with a grey border)
  initial,

  /// Property 1 = Active (Green circle with a checkmark)
  active,

  /// Property 1 = Error (Red circle with an exclamation mark)
  error,
}

/// ----------------------------------------------------------------
/// A core shared widget to display general status marks.
/// Fully responsive using [flutter_screenutil].
/// ----------------------------------------------------------------
class StatusMarkIndicator extends StatelessWidget {
  final StatusMarkState state;
  final double size;

  const StatusMarkIndicator({
    super.key,
    required this.state,
    this.size = 24.0, // Default size for status marks
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Using .w for both width and height to keep it a perfect circle
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // 1. Set background color based on state
        color: _getBackgroundColor(),

        // 2. Add a border ONLY for the initial (Default) state
        border: state == StatusMarkState.initial
            ? Border.all(
                color: AppColors.borderDeactivated,
                width: 2.w, // Responsive border thickness
              )
            : null,
      ),
      // 3. Render the appropriate inner icon
      child: _buildIcon(),
    );
  }

  /// Returns the appropriate background color based on the current state.
  Color _getBackgroundColor() {
    switch (state) {
      case StatusMarkState.active:
        return AppColors.success;
      case StatusMarkState.error:
        return AppColors.error;
      case StatusMarkState.initial:
        return Colors.transparent; // Transparent for the default outlined state
    }
  }

  /// Returns the inner icon or null if the state is initial.
  Widget? _buildIcon() {
    switch (state) {
      case StatusMarkState.active:
        return Icon(
          Icons.check_rounded,
          color: AppColors.brandWhite,
          size: (size * 0.7).sp,
        );
      case StatusMarkState.error:
        return Icon(
          // Icons.priority_high is the standard Material exclamation mark (!)
          Icons.priority_high_rounded,
          color: AppColors.brandWhite,
          size: (size * 0.65)
              .sp, // Slightly smaller to fit nicely inside the circle
        );
      case StatusMarkState.initial:
        // Return null because the Default variant has no inner element
        return null;
    }
  }
}
