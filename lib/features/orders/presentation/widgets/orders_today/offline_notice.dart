// lib/features/orders/presentation/widgets/orders_today/offline_notice.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today_metrics.dart';

/// "Showing saved orders · Updated 9:42" — a quiet line, not a red banner.
///
/// The list under it is still the right list, almost always: losing signal
/// in a car park changes nothing about where the driver is going. The notice
/// only has to stop them trusting a change that has not arrived yet, so it
/// says how old the copy is and gets out of the way.
///
/// Owns the whole gap under the segmented control: the plain 24dp when
/// online, or the notice with its own spacing when not. Animates between the
/// two, so the list slides rather than jumps when the signal comes and goes.
class OfflineNotice extends StatelessWidget {
  const OfflineNotice({
    super.key,
    required this.visible,
    required this.label,
    this.top = OrdersTodayMetrics.segmentedToOfflineNotice,
    this.bottom = OrdersTodayMetrics.offlineNoticeToContent,
    this.hiddenHeight = OrdersTodayMetrics.segmentedToBanner,
  });

  final bool visible;
  final String label;

  /// Space above and below the line while shown, and the gap kept while
  /// hidden — design units. Default to the Orders tab's.
  final double top;
  final double bottom;
  final double hiddenHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !visible
          ? SizedBox(
              width: double.infinity,
              height: hiddenHeight.h,
            )
          : Semantics(
              liveRegion: true,
              child: Padding(
                padding: EdgeInsets.only(
                  left: OrdersTodayMetrics.gutter.w,
                  right: OrdersTodayMetrics.gutter.w,
                  top: top.h,
                  bottom: bottom.h,
                ),
                child: Row(
                  children: [
                    Assets.icons.svg.offline.svg(width: 16.w, height: 16.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s14Regular.scaled
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
