// lib/features/orders/presentation/widgets/order_detail/message_dispatch_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';
import 'order_detail_metrics.dart';

/// The escape hatch when something on this order is wrong — last on the
/// page, after everything the driver should check first.
///
/// Neutral grey rather than brand green: green on this screen means "on
/// time / on the way", and asking dispatch for help is neither.
class MessageDispatchButton extends StatelessWidget {
  const MessageDispatchButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCanvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OrderDetailMetrics.buttonRadius.r),
        side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: OrderDetailMetrics.buttonHeight.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.svg.note.svg(
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.brandBlack,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.s16Bold.scaled.copyWith(
                      height: 1.4,
                      color: AppColors.brandBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
