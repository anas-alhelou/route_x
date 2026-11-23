// lib/features/orders/presentation/widgets/orders_today/orders_section_label.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import 'orders_today_metrics.dart';

/// A small-caps section heading with an optional right-hand summary
/// ("3 left · done by 12:40").
///
/// Sits on its own 30dp gutter, 4dp further in than the cards below it, so
/// the label's letterforms align with the card *content* instead of the card
/// border.
class OrdersSectionLabel extends StatelessWidget {
  const OrdersSectionLabel({super.key, required this.label, this.trailing});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: OrdersTodayMetrics.labelGutter.w,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.s10Bold.scaled.copyWith(
                height: 1.4,
                color: AppColors.textMuted,
                letterSpacing: 0.2.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: AppTextStyles.s12Medium.scaled
                  .copyWith(height: 1.4, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
