// lib/features/route_fleet/presentation/widgets/off_shift_status_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class OffShiftStatusCard extends StatelessWidget {
  const OffShiftStatusCard({
    super.key,
    required this.fleetName,
    required this.onStartShift,
  });

  final String fleetName;
  final VoidCallback onStartShift;

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
          // OFF SHIFT Tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.slatePale,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.slateMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  context.tr.routeOffShiftCaps,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slateMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            context.tr.routeYoureOffShift,
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
            context.tr.routeOffShiftBody(fleetName),
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.slateMuted,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),

          // Primary Button: Start shift
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: onStartShift,
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
                    context.tr.routeStartShift,
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
