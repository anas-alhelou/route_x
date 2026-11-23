// lib/features/home/presentation/widgets/dashboard/status_toggle_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';

/// Online/offline switch card.
///
/// Purely presentational: reads its state from [status] and reports changes to
/// [onChanged]. Independent of [HomeDashboardBloc], so a flip does not re-run
/// the dashboard load.
class StatusToggleCard extends StatelessWidget {
  const StatusToggleCard({
    required this.status,
    required this.onChanged,
    this.isUpdating = false,
    super.key,
  });

  final DriverStatus status;
  final ValueChanged<DriverStatus> onChanged;
  final bool isUpdating;

  bool get _isOnline => status == DriverStatus.online;

  Color get _statusColor => switch (status) {
        DriverStatus.online => AppColors.success,
        DriverStatus.offline => AppColors.textMuted,
        DriverStatus.onRide => AppColors.info,
        DriverStatus.onBreak => AppColors.warning,
      };

  String get _title => switch (status) {
        DriverStatus.online => 'You are online',
        DriverStatus.offline => 'You are offline',
        DriverStatus.onRide => 'On a ride',
        DriverStatus.onBreak => 'On a break',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowCard.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10.r,
            height: 10.r,
            decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tap the switch to change your availability',
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isUpdating)
            SizedBox(
              width: 20.r,
              height: 20.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: _isOnline,
              activeThumbColor: AppColors.brandMain,
              onChanged: (value) =>
                  onChanged(value ? DriverStatus.online : DriverStatus.offline),
            ),
        ],
      ),
    );
  }
}
