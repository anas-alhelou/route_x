import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_logo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

class NavigateWithSheet extends StatelessWidget {
  const NavigateWithSheet({
    super.key,
    required this.customerName,
    required this.selectedApp,
    required this.alwaysUseApp,
    required this.availableApps,
    required this.onAppSelected,
    required this.onAlwaysUseChanged,
    required this.onStartDirectionsTapped,
  });

  final String customerName;
  final MapAppOption selectedApp;
  final bool alwaysUseApp;
  final List<MapAppOption> availableApps;
  final ValueChanged<MapAppOption> onAppSelected;
  final ValueChanged<bool> onAlwaysUseChanged;
  // TODO: Navigate to R10 (Driving screen)
  final VoidCallback onStartDirectionsTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr.routeNavigateWith,
                  style: AppTextStyles.s20Bold125.copyWith(color: AppColors.brandBlack),
                ),
                SizedBox(height: 4.h),
                Text(
                  context.tr.routePickDirections(customerName),
                  style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // 2. Apps list
            Column(
              mainAxisSize: MainAxisSize.min,
              children: availableApps.map((app) {
                final isSelected = app == selectedApp;
                String name = 'RouteX';
                String desc = context.tr.routeTurnByTurnInApp;
                Widget logoWidget = SvgPicture.asset(
                  AppAssets.icLogo,
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.contain,
                  colorMapper: const RouteXLogoColorMapper(),
                );

                if (app == MapAppOption.googleMaps) {
                  name = 'Google Maps';
                  desc = context.tr.routeOpensOneStop;
                  logoWidget = SvgPicture.asset(
                    AppAssets.logoGoogleMaps,
                    width: 20.w,
                    height: 20.h,
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: InkWell(
                    onTap: () => onAppSelected(app),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.sliderProgressFill : AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        border: Border.all(
                          color: isSelected ? AppColors.brandMain : AppColors.borderDeactivated,
                          width: isSelected ? 2.w : 1.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(AppSizes.r12),
                              border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
                            ),
                            child: Center(child: logoWidget),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: AppTextStyles.s14Bold14.copyWith(color: AppColors.brandBlack),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  desc,
                                  style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          SvgPicture.asset(
                            isSelected ? AppAssets.radioOn : AppAssets.radioOff,
                            width: 22.w,
                            height: 22.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 6.h),

            // 3. Always use this app row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.tr.routeAlwaysUseApp,
                  style: AppTextStyles.s14Medium145.copyWith(color: AppColors.brandBlack),
                ),
                _CustomSwitch(
                  value: alwaysUseApp,
                  onChanged: onAlwaysUseChanged,
                  activeTrackColor: AppColors.brandMain,
                  inactiveTrackColor: AppColors.deactivatedBadge,
                  thumbColor: AppColors.brandWhite,
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // 4. Hand-off note
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(AppSizes.r12),
                border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppAssets.routeIcNote,
                    width: 16.w,
                    height: 16.h,
                    colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      context.tr.routeComeBackToMark,
                      style: AppTextStyles.s12Regular145.copyWith(color: AppColors.brandBlack),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // 5. Start directions button (Target: R10)
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMain,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                onPressed: onStartDirectionsTapped,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.routeIcNavigate,
                      width: 22.w,
                      height: 22.h,
                      colorFilter: ColorFilter.mode(AppColors.onBrand, BlendMode.srcIn),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr.routeStartDirections,
                      style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomSwitch extends StatelessWidget {
  const _CustomSwitch({
    required this.value,
    required this.onChanged,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    required this.thumbColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color thumbColor;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: value ? activeTrackColor : inactiveTrackColor,
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 26.w,
          height: 26.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: thumbColor,
            boxShadow: AppTextStyles.switchThumbShadow,
          ),
        ),
      ),
    );
  }
}
