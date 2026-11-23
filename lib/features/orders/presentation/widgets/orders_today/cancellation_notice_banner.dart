// lib/features/orders/presentation/widgets/orders_today/cancellation_notice_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today_metrics.dart';

/// Tells the driver a stop was pulled from their route — and, in the same
/// breath, what to do with the package still in the van.
///
/// It takes the slot the "new orders" banner would use and asks for an
/// explicit OK instead of fading on its own: a driver who glanced away while
/// it showed would otherwise arrive at a door with a parcel nobody wants.
class CancellationNoticeBanner extends StatelessWidget {
  const CancellationNoticeBanner({
    super.key,
    required this.title,
    required this.body,
    required this.okLabel,
    required this.onOk,
  });

  final String title;
  final String body;
  final String okLabel;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Announced as it appears, since it can land while the driver is
      // looking at something else on the list.
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius:
              BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
          border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.iconWarning,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block_rounded,
                    size: 22.w,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        // Figma O05: title line 20, description lines 17.
                        style: AppTextStyles.s16Bold.scaled
                            .copyWith(height: 1.25, color: AppColors.brandBlack),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        body,
                        style: AppTextStyles.s14Regular.scaled
                            .copyWith(height: 1.2, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Material(
              color: AppColors.surfaceAction,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(
                  color: AppColors.borderDeactivated,
                  width: 1.w,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onOk,
                child: SizedBox(
                  height: 40.h,
                  child: Center(
                    child: Text(
                      okLabel,
                      style: AppTextStyles.s16SemiBold.scaled
                          .copyWith(color: AppColors.brandBlack),
                    ),
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
