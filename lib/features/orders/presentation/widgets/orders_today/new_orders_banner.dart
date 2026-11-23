// lib/features/orders/presentation/widgets/orders_today/new_orders_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today_metrics.dart';

/// Tells the driver dispatch changed their plan, and gives them the one
/// action that resolves it.
///
/// Blue, not brand green: green is the colour of work already agreed to
/// (the current stop, the Review button's own urgency). This is news the
/// driver has not seen yet, so it reads as information, not as progress.
class NewOrdersBanner extends StatelessWidget {
  const NewOrdersBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onReviewPressed,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onReviewPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceInfoSoft,
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.iconBlueAccent, width: 1.w),
            ),
            child: Center(
              child: Assets.icons.svg.package.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  AppColors.iconBlueAccent,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s14Bold.scaled
                      .copyWith(height: 1.4, color: AppColors.brandBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTextStyles.s12Regular.scaled
                      .copyWith(height: 1.4, color: AppColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _ReviewButton(label: actionLabel, onPressed: onReviewPressed),
        ],
      ),
    );
  }
}

class _ReviewButton extends StatelessWidget {
  const _ReviewButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandMain,
      borderRadius: BorderRadius.circular(999.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            label,
            style: AppTextStyles.s14Bold.scaled.copyWith(
              fontSize: 13.sp,
              height: 1.4,
              color: AppColors.brandBlack,
            ),
          ),
        ),
      ),
    );
  }
}
