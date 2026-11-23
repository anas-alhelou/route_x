import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class DeliveredToast extends StatelessWidget {
  const DeliveredToast({
    super.key,
    this.customerName,
    this.customMessage,
    this.onUndoTapped,
  });

  final String? customerName;
  final String? customMessage;
  final VoidCallback? onUndoTapped;

  @override
  Widget build(BuildContext context) {
    final displayText = customMessage ?? (customerName != null ? context.tr.routeDeliveredTo(customerName!) : context.tr.routeDelivered);
    final showUndo = customMessage == null && onUndoTapped != null;

    return Container(
      constraints: BoxConstraints(maxWidth: 340.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r100),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.toastShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            customMessage != null ? AppAssets.routeIcReview : AppAssets.routeIcDelivered,
            width: 20.w,
            height: 20.h,
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              displayText,
              style: AppTextStyles.s14Bold14.copyWith(color: AppColors.brandBlack),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (showUndo) ...[
            SizedBox(width: 10.w),
            Container(
              width: 1.w,
              height: 18.h,
              color: AppColors.borderDeactivated,
            ),
            SizedBox(width: 10.w),
            InkWell(
              onTap: onUndoTapped,
              child: Text(
                context.tr.routeUndo,
                style: AppTextStyles.s14Bold14.copyWith(color: AppColors.undoText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
