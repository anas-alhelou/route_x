// lib/features/settings/presentation/widgets/settings_list_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'settings_section_card.dart';

/// Row inside a settings card.
///
/// [filled] rows sit on the light brand tint with a solid icon badge (fleets,
/// privacy). Non-filled rows are outlined with an outlined badge (support).
class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.filled = true,
    this.locked = false,
  });

  final IconData? icon;

  /// Replaces the icon badge, e.g. a ready-made design-system badge.
  final Widget? leading;
  final String title;
  final String? subtitle;

  /// Short value shown before the chevron, e.g. "Always".
  final String? value;

  /// Replaces the default chevron / lock icon.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool filled;

  /// Shows a lock instead of the chevron. [onTap] still fires, so the row can
  /// explain how to unlock it.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          // Figma S01: 55dp rows — a 36dp badge with 8.5 above and below.
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.5.h),
          decoration: BoxDecoration(
            color: filled ? AppColors.iconBrand : AppColors.surfaceWhite,
            borderRadius: radius,
            border: Border.all(
              color: filled ? AppColors.brandMain : AppColors.borderDeactivated,
            ),
          ),
          child: Row(
            children: [
              leading ?? SettingsIconBadge(icon: icon, outlined: !filled),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s16Bold.copyWith(
                        fontSize: AppFonts.size16.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s12Regular.copyWith(
                          fontSize: AppFonts.size12.sp,
                          color: AppColors.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              if (value != null) ...[
                SizedBox(width: 8.w),
                Text(
                  value!,
                  style: AppTextStyles.s14Regular.copyWith(
                    fontSize: AppFonts.size14.sp,
                    color: AppColors.textGray,
                  ),
                ),
              ],
              SizedBox(width: 8.w),
              trailing ??
                  Icon(
                    locked ? Icons.lock_outline : Icons.chevron_right,
                    size: 22.r,
                    color: AppColors.textPrimary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
