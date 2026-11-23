// lib/features/orders/presentation/widgets/offers/offers_tab_widgets.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';
import 'order_offer_widgets.dart';

/// "3 orders waiting for you · Answer in 09:12 or they go back" — at the
/// top of the Orders tab while offers are open. Counts down by itself and
/// calls [onExpired] when the soonest offer runs out.
class OffersWaitingBanner extends StatefulWidget {
  const OffersWaitingBanner({
    super.key,
    required this.title,
    required this.subtitleFor,
    required this.actionLabel,
    required this.onView,
    this.deadline,
    this.onExpired,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final String title;

  /// Builds the line under the title from the time left, `09:12`.
  final String Function(String time) subtitleFor;

  final String actionLabel;
  final VoidCallback onView;

  /// When the soonest offer runs out; null shows no countdown.
  final DateTime? deadline;
  final VoidCallback? onExpired;
  final DateTime Function() _now;

  @override
  State<OffersWaitingBanner> createState() => _OffersWaitingBannerState();
}

class _OffersWaitingBannerState extends State<OffersWaitingBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant OffersWaitingBanner old) {
    super.didUpdateWidget(old);
    if (old.deadline != widget.deadline) _start();
  }

  void _start() {
    _timer?.cancel();
    if (widget.deadline == null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final deadline = widget.deadline;
      if (deadline != null && !widget._now().isBefore(deadline)) {
        _timer?.cancel();
        widget.onExpired?.call();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deadline = widget.deadline;
    final left = deadline == null
        ? Duration.zero
        : deadline.difference(widget._now());

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.iconBrand,
        borderRadius: BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
        // Figma OF9: 1.5dp border, 69dp tall.
        border: Border.all(color: AppColors.brandMain, width: 1.5.w),
      ),
      child: Row(
        children: [
          OfferIconWell(
            child: Assets.icons.svg.package.svg(
              width: 22.w,
              height: 22.w,
              colorFilter: ColorFilter.mode(
                AppColors.brandBlack,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s14Bold.scaled.copyWith(
                    height: 1.35,
                    color: AppColors.brandBlack,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.subtitleFor(offerClock(left)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s12Regular.scaled.copyWith(
                    fontSize: 13.sp,
                    height: 1.35,
                    color: AppColors.brandDark,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Material(
            color: AppColors.brandMain,
            borderRadius: BorderRadius.circular(999.r),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onView,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
                child: Text(
                  widget.actionLabel,
                  style: AppTextStyles.s14Bold.scaled.copyWith(
                    fontSize: 13.sp,
                    height: 1.4,
                    color: AppColors.brandBlack,
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

/// "Order declined — Red Sea Express will give it to another driver. Undo".
class OfferDeclinedToast extends StatelessWidget {
  const OfferDeclinedToast({
    super.key,
    required this.title,
    required this.message,
    required this.undoLabel,
    required this.onUndo,
    this.undoing = false,
  });

  final String title;
  final String message;
  final String undoLabel;
  final VoidCallback onUndo;
  final bool undoing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 6.w, 14.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(OrdersTodayMetrics.cardRadius.r),
          border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBlack.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.statusDangerSurface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.iconRed, width: 1.w),
              ),
              child: Icon(
                Icons.block_rounded,
                size: 22.w,
                color: AppColors.iconRed,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.s16Bold.scaled.copyWith(
                      height: 1.3,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: AppTextStyles.s14Regular.scaled.copyWith(
                      fontSize: 13.sp,
                      height: 1.3,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: undoing ? null : onUndo,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandMain,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
              ),
              child: Text(
                undoLabel,
                style: AppTextStyles.s16Bold.scaled.copyWith(
                  height: 1.4,
                  color: AppColors.brandMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
