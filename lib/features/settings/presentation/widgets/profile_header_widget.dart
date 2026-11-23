// lib/features/settings/presentation/widgets/profile_header_widget.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/driver_profile_entity.dart';
import 'settings_section_card.dart';
import 'vehicle_type_label.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    required this.onEditPressed,
    this.onVehiclePressed,
  });

  final DriverProfileEntity profile;
  final VoidCallback onEditPressed;
  final VoidCallback? onVehiclePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: settingsCardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(4.w, 4.h, 4.w, 0),
            child: Row(
              children: [
                _Avatar(name: profile.name, photoPath: profile.photoPath),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s20Bold.copyWith(
                          fontSize: AppFonts.size20.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Phone numbers stay LTR in Arabic too.
                      Text(
                        profile.phone,
                        textDirection: TextDirection.ltr,
                        style: AppTextStyles.s14Regular.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.brandMain,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onEditPressed,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 48.r,
                      height: 48.r,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 22.r,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          // The whole strip (vehicle, plate) opens the vehicle page.
          Material(
            color: AppColors.iconBrand,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              onTap: onVehiclePressed,
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _Stat(
                        value: context.vehicleTypeLabel(profile.vehicleType),
                        label: context.tr.settingsVehicle,
                      ),
                      const _StatDivider(),
                      _Stat(
                        value: profile.vehicleNumber,
                        label: context.tr.settingsPlate,
                      ),
                    ],
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.photoPath});

  final String name;
  final String? photoPath;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'DR';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58.r,
      height: 58.r,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandMain, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.iconBrand,
        backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
        child: photoPath != null
            ? null
            : Text(
                _initials,
                style: AppTextStyles.s16Bold.copyWith(
                  fontSize: AppFonts.size16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s16Bold.copyWith(
                fontSize: AppFonts.size16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.s12Regular.copyWith(
                fontSize: 13.sp,
                height: 1.3,
                color: AppColors.textPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: AppColors.borderDeactivated,
    );
  }
}
