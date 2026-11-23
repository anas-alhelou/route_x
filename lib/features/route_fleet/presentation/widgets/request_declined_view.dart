// lib/features/route_fleet/presentation/widgets/request_declined_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';

class RequestDeclinedView extends StatelessWidget {
  const RequestDeclinedView({super.key, required this.fleetName, required this.reason});
  final String fleetName;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Status Badge ──────────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.redPale4,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: AppColors.errorRedDeep,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      context.tr.routeRequestDeclinedCaps,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.errorRedDeep,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                context.tr.routeFleetDeclinedYou(fleetName),
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlack,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16.h),

              // Reason Container
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.redPale5,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.redBorder3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.errorRedDeep, size: 18),
                        SizedBox(width: 8.w),
                        Text(
                          context.tr.routeReasonFromDispatcher,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.errorRedDeep,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      reason,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.brandBlack,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Recommendation Banner
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.limePale2,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: Color(0xFF8CE600), size: 24),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr.routeLookingForFleets,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.brandBlack),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            context.tr.routeOtherFleetsMatch,
                            style: TextStyle(fontSize: 12.sp, color: AppColors.grey666),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => context.read<RouteFleetCubit>().goToFindFleet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CE600),
                    foregroundColor: AppColors.brandBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr.routeFindAnotherFleet,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () => context.read<RouteFleetCubit>().goToNoFleet(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandBlack,
                    side: BorderSide(color: AppColors.lineLight2, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: Text(
                    context.tr.routeUpdateMyVehicle,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
