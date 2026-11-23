import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class RouteMapControls extends StatelessWidget {
  const RouteMapControls({
    super.key,
    required this.onOverviewTapped,
    this.onStopsTapped,
    this.onHelpTapped,
  });

  final VoidCallback onOverviewTapped;
  final VoidCallback? onStopsTapped;
  final VoidCallback? onHelpTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Overview Button (48x48)
        _ControlButton(
          iconAsset: AppAssets.routeIcOverview,
          onTap: onOverviewTapped,
        ),
        if (onStopsTapped != null) ...[
          SizedBox(height: 10.h),
          // Stops List Button (48x48)
          _ControlButton(
            iconAsset: AppAssets.routeIcStops,
            onTap: onStopsTapped!,
          ),
        ],
        if (onHelpTapped != null) ...[
          SizedBox(height: 10.h),
          // Help "?" Button (48x48) -> R31
          _ControlButton(
            icon: SvgPicture.asset(AppAssets.routeIcHelp, width: 24.w, height: 24.h, colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn)),
            onTap: onHelpTapped!,
          ),
        ],
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    this.iconAsset,
    this.icon,
    required this.onTap,
  }) : assert(iconAsset != null || icon != null);

  final String? iconAsset;
  final Widget? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
          boxShadow: AppTextStyles.mapControlShadow,
        ),
        child: Center(
          child: icon ??
              SvgPicture.asset(
                iconAsset!,
                width: 22.w,
                height: 22.h,
              ),
        ),
      ),
    );
  }
}
