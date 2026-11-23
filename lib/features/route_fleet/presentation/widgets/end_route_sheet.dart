import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/route_stop.dart';

class EndRouteSheet extends StatelessWidget {
  const EndRouteSheet({
    super.key,
    required this.remainingStops,
    required this.onKeepDeliveringTapped,
    required this.onEndRouteTapped,
  });

  final List<RouteStop> remainingStops;
  final VoidCallback onKeepDeliveringTapped;
  final VoidCallback onEndRouteTapped;

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
            // 1. Title
            Text(
              context.tr.routeEndRouteNowQ,
              style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
            ),
            SizedBox(height: 14.h),

            // 2. Body
            Text(
              context.tr.routeEndRouteWarning(remainingStops.length.toString()),
              style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
            ),
            SizedBox(height: 14.h),

            // 3. Danger box ("Stops left")
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.dangerSurface,
                borderRadius: BorderRadius.circular(AppSizes.r12),
                border: Border.all(color: AppColors.dangerIcon, width: 1.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: remainingStops.asMap().entries.map((entry) {
                  final stop = entry.value;
                  // Figma: 8 between the lines, none after the last one
                  return Padding(
                    padding: EdgeInsets.only(bottom: entry.key < remainingStops.length - 1 ? 8.h : 0),
                    child: Text(
                      '${stop.title} · ${stop.address}',
                      style: AppTextStyles.s13Medium14.copyWith(color: AppColors.dangerIcon),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 14.h),

            // 4. Keep delivering button (Target: R10)
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMain,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                onPressed: onKeepDeliveringTapped,
                child: Text(
                  context.tr.routeKeepDelivering,
                  style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // 5. End route button (Target: R19, via RouteFleetCubit.endRouteEarly)
            SizedBox(
              height: 56.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r16),
                  ),
                ),
                onPressed: onEndRouteTapped,
                child: Text(
                  context.tr.routeEndRoute,
                  style: AppTextStyles.s16Bold14.copyWith(color: AppColors.dangerText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
