// lib/features/orders/presentation/widgets/history/history_primary_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';

/// The full-width green action — "Send to dispatch", "Sync now". Shows a
/// spinner in place of its label while [busy], and ignores taps then.
class HistoryPrimaryButton extends StatelessWidget {
  const HistoryPrimaryButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;

  /// Null disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null || busy;

    return Material(
      color: enabled ? AppColors.brandMain : AppColors.surfaceEmpty,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : onPressed,
        child: SizedBox(
          height: 56.h,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.brandBlack,
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.s16Bold.scaled.copyWith(
                      color: enabled
                          ? AppColors.brandBlack
                          : AppColors.textMuted,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
