// lib/features/main_layout/presentation/widgets/custom_bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a single nav-bar item.
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({required this.label, required this.assetPath});

  final String label;
  final String assetPath;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab definitions — matches Figma: Home · Route · Orders · Settings
// ─────────────────────────────────────────────────────────────────────────────
List<_NavItem> _navItems(BuildContext context) => [
  _NavItem(label: context.tr.navHomeLabel, assetPath: AppAssets.icNavHome),
  _NavItem(label: context.tr.navRouteLabel, assetPath: AppAssets.icNavRoute),
  _NavItem(label: context.tr.ordersTitle, assetPath: AppAssets.icNavOrder),
  _NavItem(label: context.tr.settingsTitle, assetPath: AppAssets.icNavSettings),
];

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Floating capsule bottom navigation bar — Figma "BottomNav light / Home
/// active" (component set 4831:4474) on the 412×917 Home canvas.
///
/// Design specs:
/// - Capsule: 360×70 on the 412 canvas → side gutter 26, height 70, radius 45.
/// - Sits 32pt above the screen bottom (on top of the safe-area inset).
/// - Padding 8 on every edge; hairline stroke #D9D9D9.
/// - Fill #FDFDFD; drop shadow offset (0, 8), blur 24, #212121 @ 10%.
/// - Active tab: filled pill 60×40, radius 20, #222222, white glyph.
/// - Inactive tab: unfilled 36×36 well, radius ~18, gray glyph.
/// - Label: Satoshi 12 — Bold (700) when active, Medium (500) when not;
///   line box 10.5px. Active label #222222, inactive #737373.
class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final navItems = _navItems(context);

    final containerBg = isDark
        ? AppColors.surfaceWhite
        : AppColors.brandBackground;
    final strokeColor = AppColors.borderSubtle;
    final activePillColor = AppColors.brandBlack;
    final activeIconColor = isDark ? AppColors.onBrand : AppColors.brandWhite;
    final selectedTextColor = AppColors.brandBlack;
    final unselectedTextColor = AppColors.textNavUnselected;

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        // 26pt side gutters + 32pt bottom gap on the 412 canvas (Figma).
        padding: EdgeInsets.fromLTRB(
          AppSizes.bottomNavSideGutter.w,
          0,
          AppSizes.bottomNavSideGutter.w,
          AppSizes.bottomNavBottomGap.h,
        ),
        child: Container(
          height: AppSizes.bottomNavH.h,
          padding: EdgeInsets.all(AppSizes.bottomNavPad.h),
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(AppSizes.bottomNavRadius.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowStrong.withValues(alpha: 0.10),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          // Stroke as foreground so it does not inset the children: a
          // BoxDecoration border would eat 1px top + 1px bottom and push the
          // 40+3+11 tab column past the 54px inner height (2px overflow).
          // Figma draws the stroke INSIDE the capsule.
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.bottomNavRadius.r),
            border: Border.all(
              color: strokeColor,
              width: AppSizes.bottomNavStroke,
            ),
          ),
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: _NavTabItem(
                  item: item,
                  isActive: isActive,
                  reduceMotion: reduceMotion,
                  activePillColor: activePillColor,
                  activeIconColor: activeIconColor,
                  selectedTextColor: selectedTextColor,
                  unselectedTextColor: unselectedTextColor,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: individual nav tab item
// ─────────────────────────────────────────────────────────────────────────────
class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.item,
    required this.isActive,
    required this.reduceMotion,
    required this.activePillColor,
    required this.activeIconColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final bool reduceMotion;
  final Color activePillColor;
  final Color activeIconColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? activeIconColor : unselectedTextColor;
    final textColor = isActive ? selectedTextColor : unselectedTextColor;

    // Active: filled 60×40 pill. Inactive: unfilled 36×36 well.
    final wellW = isActive
        ? AppSizes.bottomNavWellActiveW
        : AppSizes.bottomNavWellInactive;
    final wellH = isActive
        ? AppSizes.bottomNavWellActiveH
        : AppSizes.bottomNavWellInactive;

    final animDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 250);

    return Semantics(
      button: true,
      selected: isActive,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: animDuration,
              curve: Curves.fastOutSlowIn,
              width: wellW.w,
              height: wellH.h,
              decoration: BoxDecoration(
                color: isActive ? activePillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  (isActive
                          ? AppSizes.bottomNavWellRadius
                          : AppSizes.bottomNavWellRadius - 2)
                      .r,
                ),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isActive && !reduceMotion ? 1.08 : 1.0,
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Image.asset(
                    item.assetPath,
                    width: AppSizes.bottomNavIcon.w,
                    height: AppSizes.bottomNavIcon.h,
                    color: iconColor,
                    colorBlendMode: BlendMode.srcIn,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Figma: 3px gap between the well and the label row.
            SizedBox(height: 3.h),
            Flexible(
              child: SizedBox(
                height: AppSizes.bottomNavLabelH.h,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: animDuration,
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 12.sp,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                      // Figma line box is 10.5px on a 12px face.
                      height: 10.5 / 12,
                      letterSpacing: 0,
                    ),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
