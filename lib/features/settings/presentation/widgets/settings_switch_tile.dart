// lib/features/settings/presentation/widgets/settings_switch_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'settings_section_card.dart';

/// Tinted, green-outlined row with an icon badge, a title, an optional
/// subtitle and a [trailing] widget. Base of [SettingsSwitchTile].
class SettingsOptionTile extends StatelessWidget {
  const SettingsOptionTile({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData? icon;

  /// Replaces the icon badge, e.g. a ready-made design-system badge.
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 10.h),
          decoration: BoxDecoration(
            color: AppColors.iconBrand,
            borderRadius: radius,
            border: Border.all(color: AppColors.brandMain),
          ),
          child: Row(
            children: [
              leading ?? SettingsIconBadge(icon: icon),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.s16Bold.copyWith(
                        fontSize: AppFonts.size16.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTextStyles.s12Regular.copyWith(
                          fontSize: AppFonts.size12.sp,
                          color: AppColors.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8.w),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// [SettingsOptionTile] with a brand switch; tapping the row toggles it.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsOptionTile(
      icon: icon,
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        thumbColor: const WidgetStatePropertyAll(AppColors.brandWhite),
        // Material 3 shrinks the thumb when off unless it has an icon; an
        // empty icon keeps it the same size in both states.
        thumbIcon: const WidgetStatePropertyAll(Icon(null)),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brandMain
              : AppColors.textGray,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
