// lib/features/orders/presentation/widgets/orders_today/orders_arrival_toast.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today_metrics.dart';

/// "2 orders added to tomorrow" — floats above the bottom bar for a few
/// seconds when a refresh brings in orders, then gets out of the way.
///
/// A toast, not a banner: the orders already sit in the list with their
/// "N new" pill, so this only has to catch the eye at the moment they land.
/// It needs no action and must not shift the list under the driver's thumb.
///
/// Shows each [arrivalId] once. A later rebuild carrying the same id — the
/// state keeps the last arrival around — does not bring it back.
class OrdersArrivalToast extends StatefulWidget {
  const OrdersArrivalToast({
    super.key,
    required this.arrivalId,
    required this.label,
  });

  /// Null before any orders have arrived.
  final int? arrivalId;

  final String label;

  /// How long the toast stays before it leaves by itself.
  static const Duration visibleFor = Duration(seconds: 4);

  @override
  State<OrdersArrivalToast> createState() => _OrdersArrivalToastState();
}

class _OrdersArrivalToastState extends State<OrdersArrivalToast> {
  static const _motion = Duration(milliseconds: 250);

  int? _shownId;
  bool _visible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _maybeShow();
  }

  @override
  void didUpdateWidget(OrdersArrivalToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeShow();
  }

  void _maybeShow() {
    final id = widget.arrivalId;
    if (id == null || id == _shownId) return;
    _shownId = id;
    _visible = true;
    _hideTimer?.cancel();
    _hideTimer = Timer(OrdersArrivalToast.visibleFor, _hide);
  }

  void _hide() {
    _hideTimer?.cancel();
    if (mounted && _visible) setState(() => _visible = false);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedSlide(
        duration: _motion,
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.4),
        child: AnimatedOpacity(
          duration: _motion,
          opacity: _visible ? 1 : 0,
          child: Semantics(
            liveRegion: true,
            button: true,
            child: GestureDetector(
              // Tapping only dismisses it early; the orders are in the list.
              onTap: _hide,
              child: Container(
                // Figma O12: 252×47 pill, 20 from the edge to the icon.
                padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: AppColors.borderDeactivated,
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandBlack.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.icons.svg.delivered.svg(width: 20.w, height: 20.w),
                    SizedBox(width: 9.w),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s14SemiBold.scaled
                            .copyWith(height: 1.4, color: AppColors.brandBlack),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
