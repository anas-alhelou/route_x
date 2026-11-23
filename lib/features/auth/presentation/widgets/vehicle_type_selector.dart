import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Two-by-two grid of vehicle type cards (motorcycle, car, van, truck).
/// The currently selected card is highlighted with a brand border, tinted
/// fill and a check badge.
class VehicleTypeSelector extends StatelessWidget {
  const VehicleTypeSelector({
    super.key,
    required this.selectedVehicle,
    required this.onSelected,
    this.cardHeight = 124,
  });

  /// Shared timing for the selection transition (border, fill and badge).
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const Curve _animationCurve = Curves.easeInOut;

  /// Currently selected vehicle key, or null when nothing is chosen.
  final String? selectedVehicle;

  /// Reports the tapped vehicle key (e.g. `motorcycle`).
  final ValueChanged<String> onSelected;

  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final types = [
      {
        'key': 'motorcycle',
        'label': context.tr.vehicleMotorcycle,
        'icon': Assets.icons.svg.icMotorcycle,
      },
      {
        'key': 'car',
        'label': context.tr.vehicleCar,
        'icon': Assets.icons.svg.icCar,
      },
      {
        'key': 'van',
        'label': context.tr.vehicleVan,
        'icon': Assets.icons.svg.icVan,
      },
      {
        'key': 'truck',
        'label': context.tr.vehicleTruck,
        'icon': Assets.icons.svg.icTruck,
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCard(types[0])),
            SizedBox(width: 24.w),
            Expanded(child: _buildCard(types[1])),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildCard(types[2])),
            SizedBox(width: 24.w),
            Expanded(child: _buildCard(types[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> type) {
    final isSelected = selectedVehicle == type['key'];
    return RouteXTapScale(
      key: Key('vehicle_${type['key']}'),
      onTap: () => onSelected(type['key'] as String),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: _animationDuration,
            curve: _animationCurve,
            height: cardHeight.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.brandMain.withAlpha(26) // ~10% opacity
                  : AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.brandMain
                    : AppColors.borderDeactivated,
                width: isSelected ? 2.w : 1.w,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (type['icon'] as SvgGenImage).svg(
                  width: 32.sp,
                  height: 32.sp,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.brandMain : AppColors.brandDeepBlack,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  type['label'] as String,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.brandMain
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -8.h,
            right: -8.w,
            child: AnimatedScale(
              scale: isSelected ? 1 : 0,
              duration: _animationDuration,
              curve: _animationCurve,
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: AppColors.brandMain,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.brandWhite,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
