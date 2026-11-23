// lib/features/route_fleet/presentation/widgets/map_type_selector_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

enum MapLayerStyle { normal, satellite, terrain }

class MapTypeSelectorBottomSheet extends StatefulWidget {
  const MapTypeSelectorBottomSheet({
    super.key,
    required this.currentStyle,
    required this.trafficEnabled,
    required this.onStyleChanged,
    required this.onTrafficToggled,
  });

  final MapLayerStyle currentStyle;
  final bool trafficEnabled;
  final ValueChanged<MapLayerStyle> onStyleChanged;
  final ValueChanged<bool> onTrafficToggled;

  @override
  State<MapTypeSelectorBottomSheet> createState() => _MapTypeSelectorBottomSheetState();
}

class _MapTypeSelectorBottomSheetState extends State<MapTypeSelectorBottomSheet> {
  // Local temporary state variables to delay applying changes until Done is pressed
  late MapLayerStyle _tempSelectedStyle = widget.currentStyle;
  late bool _tempTraffic = widget.trafficEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            context.tr.routeMapLayersStyle,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 16.h),
          _MapTypeOption(
            title: context.tr.routeMapStandard,
            subtitle: context.tr.routeMapStandardSub,
            icon: Icons.map_rounded,
            isSelected: _tempSelectedStyle == MapLayerStyle.normal,
            onTap: () {
              setState(() => _tempSelectedStyle = MapLayerStyle.normal);
            },
          ),
          SizedBox(height: 12.h),
          _MapTypeOption(
            title: context.tr.routeMapSatellite,
            subtitle: context.tr.routeMapSatelliteSub,
            icon: Icons.satellite_alt_rounded,
            isSelected: _tempSelectedStyle == MapLayerStyle.satellite,
            onTap: () {
              setState(() => _tempSelectedStyle = MapLayerStyle.satellite);
            },
          ),
          SizedBox(height: 12.h),
          _MapTypeOption(
            title: context.tr.routeMapTerrain,
            subtitle: context.tr.routeMapTerrainSub,
            icon: Icons.terrain_rounded,
            isSelected: _tempSelectedStyle == MapLayerStyle.terrain,
            onTap: () {
              setState(() => _tempSelectedStyle = MapLayerStyle.terrain);
            },
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: AppColors.slateBorder),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr.routeShowTraffic,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandBlack,
                ),
              ),
              Switch.adaptive(
                value: _tempTraffic,
                activeTrackColor: AppColors.brandMain,
                onChanged: (val) {
                  setState(() => _tempTraffic = val);
                },
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Center(
            child: SizedBox(
              width: 360.w,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  // Apply temporary selections to parent state and close sheet
                  widget.onStyleChanged(_tempSelectedStyle);
                  widget.onTrafficToggled(_tempTraffic);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMain,
                  foregroundColor: AppColors.onBrand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                child: Text(
                  context.tr.routeDone,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
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

class _MapTypeOption extends StatelessWidget {
  const _MapTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.limePale2 : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.brandMain : AppColors.slateBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isSelected ? AppColors.brandBlack : AppColors.slateMuted),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.slateMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1.0 : 0.5,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.brandMain,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
