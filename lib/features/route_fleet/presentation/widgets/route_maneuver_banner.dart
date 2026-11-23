import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../controllers/route_fleet_state.dart';

class RouteManeuverBanner extends StatelessWidget {
  const RouteManeuverBanner({
    super.key,
    required this.distanceValue,
    required this.distanceUnit,
    required this.instructionText,
    this.nextStepText,
    required this.maneuverType,
  });

  final String distanceValue;
  final String distanceUnit;
  final String instructionText;
  final String? nextStepText;
  final ManeuverType maneuverType;

  @override
  Widget build(BuildContext context) {
    final hasNextStep = nextStepText != null && nextStepText!.isNotEmpty;

    String iconAsset = AppAssets.routeIcTurnLeft;
    if (maneuverType == ManeuverType.arrive) {
      iconAsset = AppAssets.routeIcArrive;
    }

    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Maneuver Strip
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 60x60 Lime Tile with 16.r radius holding 36x36 icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.brandMain,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconAsset,
                      width: 36.w,
                      height: 36.h,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                // Text Block (Distance + Instruction)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Distance Number + Unit
                      RichText(
                        text: TextSpan(
                          text: distanceValue,
                          style: TextStyle(
                            fontFamily: AppFonts.fontFamilySatoshi,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: AppColors.brandBlack,
                          ),
                          children: [
                            TextSpan(
                              text: ' $distanceUnit',
                              // Figma: unit "m" is 14 Medium #737373
                              style: AppTextStyles.s14Medium145.copyWith(color: AppColors.textBody),
                            ),
                          ],
                        ),
                      ),
                      // Instruction Street Name (Figma: 16 Medium, line height 145%)
                      Text(
                        instructionText,
                        style: AppTextStyles.s16Medium145.copyWith(color: AppColors.brandBlack),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Secondary "Then" Strip (Optional)
          if (hasNextStep) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.canvas, // #F5F6F2
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppSizes.r24),
                  bottomRight: Radius.circular(AppSizes.r24),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  Text(
                    context.tr.routeThen,
                    style: AppTextStyles.s12Medium145.copyWith(color: AppColors.textBody),
                  ),
                  SizedBox(width: 8.w),
                  SvgPicture.asset(
                    AppAssets.routeIcPin,
                    width: 16.w,
                    height: 16.h,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      nextStepText!,
                      style: AppTextStyles.s12Medium145.copyWith(color: AppColors.brandBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
