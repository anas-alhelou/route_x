// lib/features/settings/presentation/widgets/settings_page_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// Back arrow followed by a title and a gray subtitle, used at the top of the
/// pages opened from settings (edit profile, vehicle).
class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.framedBack = false,
  });

  final String title;
  final String subtitle;

  /// Draws the back arrow inside an outlined circle (read-only pages).
  final bool framedBack;

  @override
  Widget build(BuildContext context) {
    final arrow = Icon(
      Icons.arrow_back,
      size: framedBack ? 22.r : 26.r,
      color: AppColors.textPrimary,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (framedBack)
          Material(
            color: AppColors.surfaceWhite,
            shape: CircleBorder(
              side: BorderSide(color: AppColors.surfaceEmpty),
            ),
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              customBorder: const CircleBorder(),
              child: SizedBox(width: 44.r, height: 44.r, child: arrow),
            ),
          )
        else
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: arrow,
          ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.s24Bold.copyWith(
                  fontSize: AppFonts.size24.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.s14Regular.copyWith(
                  fontSize: AppFonts.size14.sp,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
