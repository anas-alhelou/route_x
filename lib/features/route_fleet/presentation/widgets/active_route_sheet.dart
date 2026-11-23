// lib/features/route_fleet/presentation/widgets/active_route_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class ActiveRouteSheet extends StatelessWidget {
  const ActiveRouteSheet({
    super.key,
    required this.vehicleNumber,
    required this.routeName,
    required this.isExpanded,
    required this.onToggle,
  });

  final String vehicleNumber;
  final String routeName;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBlack.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderDeactivated,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicleNumber,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    routeName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: AppColors.brandBlack,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            SizedBox(height: 16.h),
            const Divider(),
            SizedBox(height: 8.h),
            _buildDetailRow('Driver', 'Ahmed Al-Mansoor'),
            _buildDetailRow('Vehicle Status', 'Optimal • Fuel 78%'),
            _buildDetailRow('Current Speed', '42 km/h'),
            _buildDetailRow('Next Maintenance', 'In 1,200 km'),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: AppColors.textBody)),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.brandBlack)),
        ],
      ),
    );
  }
}
