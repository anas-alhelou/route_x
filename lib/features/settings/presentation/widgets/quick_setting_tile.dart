// lib/features/settings/presentation/widgets/quick_setting_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'settings_section_card.dart';

/// One cell of the "Quick settings" grid: icon badge, current [value] and the
/// setting's [label] underneath.
class QuickSettingTile extends StatelessWidget {
  const QuickSettingTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: settingsCardDecoration(),
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SettingsIconBadge(icon: icon, size: 40),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 22.r, color: AppColors.textPrimary),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s20Bold.copyWith(
                  fontSize: AppFonts.size20.sp,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s14Regular.copyWith(
                  fontSize: 13.sp,
                  height: 1.3,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
