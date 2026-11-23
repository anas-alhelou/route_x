// lib/features/orders/presentation/widgets/search/search_no_results.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

import '../orders_empty_state.dart';

/// Shown when a query matches nothing: says so in the driver's own words,
/// suggests what to try instead, and offers the one search that cannot be
/// misspelled — scanning the label on the package in their hand.
class SearchNoResults extends StatelessWidget {
  const SearchNoResults({
    super.key,
    required this.title,
    required this.hint,
    required this.scanLabel,
    this.onScan,
  });

  final String title;
  final String hint;
  final String scanLabel;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return OrdersEmptyState(
      icon: Assets.icons.svg.search.svg(
        width: 40.w,
        height: 40.w,
        colorFilter: ColorFilter.mode(
          AppColors.textMuted,
          BlendMode.srcIn,
        ),
      ),
      title: title,
      message: hint,
      actionIcon: Assets.icons.svg.package.svg(
        width: 24.w,
        height: 24.w,
        colorFilter: ColorFilter.mode(
          AppColors.brandBlack,
          BlendMode.srcIn,
        ),
      ),
      actionLabel: scanLabel,
      onAction: onScan,
    );
  }
}
