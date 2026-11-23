// lib/features/settings/presentation/widgets/settings_section_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// White rounded card used by every block of the settings screen.
///
/// When [title] is given it is rendered above [children], which are stacked
/// with [spacing] between them.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.spacing = 11,
    this.padding,
  });

  final String? title;

  /// Gray line under [title]; ignored without a title.
  final String? subtitle;
  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Figma S01: rows sit 12 from the card edge, the title 16.
      padding: padding ?? EdgeInsets.fromLTRB(12.r, 16.r, 12.r, 12.r),
      decoration: settingsCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsetsDirectional.only(start: 4.w),
              child: Text(
                title!,
                style: AppTextStyles.s20Bold.copyWith(
                  fontSize: AppFonts.size20.sp,
                  height: 1.15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: EdgeInsetsDirectional.only(start: 4.w),
                child: Text(
                  subtitle!,
                  style: AppTextStyles.s14Regular.copyWith(
                    fontSize: AppFonts.size14.sp,
                    color: AppColors.textGray,
                  ),
                ),
              ),
            SizedBox(height: 10.h),
          ],
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.h),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Shared decoration for the outlined white settings cards.
BoxDecoration settingsCardDecoration({double radius = 24}) {
  return BoxDecoration(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(radius.r),
    border: Border.all(color: AppColors.borderDeactivated.withValues(alpha: 0.6)),
    boxShadow: [
      BoxShadow(
        color: AppColors.brandBlack.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// Round icon badge on the brand color, used as the leading icon of tiles.
///
/// Shows [svg] when given (design-system icons drawn in the dark brand color),
/// otherwise the Material [icon].
class SettingsIconBadge extends StatelessWidget {
  const SettingsIconBadge({
    super.key,
    this.icon,
    this.svg,
    this.size = 36,
    this.outlined = false,
  }) : assert(icon != null || svg != null, 'Give an icon or an svg');

  final IconData? icon;
  final SvgGenImage? svg;
  final double size;

  /// Outlined badges (white fill, gray border) are used by the support rows.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    // Material glyphs fill half the badge. Design-system SVGs are drawn in a
    // 20 px frame for the 36 px badge (padding included), so they keep that
    // ratio instead.
    final glyph = (size * (svg != null ? 20 / 36 : 0.5)).r;
    return Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outlined ? AppColors.surfaceWhite : AppColors.brandMain,
        border: outlined ? Border.all(color: AppColors.borderDeactivated) : null,
      ),
      child: svg != null
          ? svg!.svg(width: glyph, height: glyph)
          : Icon(icon, size: glyph, color: AppColors.textPrimary),
    );
  }
}
