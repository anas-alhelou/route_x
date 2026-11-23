// lib/features/route_fleet/presentation/widgets/route_planning_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';

class RoutePlanningView extends StatelessWidget {
  const RoutePlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Drag Handle
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.lineLight2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Header
          Text(
            context.tr.routePlanningYourRoute,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            context.tr.routeAppOptimizesArea,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textBody,
              height: 1.3,
            ),
          ),
          SizedBox(height: 20.h),
          // Stops Sequence List
          _buildStopItem(
            index: 1,
            name: 'Omar Haddad',
            address: 'Sari St, Al Zahra',
            status: StopStatus.active,
          ),
          SizedBox(height: 12.h),
          _buildStopItem(
            index: 2,
            name: 'Lina Fares',
            address: 'Tahlia St, Al Nahda',
            status: StopStatus.upcoming,
          ),
          SizedBox(height: 12.h),
          _buildStopItem(
            index: 3,
            name: 'Ahmed Ali',
            address: 'Prince Sultan St, Al Rawdah',
            status: StopStatus.pending,
          ),
          SizedBox(height: 24.h),
          // Bottom Action Indicator
          Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.paleSurface2,
              borderRadius: BorderRadius.circular(AppSizes.r12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.navigation_outlined,
                  size: 18.sp,
                  color: AppColors.textGray,
                ),
                SizedBox(width: 8.w),
                Text(
                  context.tr.routeGettingRouteReady,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem({
    required int index,
    required String name,
    required String address,
    required StopStatus status,
  }) {
    return Row(
      children: [
        _buildStatusDot(status, index),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
        ),
        // Trailing loading bar
        Container(
          width: 32.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: AppColors.lineLight2,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDot(StopStatus status, int index) {
    switch (status) {
      case StopStatus.active:
        return Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: const Color(0xFF8CE600),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check,
              size: 12.sp,
              color: AppColors.brandWhite,
            ),
          ),
        );
      case StopStatus.upcoming:
        return Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF8CE600), width: 2),
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8CE600),
              ),
            ),
          ),
        );
      case StopStatus.pending:
        return Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lineLight2, width: 2),
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.lineLight2,
              ),
            ),
          ),
        );
    }
  }
}

enum StopStatus { active, upcoming, pending }
