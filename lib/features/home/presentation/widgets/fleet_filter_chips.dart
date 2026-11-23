// lib/features/home/presentation/widgets/fleet_filter_chips.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';

/// Horizontal filter chips for the Find a Fleet screen (Figma 5237:3435).
///
/// Figma: an 8pt-gapped row of pills — filled brand green for the selected chip,
/// hairline #D0D0D0 outline for the rest, 12pt bold labels.
///
/// The selected pill is [AppSizes.chipH34] and the unselected ones
/// [AppSizes.buttonH36], which is what the design draws: two points shorter,
/// because a filled pill without a border needs less height to look the same
/// weight as an outlined one. Centring them on a shared axis keeps the row from
/// looking stepped.
class FleetFilterChips extends StatelessWidget {
  const FleetFilterChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
    required this.labelFor,
    super.key,
  });

  final List<FleetFilter> filters;
  final FleetFilter selected;
  final ValueChanged<FleetFilter> onSelected;
  final String Function(FleetFilter) labelFor;

  @override
  Widget build(BuildContext context) {
    // Both chip heights, so the row reserves the taller one and the shorter
    // selected pill is centred rather than aligned to the top edge.
    final rowHeight = AppSizes.buttonH36.w;

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.s8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Center(
            child: _Chip(
              label: labelFor(filter),
              isSelected: filter == selected,
              onTap: () => onSelected(filter),
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.brandMain : AppColors.surfaceWhite,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? AppColors.brandMain : AppColors.borderDeactivated,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: (isSelected ? AppSizes.chipH34 : AppSizes.buttonH36).w,
          child: Padding(
            // Wide enough that "Open to join" clears its own descenders, which
            // is what the design's 28pt side inset is for.
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.s28.w,
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.chipLabel.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
