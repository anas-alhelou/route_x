import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/main_layout/presentation/cubit/main_layout_cubit.dart';
import 'package:routex_mobile/core/widgets/routex_pop_in.dart';

class DriverPuck extends StatelessWidget {
  const DriverPuck({super.key, this.heading});

  final double? heading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.w,
      height: 64.h,
      child: Center(
        child: Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.routeAccuracyFill.withValues(alpha: 0.14),
          ),
          child: Center(
            child: Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceWhite,
                boxShadow: AppTextStyles.puckBaseShadow,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: ((heading ?? 0.0) * 3.141592653589793) / 180.0,
                  child: SizedBox(
                    width: 22.w,
                    height: 22.h,
                    child: const Icon(
                      Icons.navigation,
                      size: 16,
                      color: AppColors.routeHeadingArrow,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteEmptyIcon extends StatelessWidget {
  const _RouteEmptyIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.routeIcRoute,
      width: 32.w,
      height: 32.h,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
    );
  }
}

class _OrdersEmptyIcon extends StatelessWidget {
  const _OrdersEmptyIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.routeIcOrders,
      width: 22.w,
      height: 22.h,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
    );
  }
}

class RouteEmptyView extends StatelessWidget {
  const RouteEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground, // #FDFDFD
        borderRadius: BorderRadius.circular(AppSizes.r24.r),
        border: Border.all(
          color: AppColors.borderDeactivated, // #D0D0D0
          width: 1.w,
        ),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Lime circle 64x64
            RouteXPopIn(
              child: Container(
                width: 64.w,
                height: 64.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandMain, // #8FE600
                ),
                child: const Center(
                  child: _RouteEmptyIcon(),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // 2. Title
            Text(
              context.tr.routeNoRouteRightNow,
              textAlign: TextAlign.center,
              style: AppTextStyles.s20Bold.copyWith(
                color: AppColors.brandBlack, // #222222
                height: 1.25,
              ),
            ),
            SizedBox(height: 12.h),

            // 3. Body
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text(
                context.tr.routeNoRouteDesc,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTextStyles.s14Regular.copyWith(
                  color: AppColors.textBody, // #737373
                  height: 1.45,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // 4. Button: full inner width, height 56, fill #FFFFFF, border 1px #D0D0D0, radius r8
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surfaceWhite, // #FFFFFF
                  foregroundColor: AppColors.brandBlack,
                  elevation: 0,
                  side: BorderSide(
                    color: AppColors.borderDeactivated, // #D0D0D0
                    width: 1.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                onPressed: () {
                  context.read<MainLayoutCubit>().changeTab(2); // Orders tab
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _OrdersEmptyIcon(),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr.routeSeeMyOrders,
                      style: AppTextStyles.s16Bold.copyWith(
                        color: AppColors.brandBlack,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
