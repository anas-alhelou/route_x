import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/fleet_info.dart';

class StopsSheet extends StatelessWidget {
  const StopsSheet({
    super.key,
    required this.fleetInfo,
    required this.currentStopIndex,
    required this.onBackToDirectionsTapped,
    required this.onEndRouteEarlyTapped,
  });

  final FleetInfo fleetInfo;
  final int currentStopIndex;
  final VoidCallback onBackToDirectionsTapped;
  final VoidCallback onEndRouteEarlyTapped;

  @override
  Widget build(BuildContext context) {
    final totalStops = fleetInfo.stops.length;
    // Done count = currentStopIndex (assuming stops before current are done)
    final doneCount = currentStopIndex;

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
            // 1. Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.tr.routeTodaysRoute,
                  style: AppTextStyles.s20Bold125.copyWith(color: AppColors.brandBlack),
                ),
                Text(
                  context.tr.routeDoneOfTotal(doneCount.toString(), totalStops.toString()),
                  style: AppTextStyles.s12Medium145.copyWith(color: AppColors.textBody),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // 2. Progress bar (3 segments)
            Row(
              children: List.generate(totalStops, (i) {
                final isDoneOrCurrent = i <= currentStopIndex;
                return Expanded(
                  child: Container(
                    height: 6.h,
                    margin: EdgeInsets.only(right: i < totalStops - 1 ? 4.w : 0),
                    decoration: BoxDecoration(
                      color: isDoneOrCurrent ? AppColors.brandMain : AppColors.deactivatedBadge,
                      borderRadius: BorderRadius.circular(AppSizes.r32),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 14.h),

            // 3. Stops list
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(totalStops, (i) {
                final stop = fleetInfo.stops[i];
                final isCurrent = i == currentStopIndex;

                return Padding(
                  // Figma: 6 between rows, none after the last one
                  padding: EdgeInsets.only(bottom: i < totalStops - 1 ? 6.h : 0),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.sliderProgressFill : Colors.transparent,
                      borderRadius: BorderRadius.circular(isCurrent ? AppSizes.r12 : AppSizes.r16),
                      border: Border.all(
                        color: isCurrent ? AppColors.brandMain : Colors.transparent,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent ? AppColors.brandMain : AppColors.deactivatedBadge,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: AppTextStyles.s12Bold.copyWith(color: AppColors.brandBlack),
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
                                stop.title,
                                style: AppTextStyles.s14Bold14.copyWith(color: AppColors.brandBlack),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                stop.address,
                                style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (stop.eta.isNotEmpty && stop.eta != '--') ...[
                          Text(
                            isCurrent ? context.tr.routeEnRouteEta(stop.eta) : context.tr.routeEta(stop.eta),
                            style: AppTextStyles.s12Medium145.copyWith(
                              color: isCurrent ? AppColors.brandMain : AppColors.textBody,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 14.h),

            // 4. Back to directions button (Target: R10)
            SizedBox(
              height: 56.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surfaceWhite,
                  side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                onPressed: onBackToDirectionsTapped,
                child: Text(
                  context.tr.routeBackToDirections,
                  style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // 5. End route early button (Target: R22)
            SizedBox(
              height: 44.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r16),
                  ),
                ),
                onPressed: onEndRouteEarlyTapped,
                child: Text(
                  context.tr.routeEndRouteEarly,
                  style: AppTextStyles.s15SemiBold14.copyWith(color: AppColors.dangerText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
