// lib/features/home/presentation/widgets/quick_action_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/direction_mirror_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// One tappable shortcut in the "Quick actions" panel.
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    required this.iconPath,
    required this.label,
    required this.onTap,
    super.key,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.rowH60.w,
      child: Material(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppSizes.r8.w),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r8.w),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSizes.p16.w,
              end: AppSpacing.s14.w,
            ),
            child: Row(
              children: [
                _IconWell(iconPath: iconPath),
                SizedBox(width: AppSpacing.s12.w),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.actionLabel.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const _Chevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The bright green disc the shortcut's glyph sits in.
class _IconWell extends StatelessWidget {
  const _IconWell({required this.iconPath});

  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.iconXl.w,
      height: AppSizes.iconXl.w,
      decoration: const BoxDecoration(
        color: AppColors.brandSecondary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        iconPath,
        width: AppSizes.iconSm.w,
        height: AppSizes.iconSm.w,
        colorFilter: ColorFilter.mode(
          AppColors.textPrimary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

/// The panel's trailing chevron.
///
/// Mirrored in RTL: the source glyph points right, which is the "forward"
/// direction in English and the wrong one in Arabic.
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.icChevronRight,
      width: AppSizes.iconLg.w,
      height: AppSizes.iconLg.w,
      colorFilter: ColorFilter.mode(
        AppColors.textPrimary,
        BlendMode.srcIn,
      ),
    ).mirroredInRtl(context);
  }
}
