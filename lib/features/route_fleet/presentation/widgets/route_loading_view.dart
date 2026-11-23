import 'package:routex_mobile/core/utils/map_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_skeleton.dart';

// Figma R00 puck: accuracy ring 64 (14%), white base 34, plain blue dot 20 (no heading arrow).
class _LoadingDriverPuck extends StatelessWidget {
  const _LoadingDriverPuck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.routeAccuracyFill.withValues(alpha: 0.14),
      ),
      child: Center(
        child: Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceWhite,
            boxShadow: AppTextStyles.puckBaseShadow,
          ),
          child: Center(
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.routeAccuracyFill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RouteLoadingView extends StatelessWidget {
  const RouteLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Bottom clearance = nav bottom padding (32.h) + nav height (64.h) + 16.h gap + bottom safe area inset
    final bottomClearance =
        bottomInset + AppSizes.navBottomPadding.h + AppSizes.navHeight.h + 16.h;

    return Scaffold(
      backgroundColor: AppColors.canvas, // #F5F6F2
      body: Stack(
        children: [
          // 0. Map background (Figma R00 "World") with the driver puck at (254, 453) 64 x 64
          Positioned.fill(
            child: IgnorePointer(
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(
                    21.5380,
                    39.1680,
                  ), // TEMP: until real GPS is wired
                  initialZoom: 14.0,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.routex.routex_mobile',
                    tileBuilder: themedTileBuilder,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 254.w,
            top: 453.h,
            child: const _LoadingDriverPuck(),
          ),

          // 1. Route summary skeleton: position (16, 64), 200 x 40, fully rounded (r100), fill #D0D0D0
          Positioned(
            left: 16.w,
            top: 64.h,
            child: RouteXSkeleton.block(
              width: 200.w,
              height: 40.h,
              radius: AppSizes.r100,
            ),
          ),

          // 2. Trip sheet: anchored relative to bottom nav (exact 16px gap above nav top)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomClearance,
            child: Center(
              child: SizedBox(
                width: 360.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brandBackground, // #FDFDFD
                    borderRadius: BorderRadius.circular(AppSizes.r24.r),
                    border: Border.all(
                      color: AppColors.borderDeactivated, // #D0D0D0
                      width: 1.w,
                    ),
                    boxShadow: AppTextStyles.tripSheetShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // a. Title row: 310 x 25, skeleton bar 178 x 14 at top offset 6, radius 6
                        SizedBox(
                          width: 310.w,
                          height: 25.h,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: RouteXSkeleton.line(
                                width: 178.w,
                                height: 14.h,
                                radius: AppSizes.r6,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // b. Subtitle row: 310 x 17, skeleton bar 280.8 x 8, radius 6, top offset 5
                        SizedBox(
                          width: 310.w,
                          height: 17.h,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: RouteXSkeleton.line(
                                width: 280.8.w,
                                height: 8.h,
                                radius: AppSizes.r6,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // c. Stops list (310 x 171): three rows, each 310 x 57, vertical padding 10, horizontal gap 12, items centered
                        SizedBox(
                          width: 310.w,
                          height: 171.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStopRow(
                                nameWidth: 96.w,
                                addressWidth: 86.w,
                                timeWidth: 34.w,
                              ),
                              _buildStopRow(
                                nameWidth: 68.w,
                                addressWidth: 102.w,
                                timeWidth: 32.w,
                              ),
                              _buildStopRow(
                                nameWidth: 69.w,
                                addressWidth: 152.w,
                                timeWidth: 30.w,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // d. Button skeleton: 310 x 64, fully rounded (radius 32)
                        RouteXSkeleton.block(
                          width: 310.w,
                          height: 64.h,
                          radius: 32.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopRow({
    required double nameWidth,
    required double addressWidth,
    required double timeWidth,
  }) {
    return Container(
      width: 310.w,
      height: 57.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circle skeleton 32 x 32 (radius 16)
          RouteXSkeleton.circle(size: 32.r),
          SizedBox(width: 12.w),

          // Flexible text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name line (box height 20, bar height 10, top offset 5)
                SizedBox(
                  height: 20.h,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 5.h),
                      child: RouteXSkeleton.line(
                        width: nameWidth,
                        height: 10.h,
                        radius: AppSizes.r6,
                      ),
                    ),
                  ),
                ),
                // Address line (box height 17, bar height 8, top offset 4.5)
                SizedBox(
                  height: 17.h,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.5.h),
                      child: RouteXSkeleton.line(
                        width: addressWidth,
                        height: 8.h,
                        radius: AppSizes.r6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Time skeleton at the right end (box height 17, bar height 8, top offset 5, radius 6)
          SizedBox(
            height: 17.h,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: RouteXSkeleton.line(
                  width: timeWidth,
                  height: 8.h,
                  radius: AppSizes.r6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
