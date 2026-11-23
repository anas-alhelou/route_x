// lib/features/route_fleet/presentation/widgets/hand_back_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

class HandBackSheet extends StatefulWidget {
  const HandBackSheet({
    super.key,
    required this.packageCount,
    required this.customerName,
    required this.orderId,
    required this.failureReason,
    required this.onReturnedTapped,
  });

  final int packageCount;
  final String customerName;
  final String orderId;
  final String failureReason;
  final VoidCallback onReturnedTapped;

  @override
  State<HandBackSheet> createState() => _HandBackSheetState();
}

class _HandBackSheetState extends State<HandBackSheet> {
  bool _isChecked = true;

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
              context.tr.routeAtTheDepot,
              style: AppTextStyles.s10Bold.copyWith(
                color: AppColors.textBody,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),

            // 2. Title
            Text(
              widget.packageCount > 1
                  ? context.tr.routeHandBackMany(widget.packageCount.toString())
                  : context.tr.routeHandBackOne(widget.packageCount.toString()),
              style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
            ),
            SizedBox(height: 12.h),

            // 3. Detail (Figma: 13 Regular)
            Text(
              context.tr.routeHandBackDesc,
              style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
            ),
            SizedBox(height: 12.h),

            // 4. Checklist item
            RouteXTapScale(
              onTap: () => setState(() => _isChecked = !_isChecked),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: _isChecked ? AppColors.brandMain : AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(7.r),
                        border: Border.all(
                          color: _isChecked ? AppColors.brandMain : AppColors.borderDeactivated,
                          width: _isChecked ? 1.w : 1.5.w, // Figma: unchecked border 1.5
                        ),
                      ),
                      child: _isChecked
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
                            '${widget.customerName} · ${widget.orderId}',
                            style: AppTextStyles.s15Bold135.copyWith(color: AppColors.brandBlack),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            widget.failureReason,
                            style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // 5. Button
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked ? AppColors.brandMain : AppColors.deactivatedBadge,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                onPressed: _isChecked ? widget.onReturnedTapped : null,
                child: Text(
                  context.tr.routeReturnedEndDay,
                  style: AppTextStyles.s16Bold.copyWith(
                    color: _isChecked ? AppColors.brandBlack : AppColors.textBody,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
