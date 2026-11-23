// lib/features/route_fleet/presentation/widgets/route_stop_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import '../../domain/entities/route_stop.dart';

class RouteStopTile extends StatelessWidget {
  const RouteStopTile({
    super.key,
    required this.stop,
    required this.index,
    required this.onToggle,
  });

  final RouteStop stop;
  final int index;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(stop.id),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: stop.isCompleted ? AppColors.brandMain.withAlpha(15) : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: stop.isCompleted ? AppColors.brandMain : AppColors.borderDeactivated,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stop.isCompleted ? AppColors.brandMain : AppColors.borderDeactivated,
              ),
              child: Center(
                child: stop.isCompleted
                    ? Icon(Icons.check, size: 18, color: AppColors.brandBlack)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandBlack,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.title,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlack,
                      decoration: stop.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    stop.address,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textBody),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stop.eta,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlack,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: stop.isCompleted ? AppColors.success.withAlpha(30) : AppColors.warning.withAlpha(30),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    stop.status,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: stop.isCompleted ? AppColors.success : AppColors.brandBlack,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
