// lib/features/route_fleet/presentation/widgets/map_header_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class MapHeaderWidget extends StatelessWidget {
  const MapHeaderWidget({super.key, required this.progressPercentage, required this.totalDistance});

  final double progressPercentage;
  final String totalDistance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.brandBlack,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.brandBlack,
            AppColors.brandBlack.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(
                painter: _MapGridPainter(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr.routeLiveFleetNavigation,
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilySatoshi,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.surfaceWhite,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.brandMain,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        context.tr.routeActiveRoute,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBrand,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.surfaceWhite.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr.routeRouteProgress,
                            style: TextStyle(fontSize: 13.sp, color: AppColors.brandWhite),
                          ),
                          Text(
                            context.tr.routeProgressLeft((progressPercentage * 100).toInt().toString(), totalDistance),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandMain,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: progressPercentage,
                          backgroundColor: AppColors.surfaceWhite.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandMain),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const step = 30.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += step) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
