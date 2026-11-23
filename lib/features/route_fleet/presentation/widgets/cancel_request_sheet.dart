// lib/features/route_fleet/presentation/widgets/cancel_request_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';

class CancelRequestSheet extends StatelessWidget {
  const CancelRequestSheet({super.key, required this.fleetName});
  final String fleetName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Drag Handle Indicator
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Top Error Request Icon (Width 72.0px, Height 72.0px)
          Center(
            child: Image.asset(
              AppAssets.icErrorRequest,
              width: 72.w,
              height: 72.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: AppColors.redPale,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: AppColors.errorRedDark,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Main Title: "Cancel your request to {Fleet Name}?"
          Text(
            context.tr.routeCancelYourRequestTo(fleetName),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              height: 26 / 20,
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 8.h),

          // Description Hint Text
          Text(
            context.tr.routeCancelRequestBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: AppColors.slateMuted,
            ),
          ),
          SizedBox(height: 28.h),

          // Primary Destructive Button ("Cancel request")
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => context.read<RouteFleetCubit>().confirmCancelRequest(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redPale2,
                foregroundColor: AppColors.errorRedDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  side: BorderSide(color: AppColors.redBorder2, width: 1.0),
                ),
              ),
              child: Text(
                context.tr.routeCancelRequest,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.errorRedDark,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Secondary Neutral Button ("Keep my request")
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: OutlinedButton(
              onPressed: () => context.read<RouteFleetCubit>().closeCancelRequestSheet(),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: AppColors.slateInk,
                elevation: 0,
                side: BorderSide(color: AppColors.slateBorder, width: 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                context.tr.routeKeepMyRequest,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateInk,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
