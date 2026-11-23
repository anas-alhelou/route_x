import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'route_list_row.dart';

class MoreOptionsSheet extends StatelessWidget {
  const MoreOptionsSheet({
    super.key,
    required this.onTryAgainLaterTapped,
    required this.onDeliverDifferentStopTapped,
    required this.onReportWrongLocationTapped,
    required this.onGetHelpTapped,
    required this.onCloseTapped,
  });

  final VoidCallback onTryAgainLaterTapped;
  final VoidCallback onDeliverDifferentStopTapped;
  final VoidCallback onReportWrongLocationTapped;
  final VoidCallback onGetHelpTapped;
  final VoidCallback onCloseTapped;

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
            context.tr.routeMoreOptions,
            style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
          ),
          SizedBox(height: 16.h),
          // Rows
          RouteListRow(
            icon: SvgPicture.asset(
              AppAssets.routeIcHistory,
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
            ),
            title: context.tr.routeTryAgainLater,
            subtitle: context.tr.routeTryAgainLaterSub,
            onTap: onTryAgainLaterTapped,
          ),
          RouteListRow(
            icon: SvgPicture.asset(
              AppAssets.routeIcStops,
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
            ),
            title: context.tr.routeDeliverDifferentStop,
            subtitle: context.tr.routeDeliverDifferentStopSub,
            onTap: onDeliverDifferentStopTapped,
          ),
          RouteListRow(
            icon: SvgPicture.asset(
              AppAssets.routeIcPin,
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
            ),
            title: context.tr.routeReportWrongLocation,
            subtitle: context.tr.routeReportWrongLocationSub,
            onTap: onReportWrongLocationTapped,
          ),
          RouteListRow(
            tileColor: AppColors.brandMain, // Lime tile for Get help
            icon: SvgPicture.asset(
              AppAssets.routeIcCall,
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
            ),
            title: context.tr.routeGetHelp,
            subtitle: context.tr.routeGetHelpSub,
            showDivider: false,
            onTap: onGetHelpTapped,
          ),
          SizedBox(height: 16.h),
          // Close Button
          SizedBox(
            height: 52.h,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
              ),
              onPressed: onCloseTapped,
              child: Text(
                context.tr.routeClose,
                style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
