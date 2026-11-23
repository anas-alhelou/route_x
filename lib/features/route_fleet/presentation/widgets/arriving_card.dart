// lib/features/route_fleet/presentation/widgets/arriving_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class ArrivingCard extends StatelessWidget {
  const ArrivingCard({
    super.key,
    required this.customerName,
    required this.address,
    required this.onNotHereYetTapped,
    required this.onOpenStopTapped,
  });

  final String customerName;
  final String address;
  final VoidCallback onNotHereYetTapped;
  final VoidCallback onOpenStopTapped;

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
              context.tr.routeYouveArrivedCaps,
              // Figma R41: 12 Bold lime
              style: AppTextStyles.s12Bold.copyWith(
                color: AppColors.brandMain,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),

            // 2. Customer Name
            Text(
              customerName,
              style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
            ),
            SizedBox(height: 12.h),

            // 3. Address (Figma: 14 Regular)
            Text(
              address,
              style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),

            // 4. Progress bar (auto-advance bar)
            ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: LinearProgressIndicator(
                value: 0.645,
                backgroundColor: AppColors.canvas,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandMain),
                minHeight: 4.h,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              context.tr.routeOpeningStopIn3s,
              style: AppTextStyles.s13Medium14.copyWith(color: AppColors.textBody),
            ),
            SizedBox(height: 12.h),

            // 5. Buttons row
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
                      onPressed: onNotHereYetTapped,
                      child: Text(
                        context.tr.routeNotHereYet,
                        style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandMain,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                        ),
                      ),
                      onPressed: onOpenStopTapped,
                      child: Text(
                        context.tr.routeOpenStop,
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
