import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'route_list_row.dart';

class RouteChangesSheet extends StatelessWidget {
  const RouteChangesSheet({
    super.key,
    required this.companyName,
    required this.updateTimestamp,
    required this.onGotItTapped,
  });

  final String companyName;
  final String updateTimestamp;
  final VoidCallback onGotItTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.proofSheetShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            context.tr.routeWhatChanged,
            style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
          ),
          SizedBox(height: 10.h),
          // Subtitle (Figma: 13 Regular)
          Text(
            context.tr.routeUpdatedYourRouteAt(companyName, updateTimestamp),
            style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
          ),
          SizedBox(height: 10.h),
          // Three Rows
          RouteListRow(
            tileColor: AppColors.addedSurface,
            icon: SvgPicture.asset(
              AppAssets.routeIcPackage,
              width: 22.w,
              height: 22.h,
              colorFilter: const ColorFilter.mode(AppColors.brandMain, BlendMode.srcIn),
            ),
            title: context.tr.routeChangeAdded,
            subtitle: context.tr.routeChangeAddedSub,
            dividerGap: 10,
          ),
          RouteListRow(
            tileColor: AppColors.dangerSurface,
            icon: SvgPicture.asset(
              AppAssets.routeIcCancelled,
              width: 22.w,
              height: 22.h,
            ),
            title: context.tr.routeChangeRemoved,
            subtitle: context.tr.routeChangeRemovedSub,
            dividerGap: 10,
          ),
          RouteListRow(
            tileColor: AppColors.deactivatedBadge,
            icon: SvgPicture.asset(
              AppAssets.routeIcClockHistory,
              width: 20.w,
              height: 20.h,
            ),
            title: context.tr.routeNowStops,
            subtitle: context.tr.routeAboutLonger,
            showDivider: false,
          ),
          SizedBox(height: 10.h),
          // Got it Button
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
              onPressed: onGotItTapped,
              child: Text(
                context.tr.routeGotIt,
                style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
