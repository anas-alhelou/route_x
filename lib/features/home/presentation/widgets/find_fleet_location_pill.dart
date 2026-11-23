// lib/features/home/presentation/widgets/find_fleet_location_pill.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// The city pill on the trailing edge of the Find a Fleet top bar.
///
/// Figma 5237:3435: an 88x40 rounded rectangle, white fill inside a 1pt brand
/// green outline, holding a pin glyph and the city name 6pt apart.
///
/// Its green ring is the only place on this screen where the brand colour is
/// drawn as a border rather than a fill, which is what makes it read as a
/// location selector rather than another action.
///
/// Both dimensions are fixed tokens rather than derived from the label: a pill
/// that grew with its city name would move the pin every time the name was
/// localized and stop lining up with anything below it.
class FindFleetLocationPill extends StatelessWidget {
  const FindFleetLocationPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.pillH40.h,
      width: AppSizes.pillW88.w,
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.s12,
        AppSpacing.s8,
        AppSpacing.s14,
        AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r6.r),
        border: Border.all(color: AppColors.borderActivated),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppAssets.icPin,
            width: AppSizes.iconXs.w,
            height: AppSizes.iconXs.w,
            colorFilter: ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: AppSpacing.s6.w),
          Text(
            context.tr.findFleetCity,
            style: AppTextStyles.pillLabel.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}