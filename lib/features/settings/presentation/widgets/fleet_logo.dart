// lib/features/settings/presentation/widgets/fleet_logo.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/nearby_fleet_entity.dart';

/// Fleet logo from [NearbyFleetEntity.logoUrl], or its initials until the
/// fleet has one.
class FleetLogo extends StatelessWidget {
  const FleetLogo({super.key, required this.fleet});

  final NearbyFleetEntity fleet;

  String get _initials => fleet.name
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final logoUrl = fleet.logoUrl;
    return Container(
      width: 42.r,
      height: 42.r,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderDeactivated),
      ),
      child: logoUrl != null
          ? Image.network(logoUrl, fit: BoxFit.cover)
          : Text(
              _initials,
              style: AppTextStyles.s14Bold.copyWith(
                fontSize: AppFonts.size14.sp,
                color: AppColors.textPrimary,
              ),
            ),
    );
  }
}
