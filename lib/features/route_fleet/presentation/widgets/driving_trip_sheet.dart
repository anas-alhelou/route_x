import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/utils/external_launcher.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/route_stop.dart';

class DrivingTripSheet extends StatelessWidget {
  const DrivingTripSheet({
    super.key,
    required this.currentStop,
    required this.stopIndex,
    required this.arrivalTime,
    required this.remainingMinutes,
    required this.remainingKm,
    this.isTappable = true,
    required this.onNavigateTapped,
    this.onStopDetailsTapped,
  });

  final RouteStop currentStop;
  final int stopIndex;
  final String arrivalTime;
  final int remainingMinutes;
  final double remainingKm;
  final bool isTappable;
  final VoidCallback onNavigateTapped;
  final VoidCallback? onStopDetailsTapped;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isTappable ? onNavigateTapped : null,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Three Stat Columns per R10 spec section 4 (equal width, left-aligned)
                Row(
                  children: [
                    // Column 1: ETA in Lime + "arrival" caption
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            arrivalTime,
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.24,
                              color: AppColors.brandMain, // Lime #8FE600
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            context.tr.routeArrival,
                            style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
                          ),
                        ],
                      ),
                    ),

                    // Column 2: Time in Bold 18 (centered vertically, no caption)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr.routeMinutesShort(remainingMinutes.toString()),
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: AppColors.brandBlack,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Column 3: Distance in Bold 18 (centered vertically, no caption)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr.routeKmShort(remainingKm.toStringAsFixed(1)),
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: AppColors.brandBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Divider
                Divider(color: AppColors.borderDeactivated, height: 1),
                SizedBox(height: 14.h),

                // 2. Current Stop Row with 2 Circle Buttons (44x44 each)
                InkWell(
                  onTap: onStopDetailsTapped,
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Figma: 36x36 lime circle, number 16 Bold
                        Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.brandMain,
                          ),
                          child: Center(
                            child: Text(
                              '$stopIndex',
                              style: AppTextStyles.s16Bold.copyWith(color: AppColors.onBrand),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentStop.title,
                                style: AppTextStyles.s14Bold14.copyWith(color: AppColors.brandBlack),
                              ),
                              Text(
                                '${currentStop.address}${currentStop.orderId != null ? ' · ${currentStop.orderId}' : ''}',
                                style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // 8 (not Figma's 12) so the address "· #RX-1039" is not cut with "…"
                        SizedBox(width: 8.w),

                        // Circle Call Button (44x44, filled #E9E9E9, no border)
                        InkWell(
                          onTap: () => ExternalLauncher.call(currentStop.phone),
                          borderRadius: BorderRadius.circular(22.r),
                          child: Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.deactivatedBadge, // #E9E9E9
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppAssets.routeIcCall,
                                width: 24.w,
                                height: 24.h,
                                colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Circle Navigate Button (44x44, filled #8FE600)
                        InkWell(
                          onTap: onNavigateTapped,
                          borderRadius: BorderRadius.circular(22.r),
                          child: Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.brandMain, // #8FE600
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppAssets.routeIcNavigate,
                                width: 24.w,
                                height: 24.h,
                                colorFilter: ColorFilter.mode(AppColors.onBrand, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
