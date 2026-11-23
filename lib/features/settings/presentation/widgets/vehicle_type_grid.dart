// lib/features/settings/presentation/widgets/vehicle_type_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'vehicle_type_label.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Two-by-two grid of the vehicle types on the settings vehicle page. The
/// selected card gets the brand border, a light tint and a check badge.
class VehicleTypeGrid extends StatelessWidget {
  const VehicleTypeGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const types = ['motorcycle', 'car', 'van', 'truck'];

  /// Selected vehicle key, or null.
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < types.length; i += 2) ...[
          if (i > 0) SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _card(context, types[i])),
              SizedBox(width: 12.w),
              Expanded(child: _card(context, types[i + 1])),
            ],
          ),
        ],
      ],
    );
  }

  Widget _card(BuildContext context, String type) {
    return _VehicleTypeCard(
      key: Key('vehicle_page_$type'),
      label: context.vehicleTypeLabel(type),
      icon: vehicleTypeIcon(type),
      isSelected: selected == type,
      onTap: () => onSelected(type),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  const _VehicleTypeCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  static const _duration = Duration(milliseconds: 200);

  final String label;
  final SvgGenImage icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.r);
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeInOut,
        height: 106.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.iconBrand : AppColors.surfaceWhite,
          borderRadius: radius,
          border: Border.all(
            color: isSelected ? AppColors.brandMain : AppColors.borderDeactivated,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon.svg(
                    height: 34.h,
                    colorFilter: ColorFilter.mode(
                      AppColors.brandDeepBlack,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    label,
                    style: AppTextStyles.s20Bold.copyWith(
                      fontSize: AppFonts.size20.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 8.r,
              end: 8.r,
              child: AnimatedScale(
                scale: isSelected ? 1 : 0,
                duration: _duration,
                curve: Curves.easeInOut,
                child: Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: const BoxDecoration(
                    color: AppColors.brandMain,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, size: 16.r, color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
