// lib/features/orders/presentation/widgets/order_offer_notification_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';

import 'orders_today/orders_today_metrics.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// The new-order notification (Figma NF1, NF2), shown over the app the way
/// the system would show it on the lock screen: one order with Decline and
/// Accept, or a group with View orders and the stack behind it.
///
/// Design only for now — the push itself arrives once Firebase Messaging
/// is wired up.
class OrderOfferNotificationDialog extends StatelessWidget {
  const OrderOfferNotificationDialog({
    required this.offer,
    required this.onAccept,
    required this.onDecline,
    required this.onViewOrders,
    super.key,
  });

  final OrderOfferEntity offer;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewOrders;

  static Future<void> show({
    required BuildContext context,
    required OrderOfferEntity offer,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
    required VoidCallback onViewOrders,
  }) {
    return showRoutexDialog<void>(
      context: context,
      barrierColor: AppColors.brandBlack.withAlpha(150),
      builder: (_) => OrderOfferNotificationDialog(
        offer: offer,
        onAccept: onAccept,
        onDecline: onDecline,
        onViewOrders: onViewOrders,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void close(VoidCallback then) {
      Navigator.of(context).pop();
      then();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: OrderOfferNotificationCard(
        offer: offer,
        onAccept: () => close(onAccept),
        onDecline: () => close(onDecline),
        onViewOrders: () => close(onViewOrders),
      ),
    );
  }
}

/// The notification itself — usable on its own, e.g. as an in-app banner.
class OrderOfferNotificationCard extends StatelessWidget {
  const OrderOfferNotificationCard({
    super.key,
    required this.offer,
    required this.onAccept,
    required this.onDecline,
    required this.onViewOrders,
  });

  final OrderOfferEntity offer;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewOrders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final single = offer.orders.length == 1;
    final order = offer.orders.first;
    final packages =
        offer.orders.fold<int>(0, (total, o) => total + o.packagesCount);
    final areas = offer.orders.map((o) => o.area).toSet().join(', ');

    final card = Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _AppIcon(),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  single
                      ? l10n.orderOfferNotificationAppLabel
                      : l10n.orderOfferNotificationGroupAppLabel(
                          offer.orders.length,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s12SemiBold.scaled.copyWith(
                    height: 1.4,
                    letterSpacing: 0.8.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            single
                ? l10n.orderOfferNotificationSingleTitle(
                    order.customerName,
                    order.area,
                  )
                : l10n.orderOfferNotificationGroupTitle(offer.orders.length),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.s16Bold.scaled.copyWith(
              fontSize: 17.sp,
              height: 1.3,
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            single
                ? l10n.orderOfferNotificationDetails(
                    packages,
                    offer.distanceLabel,
                    offer.deadlineLabel,
                  )
                : l10n.orderOfferNotificationGroupDetails(
                    areas,
                    offer.distanceLabel,
                    offer.deadlineLabel,
                  ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.s14Regular.scaled.copyWith(
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 12.h),
          if (single)
            Row(
              children: [
                Expanded(
                  child: _NotificationButton(
                    label: l10n.orderOfferNotificationDecline,
                    filled: false,
                    onPressed: onDecline,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _NotificationButton(
                    label: l10n.orderOfferNotificationAccept,
                    filled: true,
                    onPressed: onAccept,
                  ),
                ),
              ],
            )
          else
            _NotificationButton(
              label: l10n.orderOfferNotificationViewOrders,
              filled: true,
              onPressed: onViewOrders,
            ),
        ],
      ),
    );

    if (single) return card;

    // A group arrives as one notification on top of the ones it gathers —
    // two faded edges peek out under the card.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        card,
        _StackEdge(inset: 12.w, alpha: 0.75),
        _StackEdge(inset: 24.w, alpha: 0.5),
      ],
    );
  }
}

/// The RouteX mark in its rounded green-outlined square.
class _AppIcon extends StatelessWidget {
  const _AppIcon();

  @override
  Widget build(BuildContext context) {
    final size = 20.w;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: AppColors.brandMain, width: 1.w),
      ),
      child: Center(child: Assets.icons.svg.icLogo.svg(width: size)),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.brandMain : AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: filled
            ? BorderSide.none
            : BorderSide(color: AppColors.borderDeactivated, width: 1.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 40.h,
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.s16Bold.scaled.copyWith(
                height: 1.3,
                color: AppColors.brandBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StackEdge extends StatelessWidget {
  const _StackEdge({required this.inset, required this.alpha});

  final double inset;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: Container(
        height: 14.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite.withValues(alpha: alpha),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(OrdersTodayMetrics.cardRadius.r),
          ),
        ),
      ),
    );
  }
}
