// lib/features/app_permissions/presentation/widgets/permission_indicator_dots.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

class PermissionIndicatorDots extends StatelessWidget {
  const PermissionIndicatorDots({
    super.key,
    required this.currentIndex,
    this.itemCount = 3,
  });

  final int currentIndex;
  final int itemCount;

  // Figma carousel-dot fills (not part of the shared palette).
  static const Color _activeColor = AppColors.brandMain;
  static Color get _inactiveColor => AppColors.lineLight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4), // 8 gap between dots
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? _activeColor : _inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
