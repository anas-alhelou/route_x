// lib/features/route_fleet/presentation/widgets/declined_status_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class DeclinedStatusCard extends StatelessWidget {
  const DeclinedStatusCard({
    super.key,
    required this.fleetName,
    required this.reason,
    required this.onChooseAnotherFleet,
    required this.onUpdateVehicle,
  });

  final String fleetName;
  final String reason;
  final VoidCallback onChooseAnotherFleet;
  final VoidCallback onUpdateVehicle;

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
          // REQUEST DECLINED Tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.errorRed,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.close_rounded, size: 13, color: AppColors.brandWhite),
                SizedBox(width: 6.w),
                Text(
                  context.tr.routeRequestDeclinedCaps,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceWhite,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            context.tr.routeFleetDeclinedYou(fleetName),
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlack,
              height: 1.25,
            ),
          ),
          SizedBox(height: 16.h),

          // Reason Card
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.slateSurface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.slateBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.routeReasonFromDispatcherCaps,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.slateMuted,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  reason,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.brandBlack,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Primary Button: Choose another fleet
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: onChooseAnotherFleet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF84E300),
                foregroundColor: AppColors.brandBlack,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr.routeChooseAnotherFleet,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.brandBlack),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Secondary Outlined Button: Update vehicle & retry
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: onUpdateVehicle,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: AppColors.brandBlack,
                side: BorderSide(color: AppColors.slateBorder, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr.routeUpdateVehicleRetry,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.brandBlack),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
