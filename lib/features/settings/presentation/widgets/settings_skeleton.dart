import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_skeleton.dart';

/// Loading placeholder for the Settings page: the same section layout as the
/// loaded page, drawn with pulsing [RouteXSkeleton] bars (like the Route tab).
class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.fromSTEB(
            26.w,
            12.h,
            26.w,
            AppSizes.bottomNavClearance.h,
          ),
          children: [
            RouteXSkeleton.line(width: 140.w, height: 28.h, radius: 8.r),
            SizedBox(height: 20.h),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RouteXSkeleton.circle(size: 56.r),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RouteXSkeleton.line(width: 130.w, height: 14.h),
                            SizedBox(height: 10.h),
                            RouteXSkeleton.line(width: 90.w, height: 8.h),
                          ],
                        ),
                      ),
                      RouteXSkeleton.circle(size: 40.r),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  RouteXSkeleton.block(
                    width: double.infinity,
                    height: 56.h,
                    radius: 16.r,
                  ),
                ],
              ),
            ),
            SizedBox(height: 22.h),
            RouteXSkeleton.line(width: 150.w, height: 18.h),
            SizedBox(height: 19.h),
            Row(
              children: [
                Expanded(child: _tile()),
                SizedBox(width: 12.w),
                Expanded(child: _tile()),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: _tile()),
                SizedBox(width: 12.w),
                Expanded(child: _tile()),
              ],
            ),
            SizedBox(height: 16.h),
            _section(rows: 1),
            SizedBox(height: 16.h),
            _section(rows: 3),
            SizedBox(height: 16.h),
            _section(rows: 3),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: child,
    );
  }

  Widget _tile() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RouteXSkeleton.circle(size: 32.r),
          SizedBox(height: 14.h),
          RouteXSkeleton.line(width: 80.w, height: 12.h),
          SizedBox(height: 8.h),
          RouteXSkeleton.line(width: 56.w, height: 8.h),
        ],
      ),
    );
  }

  Widget _section({required int rows}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RouteXSkeleton.line(width: 110.w, height: 14.h),
          for (var i = 0; i < rows; i++) ...[
            SizedBox(height: 14.h),
            Row(
              children: [
                RouteXSkeleton.circle(size: 36.r),
                SizedBox(width: 12.w),
                RouteXSkeleton.line(width: 150.w, height: 12.h),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
