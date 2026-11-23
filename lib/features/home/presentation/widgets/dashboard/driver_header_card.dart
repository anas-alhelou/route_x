// lib/features/home/presentation/widgets/dashboard/driver_header_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/location_entity.dart';

/// Dashboard header: avatar, greeting, vehicle info, rating and location, plus
/// settings and profile actions.
class DriverHeaderCard extends StatelessWidget {
  const DriverHeaderCard({
    required this.driver,
    required this.onSettingsTap,
    required this.onProfileTap,
    this.location,
    super.key,
  });

  final DriverEntity driver;
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;
  final LocationEntity? location;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowCard.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(path: driver.profileImageUrl, initials: driver.fullName),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  driver.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                _VehicleLine(driver: driver),
                if (location != null) ...[
                  SizedBox(height: 6.h),
                  _LocationLine(address: location!.address),
                ],
              ],
            ),
          ),
          _IconAction(icon: Icons.settings_outlined, onTap: onSettingsTap),
          SizedBox(width: 4.w),
          _IconAction(icon: Icons.person_outline, onTap: onProfileTap),
        ],
      ),
    );
  }
}

class _VehicleLine extends StatelessWidget {
  const _VehicleLine({required this.driver});

  final DriverEntity driver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.two_wheeler_outlined, size: 16.r, color: AppColors.textMuted),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            '${driver.vehicleType} · ${driver.vehicleNumber}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _bodyStyle,
          ),
        ),
        SizedBox(width: 8.w),
        Icon(Icons.star_rounded, size: 16.r, color: AppColors.warning),
        SizedBox(width: 2.w),
        Text(driver.rating.toStringAsFixed(2), style: _bodyStyle),
      ],
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16.r, color: AppColors.brandMain),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _bodyStyle,
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(icon, size: 22.r, color: AppColors.textPrimary),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.path, required this.initials});

  final String? path;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Driver avatar for $initials',
      child: Container(
        width: 52.r,
        height: 52.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandMain, width: 2.w),
          color: AppColors.surfaceTint,
        ),
        clipBehavior: Clip.antiAlias,
        child: path == null
            ? _Initials(text: initials)
            : CachedNetworkImage(
                imageUrl: path!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => _Initials(text: initials),
              ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final initials = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppFonts.fontFamilySatoshi,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.brandBlack,
        ),
      ),
    );
  }
}

TextStyle get _bodyStyle => TextStyle(
      fontFamily: AppFonts.fontFamilySatoshi,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );
