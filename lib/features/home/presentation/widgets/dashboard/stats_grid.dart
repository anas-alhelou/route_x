// lib/features/home/presentation/widgets/dashboard/stats_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';

/// A 2×2 grid of today's headline metrics: rides, earnings, driving time and
/// rating.
class StatsGrid extends StatelessWidget {
  const StatsGrid({required this.stats, super.key});

  final HomeStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.local_taxi_outlined,
                label: "Today's rides",
                value: '${stats.todayRides}',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatTile(
                icon: Icons.payments_outlined,
                label: 'Earnings',
                value: 'SAR ${stats.todayEarnings.toStringAsFixed(0)}',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.timer_outlined,
                label: 'Driving time',
                value: _formatDuration(stats.totalDrivingTime),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatTile(
                icon: Icons.star_rounded,
                label: 'Rating',
                value: stats.averageRating.toStringAsFixed(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.r, color: AppColors.brandMain),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
