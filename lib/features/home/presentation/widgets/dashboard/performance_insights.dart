// lib/features/home/presentation/widgets/dashboard/performance_insights.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';

/// Weekly performance metrics.
class PerformanceInsights extends StatelessWidget {
  const PerformanceInsights({required this.stats, super.key});

  final HomeStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
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
          Text(
            'Performance insights',
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _InsightRow(
            label: 'Completed this week',
            value: '${stats.completedRidesWeekly}',
          ),
          _InsightRow(
            label: 'Cancelled this week',
            value: '${stats.cancelledRidesWeekly}',
          ),
          _InsightRow(
            label: 'Total trips',
            value: '${stats.totalTripsWeekly}',
          ),
          _InsightRow(
            label: 'Completion rate',
            value: '${stats.weeklyCompletionPercent.toStringAsFixed(1)}%',
          ),
          _InsightRow(
            label: 'Average speed',
            value: '${stats.averageSpeed.toStringAsFixed(1)} km/h',
          ),
          _InsightRow(
            label: 'Completion score',
            value: '${stats.completionRate.toStringAsFixed(1)}%',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.textUnderline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
