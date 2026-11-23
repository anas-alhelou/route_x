// lib/features/route_fleet/presentation/widgets/unmarked_stop_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class UnmarkedStopCard extends StatelessWidget {
  const UnmarkedStopCard({
    super.key,
    required this.stopNumberText,
    required this.customerName,
    required this.timeAgoText,
    required this.onYesDeliveredTapped,
    required this.onCouldntDeliverTapped,
    required this.onGoBackTapped,
  });

  final String stopNumberText;
  final String customerName;
  final String timeAgoText;
  final VoidCallback onYesDeliveredTapped;
  final VoidCallback onCouldntDeliverTapped;
  final VoidCallback onGoBackTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Overline
            Text(
              context.tr.routeStopNotMarked(stopNumberText),
              style: AppTextStyles.s10Bold.copyWith(
                color: AppColors.statusAmber,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),

            // 2. Title (Figma: 22 Bold)
            Text(
              context.tr.routeDidYouDeliverTo(customerName),
              style: AppTextStyles.s22Bold115.copyWith(color: AppColors.brandBlack),
            ),
            SizedBox(height: 12.h),

            // 3. Body
            Text(
              context.tr.routeLeftAddress(timeAgoText),
              style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
            ),
            // Figma: 12 + a 2px spacer + 12 before the primary button
            SizedBox(height: 26.h),

            // 4. Yes, delivered button
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMain,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                onPressed: onYesDeliveredTapped,
                child: Text(
                  context.tr.routeYesDelivered,
                  style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // 5. Secondary buttons row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.brandBackground,
                        side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                        ),
                      ),
                      onPressed: onCouldntDeliverTapped,
                      child: Text(
                        context.tr.routeCouldntDeliver,
                        style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.brandBackground,
                        side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                        ),
                      ),
                      onPressed: onGoBackTapped,
                      child: Text(
                        context.tr.routeGoBack,
                        style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                      ),
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
