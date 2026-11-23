// lib/features/route_fleet/presentation/widgets/on_shift_waiting_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class OnShiftWaitingCard extends StatelessWidget {
  const OnShiftWaitingCard({
    super.key,
    required this.onEndShift,
  });

  final VoidCallback onEndShift;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ON SHIFT Tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.greenPale,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  context.tr.routeOnShiftCaps,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnlineGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            context.tr.routeWaitingFirstRoute,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlack,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6.h),

          // Subtext
          Text(
            context.tr.routeDispatchAssignsRoutes,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.slateMuted,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),

          // Info Grid Cards (2 columns)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.slateSurface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.slateBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.alt_route_rounded, size: 22, color: AppColors.slateMuted),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr.routeZeroStops,
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandBlack,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            context.tr.routeSoFarToday,
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.slateMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.slateSurface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.slateBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active_rounded, size: 22, color: AppColors.slateMuted),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr.routeAlertsOn,
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandBlack,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            context.tr.routeSoundAndVibrate,
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.slateMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Outlined Button: End shift
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: onEndShift,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: AppColors.brandBlack,
                side: BorderSide(color: AppColors.slateBorder, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.nightlight_round, size: 18, color: AppColors.brandBlack),
                  SizedBox(width: 8.w),
                  Text(
                    context.tr.routeEndShift,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
