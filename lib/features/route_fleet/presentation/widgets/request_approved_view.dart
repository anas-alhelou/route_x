// lib/features/route_fleet/presentation/widgets/request_approved_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/custom_button.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';

class RequestApprovedView extends StatelessWidget {
  const RequestApprovedView({super.key, required this.fleetName});
  final String fleetName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Navigation & Back Button ───────────────────────────
              GestureDetector(
                onTap: () => context.read<RouteFleetCubit>().goToNoFleet(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h, bottom: 0.h),
                  child: Icon(Icons.arrow_back, color: AppColors.brandBlack, size: 28),
                ),
              ),

              // 20.0px vertical margin / gap between Back Button and APPROVED badge
              SizedBox(height: 20.h),

              // ── 2. Status Badge (APPROVED) ──────────────────────────────
              // Dimensions: Width 141.0px, Height 25.0px, Radius 3.0px, Background: AppColors.brandSecondary (#9BEF00)
              Container(
                width: 141.w,
                height: 25.h,
                decoration: BoxDecoration(
                  color: AppColors.brandSecondary,
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 13, color: AppColors.brandWhite),
                    SizedBox(width: 6.w),
                    Text(
                      context.tr.routeApprovedCaps,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surfaceWhite,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ── 3. Title & Subtitle Typography ──────────────────────────
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(
                      text: context.tr.routeYoureInAt,
                      style: TextStyle(color: AppColors.slateInk),
                    ),
                    TextSpan(
                      text: fleetName,
                      style: const TextStyle(color: Color(0xFF8CE600)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.tr.routeApprovedAccountActive,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.slateMuted,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),

              // ── 4. Fleet Component Integration ──────────────────────────
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.slateBorder, width: 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.lineLight, width: 1.0),
                      ),
                      child: Center(
                        child: Text(
                          fleetName[0],
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blueLink,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fleetName,
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slateInk,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(Icons.location_pin, size: 12, color: AppColors.slateMuted),
                              SizedBox(width: 4.w),
                              Text(
                                'Al Hamra • 1.2 km',
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.slateMuted,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: AppColors.brandMain,
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 4.w,
                                      height: 4.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceWhite,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      context.tr.routeActiveCaps,
                                      style: TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.surfaceWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                context.tr.routeDriversCount('48'),
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
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
                  ],
                ),
              ),

              // 20.0px margin/gap above Timeline Progress Stepper Card
              SizedBox(height: 20.h),

              // ── 5. Timeline Progress Stepper Card (Width 360, Height 188, Radius 10) ──
              SizedBox(
                width: 360.w,
                height: 188.h,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.slateBorder, width: 1.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TimelineStep(
                        isCompleted: true,
                        isCurrent: false,
                        title: context.tr.routeRequestSent,
                        subtitle: 'Today, 3:32 PM',
                      ),
                      _TimelineStep(
                        isCompleted: true,
                        isCurrent: false,
                        title: context.tr.routeApprovedByDispatcher,
                        subtitle: 'Today, 4:10 PM',
                      ),
                      _TimelineStep(
                        isCompleted: false,
                        isCurrent: true,
                        title: context.tr.routeStartFirstShift,
                        subtitle: context.tr.routeRoutesAppearOnMap,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // ── 6. Notification Info Card (Width 360, Height 60) ─────────
              SizedBox(
                width: 360.w,
                height: 60.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppColors.limePale,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        AppAssets.icNotificationN,
                        width: 24.w,
                        height: 24.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          context.tr.routeJoinMoreFleetsLater,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slateInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // ── 7. Action Buttons ───────────────────────────────────────
              // "Start shift" Button: Width 360, Height 60, Radius 6, arrow_right_ic.png 24x24
              SizedBox(
                width: 360.w,
                height: 60.h,
                child: CustomButton(
                  text: context.tr.routeStartShift,
                  backgroundColor: AppColors.brandMain,
                  textColor: AppColors.onBrand,
                  iconAsset: AppAssets.icArrowRight,
                  width: 360.w,
                  height: 60.h,
                  borderRadius: 6.r,
                  onPressed: () => context.read<RouteFleetCubit>().goToNoFleet(),
                ),
              ),
              SizedBox(height: 12.h),

              // "Not now" Button
              Center(
                child: TextButton(
                  onPressed: () => context.read<RouteFleetCubit>().goToNoFleet(),
                  child: Text(
                    context.tr.routeNotNow,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slateMuted,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.isCompleted,
    required this.isCurrent,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  final bool isCompleted;
  final bool isCurrent;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.brandMain // #8FE600
                    : isCurrent
                        ? AppColors.surfaceWhite
                        : AppColors.surfaceWhite,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.brandMain
                      : isCurrent
                          ? AppColors.brandMain
                          : AppColors.slateBorder,
                  width: isCompleted || isCurrent ? 2.0 : 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.black) // Black checkmark
                    : isCurrent
                        ? Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: const BoxDecoration(
                              color: AppColors.brandMain,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 24.h,
                color: isCompleted ? AppColors.brandMain : AppColors.slateLine,
              ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isCompleted || isCurrent ? AppColors.slateInk : AppColors.slateSoft,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.slateMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
