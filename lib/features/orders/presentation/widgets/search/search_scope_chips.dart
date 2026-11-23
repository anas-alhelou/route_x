// lib/features/orders/presentation/widgets/search/search_scope_chips.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../../domain/entities/order_search_result_entity.dart';

import '../orders_today/orders_today_metrics.dart';
import 'search_metrics.dart';

/// All / Today / Upcoming — narrows the results without touching the query.
///
/// The selected chip is solid black rather than brand green: green on these
/// screens marks the driver's current stop, and a filter is not that.
class SearchScopeChips extends StatelessWidget {
  const SearchScopeChips({
    super.key,
    required this.scope,
    required this.labels,
    required this.onChanged,
  });

  final OrderSearchScope scope;

  /// One localized label per scope, in [OrderSearchScope.values] order.
  final Map<OrderSearchScope, String> labels;

  final ValueChanged<OrderSearchScope> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Scrolls rather than wraps when Arabic labels or a large system font
      // make the three chips wider than the screen.
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: SearchMetrics.gutter.w),
      child: Row(
        children: [
          for (final value in OrderSearchScope.values) ...[
            if (value != OrderSearchScope.values.first)
              SizedBox(width: SearchMetrics.chipGap.w),
            _ScopeChip(
              label: labels[value] ?? value.name,
              selected: value == scope,
              onTap: () => onChanged(value),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SearchMetrics.chipHeight.r / 2);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.brandBlack : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: selected
              ? BorderSide.none
              : BorderSide(color: AppColors.borderDeactivated, width: 1.w),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: SearchMetrics.chipHeight.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.s16Medium.scaled.copyWith(
                color:
                    selected ? AppColors.surfaceWhite : AppColors.brandBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
