import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/utils/external_launcher.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class ArrivalSheet extends StatelessWidget {
  const ArrivalSheet({
    super.key,
    required this.stopIndexText,
    required this.arrivalTime,
    required this.customerName,
    required this.addressAndOrder,
    this.companyNote,
    this.phone,
    required this.onMapsTapped,
    required this.onMoreTapped,
    required this.onCouldntDeliverTapped,
    required this.onDeliveredTapped,
  });

  final String stopIndexText;
  final String arrivalTime;
  final String customerName;
  final String addressAndOrder;
  final String? companyNote;

  /// The customer's number, dialled by the Call tile.
  final String? phone;
  final VoidCallback onMapsTapped;
  final VoidCallback onMoreTapped;
  final VoidCallback onCouldntDeliverTapped;
  final VoidCallback onDeliveredTapped;

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
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header (Overline + ETA)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                stopIndexText,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: 0.6,
                  color: AppColors.textBody,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppAssets.routeIcEta,
                    width: 16.w,
                    height: 16.h,
                    colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    context.tr.routeArrivedAt(arrivalTime),
                    style: AppTextStyles.s12Medium145.copyWith(color: AppColors.textBody),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // 2. Customer Name & Address/Order ID
          Text(
            customerName,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              height: 1.12,
              letterSpacing: -0.52,
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            addressAndOrder,
            style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
          ),
          SizedBox(height: 14.h),

          // 3. Quick Action Tiles Row (Call, Note, Maps, More)
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  iconAsset: AppAssets.routeIcCall,
                  label: context.tr.routeCall,
                  onTap: () => ExternalLauncher.call(phone),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _QuickActionTile(
                  iconAsset: AppAssets.routeIcNote,
                  label: context.tr.routeNote,
                  onTap: () {
                    // TODO: Open note sheet
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _QuickActionTile(
                  iconAsset: AppAssets.routeIcNavigate,
                  label: context.tr.routeMaps,
                  onTap: onMapsTapped,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _QuickActionTile(
                  iconAsset: AppAssets.routeIcStops,
                  label: context.tr.routeMore,
                  onTap: onMoreTapped,
                ),
              ),
            ],
          ),

          // 4. Company Note Container (shown if present)
          if (companyNote != null && companyNote!.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              // Figma: radius 6, padding 12 / 10
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppAssets.routeIcNote,
                    width: 16.w,
                    height: 16.h,
                    colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      companyNote!,
                      style: AppTextStyles.s12Regular145.copyWith(color: AppColors.brandBlack),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 14.h),

          // 5. Outcome Buttons (Couldn't deliver / Delivered)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWhite,
                      // Figma: the label (16 Bold) fills the button, so no default 24 padding
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                    ),
                    onPressed: onCouldntDeliverTapped,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.tr.routeCouldntDeliver,
                        style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 56.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandMain,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                    ),
                    onPressed: onDeliveredTapped,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppAssets.routeIcDelivered,
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.tr.routeDelivered,
                              style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r8),
      child: Container(
        // Figma: #E9E9E9 tile, no border, radius 8, padding 10/8
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.deactivatedBadge,
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 22.w,
              height: 22.h,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.s12Medium145.copyWith(color: AppColors.brandBlack),
            ),
          ],
        ),
      ),
    );
  }
}
