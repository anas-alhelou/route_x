// lib/features/orders/presentation/widgets/orders_today/orders_today_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today_metrics.dart';

/// Screen title and the search affordance.
///
/// The two sit at different distances from the top (12dp for the title,
/// 8dp for the search button) so their *optical* centres line up — the
/// title's line box carries more air above its caps than the circle does.
/// A [Stack] is what keeps both offsets exact; a Row with
/// `crossAxisAlignment` would split the difference and honour neither.
///
/// The header stays on screen in every state — it is the one part of the
/// page the driver can act on before the data arrives.
class OrdersTodayHeader extends StatelessWidget {
  const OrdersTodayHeader({
    super.key,
    required this.title,
    required this.searchLabel,
    this.onSearchPressed,
    this.compactSearch = false,
  });

  final String title;

  /// Screen-reader label for the search button; never painted.
  final String searchLabel;

  final VoidCallback? onSearchPressed;

  /// Figma O00: while the plan loads the search button is a 44dp circle
  /// instead of the 70dp pill.
  final bool compactSearch;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.s28Bold.scaled.copyWith(
      height: 1.15,
      letterSpacing: -0.28.sp,
      color: AppColors.brandBlack,
    );
    final titleHeight =
        (titleStyle.fontSize ?? 0) * (titleStyle.height ?? 1.0);

    return SizedBox(
      height: OrdersTodayMetrics.titleTop.h + titleHeight,
      child: Stack(
        // The search button is sized in `.w` and the box in `.h`; on an
        // unusually wide screen those diverge far enough to clip it.
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            top: OrdersTodayMetrics.titleTop.h,
            start: OrdersTodayMetrics.gutter.w,
            child: Text(title, style: titleStyle),
          ),
          PositionedDirectional(
            top: OrdersTodayMetrics.searchTop.h,
            end: OrdersTodayMetrics.gutter.w,
            child: _SearchButton(
              label: searchLabel,
              onPressed: onSearchPressed,
              compact: compactSearch,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({
    required this.label,
    this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = OrdersTodayMetrics.searchSize.w;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.surfaceWhite,
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.borderDeactivated, width: 1.w),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: (compact
                    ? OrdersTodayMetrics.searchSize
                    : OrdersTodayMetrics.searchWidth)
                .w,
            height: height,
            child: Center(
              child: Assets.icons.svg.search28.svg(width: 28.w, height: 28.w),
            ),
          ),
        ),
      ),
    );
  }
}
