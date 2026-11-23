// lib/features/settings/presentation/pages/my_company_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../widgets/company_contact.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/vehicle_type_label.dart';

/// The delivery company the driver works for: its status, join date, code,
/// the vehicle it assigned, and a way to call or email it.
class MyCompanyPage extends StatelessWidget {
  const MyCompanyPage({super.key, required this.profile});

  final DriverProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final joined = profile.companyJoinedAt;
    final phone = profile.companyPhone;
    final email = profile.companyEmail;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.myCompanyTitle,
              subtitle: tr.myCompanySubtitle,
            ),
            SizedBox(height: 24.h),
            SettingsCard(
              spacing: 0,
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 22.h, 16.w, 15.h),
              children: [
                _CompanySummary(
                  name: profile.companyName ?? '',
                  logoUrl: profile.companyLogoUrl,
                  status: tr.settingsCompanyActive,
                ),
                SizedBox(height: 12.h),
                if (joined != null)
                  _DetailRow(
                    label: tr.myCompanyJoined,
                    value: Text(
                      DateFormat(
                        'd MMM y',
                        Localizations.localeOf(context).toString(),
                      ).format(joined),
                      style: _valueStyle,
                    ),
                  ),
                if (profile.companyCode case final code?)
                  _DetailRow(
                    label: tr.myCompanyCode,
                    value: Text(code, style: _valueStyle),
                  ),
                _DetailRow(
                  label: tr.myCompanyVehicle,
                  showDivider: false,
                  value: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '${context.vehicleTypeLabel(profile.vehicleType)} · ${profile.vehicleNumber}',
                          textAlign: TextAlign.end,
                          style: _valueStyle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.lock_outline,
                        size: 18.r,
                        color: AppColors.textGray,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 11.h),
            Row(
              children: [
                Expanded(
                  child: _ContactButton(
                    icon: Icons.phone_outlined,
                    label: tr.myCompanyCall,
                    onPressed: phone == null
                        ? null
                        : () => callCompany(context, phone),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ContactButton(
                    icon: Icons.mail_outline,
                    label: tr.myCompanyEmail,
                    onPressed: email == null
                        ? null
                        : () => emailCompany(context, email),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle get _valueStyle => AppTextStyles.s16Regular.copyWith(
  fontSize: 15.sp,
  height: 1.3,
  color: AppColors.textPrimary,
);

/// Company logo (or its initials), name and a status chip.
class _CompanySummary extends StatelessWidget {
  const _CompanySummary({
    required this.name,
    required this.logoUrl,
    required this.status,
  });

  final String name;
  final String? logoUrl;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CompanyLogo(name: name, logoUrl: logoUrl, size: 48),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
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
                      status,
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
    this.showDivider = true,
  });

  final String label;
  final Widget value;
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
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: value,
            ),
          ),
        ],
      ),
    );
  }
}

/// Outlined button with an icon and a label (Call / Email).
class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surfaceWhite,
          side: BorderSide(color: AppColors.surfaceEmpty),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: Icon(icon, size: 22.r),
        label: Text(
          label,
          style: AppTextStyles.s16Bold.copyWith(fontSize: AppFonts.size16.sp),
        ),
      ),
    );
  }
}
