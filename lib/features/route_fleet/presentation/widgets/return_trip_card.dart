// lib/features/route_fleet/presentation/widgets/return_trip_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class ReturnTripCard extends StatelessWidget {
  const ReturnTripCard({
    super.key,
    required this.depotName,
    required this.metaText,
    required this.packageCountText,
    required this.packageSubtitle,
    required this.onAtDepotTapped,
  });

  final String depotName;
  final String metaText;
  final String packageCountText;
  final String packageSubtitle;
  final VoidCallback onAtDepotTapped;

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
              context.tr.routeReturningToDepot,
              style: AppTextStyles.s10Bold.copyWith(
                color: AppColors.textBody,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),

            // 2. Depot Name
            Text(
              depotName,
              style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
            ),
            SizedBox(height: 12.h),

            // 3. Meta (Figma: 13 Regular)
            Text(
              metaText,
              style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),

            // 4. Package row (Figma: no box, 10 vertical padding)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: AppColors.amberSurface,
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.routeIcPackage,
                        width: 20.w,
                        height: 20.h,
                        colorFilter: ColorFilter.mode(AppColors.statusAmber, BlendMode.srcIn),
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
                          packageCountText,
                          style: AppTextStyles.s15Bold135.copyWith(color: AppColors.brandBlack),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          packageSubtitle,
                          style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // 5. Button
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
                onPressed: onAtDepotTapped,
                child: Text(
                  context.tr.routeImAtDepot,
                  style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
