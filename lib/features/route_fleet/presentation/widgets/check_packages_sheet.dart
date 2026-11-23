// lib/features/route_fleet/presentation/widgets/check_packages_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/fleet_info.dart';

class CheckPackagesSheet extends StatelessWidget {
  const CheckPackagesSheet({
    super.key,
    required this.fleetInfo,
    required this.checkedStopIds,
    required this.onPackageToggled,
    required this.onStartRouteTapped,
    required this.onPackageMissingTapped,
    this.onScanLabelsTapped,
  });

  final FleetInfo fleetInfo;
  final Set<String> checkedStopIds;
  final ValueChanged<String> onPackageToggled;
  final VoidCallback onStartRouteTapped;
  final VoidCallback onPackageMissingTapped;
  final VoidCallback? onScanLabelsTapped;

  @override
  Widget build(BuildContext context) {
    final totalCount = fleetInfo.stops.length;
    final checkedCount = checkedStopIds.length;
    final allChecked = checkedCount == totalCount;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // 1. Overline
            Text(
              context.tr.routeBeforeYouGo,
              style: AppTextStyles.s10Bold.copyWith(
                color: AppColors.textBody,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10.h),

            // 2. Title (Figma R43: 22 Bold, one line)
            Text(
              context.tr.routeAllPackagesInVan(totalCount.toString()),
              // Figma: 22 Bold, letter spacing -1.5% so it fits one line
              style: AppTextStyles.s22Bold115.copyWith(
                color: AppColors.brandBlack,
                letterSpacing: -0.33,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.h),

            // 3. Subtitle (Figma: 13 Regular)
            Text(
              context.tr.routeTapEachOrScan,
              style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
            ),
            // Figma: 10 + a 4px spacer + 10 before the package rows
            SizedBox(height: 24.h),

            // 4. Package rows
            ...fleetInfo.stops.map((stop) {
              final isChecked = checkedStopIds.contains(stop.id);
              // Detail line from data only (no invented order id / package type)
              final detailText = [
                if (stop.orderId != null && stop.orderId!.isNotEmpty) stop.orderId!,
                if (stop.packageType != null && stop.packageType!.isNotEmpty) stop.packageType!,
              ].join(' · ');

              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: InkWell(
                  onTap: () => onPackageToggled(stop.id),
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
                    ),
                    child: Row(
                      children: [
                        // Checkbox
                        Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: isChecked ? AppColors.brandMain : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(7.r),
                            border: Border.all(
                              color: isChecked ? AppColors.brandMain : AppColors.borderDeactivated,
                              width: 1.5.w,
                            ),
                          ),
                          child: isChecked
                              ? Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 16.sp,
                                    color: AppColors.brandBlack,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                stop.title,
                                style: AppTextStyles.s15Bold135.copyWith(color: AppColors.brandBlack),
                              ),
                              SizedBox(height: 1.h),
                              if (detailText.isNotEmpty)
                                Text(
                                  detailText,
                                  style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // 5. Scan labels instead row (rows above already end with a 10 gap)
            InkWell(
              onTap: onScanLabelsTapped ?? () {},
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.routeIcPackage,
                      width: 24.w,
                      height: 24.h,
                      colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr.routeScanLabelsInstead,
                      style: AppTextStyles.s14SemiBold.copyWith(color: AppColors.brandBlack),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // 6. Primary Button
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: allChecked ? AppColors.brandMain : AppColors.surfaceWhite,
                  disabledBackgroundColor: AppColors.surfaceWhite,
                  disabledForegroundColor: AppColors.textBody,
                  elevation: 0,
                  side: allChecked ? BorderSide.none : BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r12), // Figma R43: radius 12
                  ),
                ),
                onPressed: allChecked ? onStartRouteTapped : null,
                child: Text(
                  allChecked
                      ? context.tr.routeStartRoute
                      : context.tr.routeCheckedOf(checkedCount.toString(), totalCount.toString()),
                  style: AppTextStyles.s16Bold.copyWith(
                    color: allChecked ? AppColors.brandBlack : AppColors.textBody,
                  ),
                ),
              ),
            ),

            // 7. Package missing link (if not all checked)
            if (!allChecked) ...[
              SizedBox(height: 10.h),
              Center(
                child: TextButton(
                  onPressed: onPackageMissingTapped,
                  child: Text(
                    context.tr.routePackageMissing,
                    style: AppTextStyles.s14Bold.copyWith(color: AppColors.dangerIcon),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }
}
