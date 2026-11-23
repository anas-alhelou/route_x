import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../controllers/route_fleet_state.dart';

class StateBanner extends StatelessWidget {
  const StateBanner({
    super.key,
    required this.type,
    required this.customerName,
  });

  final StateBannerType type;
  final String customerName;

  @override
  Widget build(BuildContext context) {
    if (type == StateBannerType.none) return const SizedBox.shrink();

    String iconAsset = AppAssets.routeIcUTurn;
    Color tileColor = AppColors.amberSurface;
    double iconSize = 32;
    String title = context.tr.routeFindingNewWay;
    String body = context.tr.routeLeftRoute(customerName);

    if (type == StateBannerType.weakGps) {
      iconAsset = AppAssets.routeIcRecenter;
      tileColor = AppColors.deactivatedBadge;
      iconSize = 28;
      title = context.tr.routeWeakGps;
      body = context.tr.routeWeakGpsBody;
    } else if (type == StateBannerType.offline) {
      iconAsset = AppAssets.routeIcOffline;
      tileColor = AppColors.dangerSurface; // Figma R25: #FFECE5
      iconSize = 28;
      title = context.tr.routeOffline;
      body = context.tr.routeOfflineBody;
    }

    return Container(
      width: 360.w,
      // Figma: the height (89) comes from the content, so it is not fixed
      // (a fixed height overflowed by a few pixels when the body takes 2 lines).
      constraints: BoxConstraints(minHeight: 89.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Tile 52x52 (16r radius)
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconAsset,
                width: iconSize.w,
                height: iconSize.h,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Title & Body Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s18Bold13.copyWith(color: AppColors.brandBlack),
                ),
                SizedBox(height: 2.h),
                Text(
                  body,
                  style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
