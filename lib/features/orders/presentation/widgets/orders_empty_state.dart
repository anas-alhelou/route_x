// lib/features/orders/presentation/widgets/orders_empty_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today/orders_today_metrics.dart';
import 'package:routex_mobile/core/widgets/routex_pop_in.dart';

/// The shared "nothing here" layout for the orders screens: a grey icon
/// well, a one-line verdict, a sentence on what happens next, and the one
/// action that gets the driver somewhere useful instead.
///
/// One component for every empty screen, so a driver who has met it once
/// knows where the way out is on all of them.
class OrdersEmptyState extends StatelessWidget {
  const OrdersEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.tone = OrdersEmptyStateTone.neutral,
  });

  /// Drawn centred in the well.
  final Widget icon;

  final String title;
  final String message;
  final String actionLabel;

  /// Leads the action label on a neutral button; the error tone's filled
  /// button carries no icon.
  final Widget? actionIcon;

  final VoidCallback? onAction;
  final OrdersEmptyStateTone tone;

  /// Inset of the whole block from each screen edge.
  static const double sideInset = 56;

  @override
  Widget build(BuildContext context) {
    final isError = tone == OrdersEmptyStateTone.error;
    final wellSize = (isError ? 64.0 : 80.0).w;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sideInset.w),
      child: Column(
        children: [
          RouteXPopIn(
            child: Container(
              width: wellSize,
              height: wellSize,
              decoration: BoxDecoration(
                color: isError ? AppColors.iconWarning : AppColors.surfaceBadge,
                shape: BoxShape.circle,
                border: isError
                    ? Border.all(color: AppColors.error, width: 1.w)
                    : null,
              ),
              child: Center(child: icon),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.s20SemiBold.scaled
                .copyWith(color: AppColors.brandBlack),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.s14Regular.scaled.copyWith(
              fontSize: 15.sp,
              height: 20 / 15,
              color: AppColors.textMuted,
            ),
          ),
          // The error tone's button is the only way forward, so it stands
          // further off the copy and wears the primary colour.
          SizedBox(height: (isError ? 28 : 18).h),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: isError ? AppColors.brandMain : AppColors.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular((isError ? 10 : 12).r),
                side: isError
                    ? BorderSide.none
                    : BorderSide(
                        color: AppColors.borderDeactivated,
                        width: 1.w,
                      ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onAction,
                child: SizedBox(
                  height: 56.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (actionIcon != null) ...[
                          actionIcon!,
                          SizedBox(width: 12.w),
                        ],
                        Flexible(
                          child: Text(
                            actionLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.s16SemiBold.scaled.copyWith(
                              fontSize: 18.sp,
                              color: AppColors.brandBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum OrdersEmptyStateTone {
  /// Nothing here, and that is fine: grey well, outlined secondary action.
  neutral,

  /// Something failed: red well, and the action is the primary way out.
  error,
}
