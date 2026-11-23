// lib/features/orders/presentation/widgets/history/sync_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_row_tile.dart';
import '../orders_today/orders_today_metrics.dart';

/// The delivered mark in a soft green well — [HistoryFailureBadge]'s
/// counterpart, for a light row where the solid brand-green badge would
/// shout.
class HistoryDeliveredBadge extends StatelessWidget {
  const HistoryDeliveredBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return OrdersRowBadge(
      background: AppColors.surfaceSuccessSoft,
      borderColor: AppColors.brandMain,
      child: Assets.icons.svg.delivered.svg(width: 22.w, height: 22.w),
    );
  }
}

/// "Waiting" — an update still on the phone. Amber like the sync card that
/// leads here.
class SyncWaitingPill extends StatelessWidget {
  const SyncWaitingPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.statusAmberSurface,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.statusAmber, width: 0.8.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.svg.clockHistory.svg(width: 14.w, height: 14.w),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.s12SemiBold.scaled.copyWith(
              fontSize: 11.sp,
              height: 1.4,
              color: AppColors.statusAmber,
            ),
          ),
        ],
      ),
    );
  }
}

/// The one thing that can still lose these updates, said once and plainly.
class SyncKeepAppWarning extends StatelessWidget {
  const SyncKeepAppWarning({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.statusAmberSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.statusAmber, width: 1.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.icons.svg.clockHistory.svg(width: 24.w, height: 24.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.s14Medium.scaled.copyWith(
                fontSize: 13.sp,
                height: 1.4,
                color: AppColors.brandBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
