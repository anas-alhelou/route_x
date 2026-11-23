// lib/features/orders/presentation/widgets/search/search_field_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';
import 'search_metrics.dart';

/// The search field with its scan button, and Cancel beside it.
///
/// Cancel is a word, not an ×: on a screen opened from somewhere else it has
/// to say "go back", not "clear what I typed".
class SearchFieldBar extends StatelessWidget {
  const SearchFieldBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.cancelLabel,
    required this.scanLabel,
    required this.onChanged,
    required this.onCancel,
    this.onScan,
  });

  final TextEditingController controller;
  final String hint;
  final String cancelLabel;

  /// Screen-reader label for the box icon; never painted.
  final String scanLabel;

  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.s16Regular.scaled.copyWith(
      fontSize: 18.sp,
      color: AppColors.brandBlack,
    );

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: SearchMetrics.fieldTop.h,
        start: SearchMetrics.gutter.w,
        // Cancel's own padding carries it to the gutter.
        end: (SearchMetrics.gutter - 10).w,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: SearchMetrics.fieldHeight.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceAction,
                borderRadius:
                    BorderRadius.circular(SearchMetrics.fieldRadius.r),
              ),
              child: Row(
                children: [
                  SizedBox(width: 14.w),
                  Assets.icons.svg.search.svg(
                    width: 22.w,
                    height: 22.w,
                    colorFilter: ColorFilter.mode(
                      AppColors.brandBlack,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      cursorColor: AppColors.brandBlack,
                      style: textStyle,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle:
                            textStyle.copyWith(color: AppColors.textHint),
                      ),
                    ),
                  ),
                  _ScanButton(label: scanLabel, onPressed: onScan),
                ],
              ),
            ),
          ),
          SizedBox(width: SearchMetrics.fieldToCancel.w),
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandBlack,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              minimumSize: Size(0, SearchMetrics.fieldHeight.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              cancelLabel,
              style: AppTextStyles.s16Medium.scaled.copyWith(
                fontSize: 18.sp,
                color: AppColors.brandBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onPressed,
        radius: 22.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Assets.icons.svg.package.svg(
            width: 22.w,
            height: 22.w,
            colorFilter: ColorFilter.mode(
              AppColors.brandBlack,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
