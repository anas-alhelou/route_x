import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'route_list_row.dart';

class HelpSheet extends StatelessWidget {
  const HelpSheet({
    super.key,
    required this.companyName,
    required this.onCallDispatchTapped,
    required this.onMessageDispatchTapped,
    required this.onTakeABreakTapped,
    required this.onVehicleProblemTapped,
    required this.onUnsafeTapped,
    required this.onCloseTapped,
  });

  final String companyName;
  final VoidCallback onCallDispatchTapped;
  final VoidCallback onMessageDispatchTapped;
  final VoidCallback onTakeABreakTapped;
  final VoidCallback onVehicleProblemTapped;
  final VoidCallback onUnsafeTapped;
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
            context.tr.routeNeedHelp,
            style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
          ),
          SizedBox(height: 4.h),
          // Subtitle
          Text(
            context.tr.routeDispatchAnswers(companyName),
            style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
          ),
          SizedBox(height: 16.h),
          // Rows (Figma R31: 15 Bold titles)
          RouteListRow(
            titleBold: true,
            icon: SvgPicture.asset(
              AppAssets.routeIcCall,
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
            ),
            title: context.tr.routeCallDispatch,
            onTap: onCallDispatchTapped,
          ),
          RouteListRow(
            titleBold: true,
            icon: SvgPicture.asset(
              AppAssets.routeIcNote,
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
            ),
            title: context.tr.routeMessageDispatch,
            onTap: onMessageDispatchTapped,
          ),
          RouteListRow(
            titleBold: true,
            icon: SvgPicture.asset(
              AppAssets.routeIcClockHistory,
              width: 20.w,
              height: 20.h,
            ),
            title: context.tr.routeTakeBreak,
            onTap: onTakeABreakTapped,
          ),
          RouteListRow(
            titleBold: true,
            icon: SvgPicture.asset(
              AppAssets.routeIcVehicleProblem,
              width: 20.w,
              height: 10.h,
            ),
            title: context.tr.routeVehicleProblem,
            subtitle: context.tr.routeVehicleProblemSub,
            onTap: onVehicleProblemTapped,
          ),
          RouteListRow(
            titleBold: true,
            tileColor: AppColors.dangerSurface,
            icon: SvgPicture.asset(
              AppAssets.routeIcPackageFailed,
              width: 22.w,
              height: 22.h,
            ),
            title: context.tr.routeFeelUnsafe,
            titleColor: AppColors.dangerText,
            subtitle: context.tr.routeFeelUnsafeSub,
            showDivider: false,
            onTap: onUnsafeTapped,
          ),
          SizedBox(height: 16.h),
          // Close Button (Figma R31: radius 12)
          SizedBox(
            height: 52.h,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
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
