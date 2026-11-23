// lib/features/orders/presentation/widgets/orders_today/connection_lost_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today_metrics.dart';

/// Shown when the phone has no network at all: nothing new can arrive, so
/// the driver is told plainly and given a way to try once they move.
///
/// A card in the banner slot, louder than the weak-signal line, because the
/// two mean different things. A weak signal heals itself and the app keeps
/// retrying; no signal at all needs the driver to know they are on their
/// own until they reach coverage.
///
/// Try again is grey, not brand green: it is a fallback, and the list below
/// is still the thing to act on.
class ConnectionLostBanner extends StatelessWidget {
  const ConnectionLostBanner({
    super.key,
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius:
              BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
          border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        ),
        child: Row(
          children: [
            // The asset already draws its own red well and border.
            Assets.icons.svg.icon.svg(width: 36.w, height: 36.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    // Figma O10: title 15sp bold, description 13sp / 17 line.
                    style: AppTextStyles.s15Bold.scaled
                        .copyWith(color: AppColors.brandBlack, height: 1.4),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    message,
                    style: AppTextStyles.s14Regular.scaled.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 13.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Material(
              color: AppColors.surfaceBadge,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onRetry,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
                  child: Text(
                    retryLabel,
                    style: AppTextStyles.s14SemiBold.scaled
                        .copyWith(color: AppColors.brandBlack),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
