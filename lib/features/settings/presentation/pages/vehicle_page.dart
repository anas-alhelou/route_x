// lib/features/settings/presentation/pages/vehicle_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/vehicle_type_label.dart';

/// The driver's vehicle, read-only: the delivery company assigns and manages
/// it, so the driver can only look and contact the company for changes.
class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key, required this.profile});

  final DriverProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final typeLabel = context.vehicleTypeLabel(profile.vehicleType);
    final capacity = profile.loadCapacityKg;
    final rows = <({String label, String value})>[
      (label: tr.vehicleType, value: typeLabel),
      (label: tr.vehiclePagePlate, value: profile.vehicleNumber),
      if (profile.vehicleColour case final colour?)
        (label: tr.vehicleColour, value: colour),
      if (capacity != null)
        (
          label: tr.vehiclePageCapacity,
          value:
              '${NumberFormat.decimalPattern(Localizations.localeOf(context).toString()).format(capacity)} ${tr.vehiclePageKg}',
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.settingsVehicle,
              subtitle: switch (profile.companyName) {
                final company? => tr.vehicleManagedBy(company),
                null => tr.vehicleManagedByYourCompany,
              },
              framedBack: true,
            ),
            SizedBox(height: 20.h),
            _ManagedNotice(text: tr.vehicleCompanyManages),
            SizedBox(height: 16.h),
            SettingsCard(
              spacing: 0,
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 22.h, 16.w, 15.h),
              children: [
                _VehicleSummary(
                  vehicleType: profile.vehicleType,
                  title: profile.vehicleModel ?? typeLabel,
                  typeLabel: typeLabel,
                ),
                SizedBox(height: 12.h),
                for (var i = 0; i < rows.length; i++)
                  _DetailRow(
                    label: rows[i].label,
                    value: rows[i].value,
                    showDivider: i < rows.length - 1,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Gray box with a lock explaining who changes the vehicle.
class _ManagedNotice extends StatelessWidget {
  const _ManagedNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceEmpty.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 24.r, color: AppColors.textPrimary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.s14Regular.copyWith(
                fontSize: AppFonts.size14.sp,
                height: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vehicle icon in a tinted circle, the model name and a type chip.
class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({
    required this.vehicleType,
    required this.title,
    required this.typeLabel,
  });

  final String vehicleType;
  final String title;
  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.r,
          height: 48.r,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.iconBrand,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brandMain, width: 1.5),
          ),
          child: vehicleTypeIcon(vehicleType).svg(
            colorFilter: ColorFilter.mode(
              AppColors.brandDeepBlack,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s24Bold.copyWith(
                  fontSize: 20.sp,
                  height: 1.3,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsetsDirectional.fromSTEB(10.w, 4.h, 11.w, 4.h),
                decoration: BoxDecoration(
                  color: AppColors.iconBrand,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.brandMain),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: AppColors.brandMain,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      typeLabel,
                      style: AppTextStyles.s14Bold.copyWith(
                        fontSize: 13.sp,
                        height: 1.3,
                        color: AppColors.brandMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Label on the start side, value on the end side, a rule underneath.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.5.h),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: AppColors.surfaceEmpty))
            : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.s16Regular.copyWith(
              fontSize: 15.sp,
              height: 1.3,
              color: AppColors.textGray,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.s16Regular.copyWith(
                fontSize: 15.sp,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
