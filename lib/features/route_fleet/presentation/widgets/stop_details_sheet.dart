// lib/features/route_fleet/presentation/widgets/stop_details_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class StopDetailsSheet extends StatelessWidget {
  const StopDetailsSheet({
    super.key,
    required this.stopNumber,
    required this.totalStops,
    required this.customerName,
    required this.metaText,
    this.gateCode,
    this.timeWindow,
    this.packagesText,
    this.companyNote,
    this.phone,
    this.onCallTapped,
    this.onMessageTapped,
    required this.onBackToMapTapped,
  });

  final int stopNumber;
  final int totalStops;
  final String customerName;
  final String metaText;
  final String? gateCode;
  final String? timeWindow;
  final String? packagesText;
  final String? companyNote;
  final String? phone;
  final VoidCallback? onCallTapped;
  final VoidCallback? onMessageTapped;
  final VoidCallback onBackToMapTapped;

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
              context.tr.routeNextStopOf(stopNumber.toString(), totalStops.toString()),
              style: AppTextStyles.s10Bold.copyWith(
                color: AppColors.textBody,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),

            // 2. Name
            Text(
              customerName,
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

            // 4. Details list (hide if all detail fields are null/empty)
            if ((gateCode != null && gateCode!.isNotEmpty) ||
                (timeWindow != null && timeWindow!.isNotEmpty) ||
                (packagesText != null && packagesText!.isNotEmpty)) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(AppSizes.r16),
                  border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (gateCode != null && gateCode!.isNotEmpty) ...[
                      _buildDetailRow(context.tr.routeGateCode, gateCode!),
                    ],
                    if (timeWindow != null && timeWindow!.isNotEmpty) ...[
                      _buildDetailRow(context.tr.routeTimeWindow, timeWindow!),
                    ],
                    if (packagesText != null && packagesText!.isNotEmpty) ...[
                      _buildDetailRow(context.tr.routePackages, packagesText!),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // 5. Note row (if present)
            if (companyNote != null && companyNote!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppAssets.routeIcNote,
                    width: 18.w,
                    height: 18.h,
                    colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      companyNote!,
                      style: AppTextStyles.s14Medium.copyWith(color: AppColors.brandBlack),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],

            // 6. Actions row (Call & Message) - hide if phone is null/empty
            if (phone != null && phone!.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52.h,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.brandBackground,
                          side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                        ),
                        onPressed: onCallTapped,
                        child: Text(
                          context.tr.routeCall,
                          style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: SizedBox(
                      height: 52.h,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.brandBackground,
                          side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                        ),
                        onPressed: onMessageTapped,
                        child: Text(
                          context.tr.routeMessage,
                          style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],

            // 7. Back to map button
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
                onPressed: onBackToMapTapped,
                child: Text(
                  context.tr.routeBackToMap,
                  style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.s14Regular.copyWith(color: AppColors.textBody),
          ),
          Text(
            value,
            style: AppTextStyles.s14Bold.copyWith(color: AppColors.brandBlack),
          ),
        ],
      ),
    );
  }
}
