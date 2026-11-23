// lib/features/settings/presentation/widgets/company_contact.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import '../../domain/entities/driver_profile_entity.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// Opens the dialer on [phone]; spaces are dropped from the number.
Future<void> callCompany(BuildContext context, String phone) =>
    _open(context, Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

/// Opens the mail app addressed to [email].
Future<void> emailCompany(BuildContext context, String email) =>
    _open(context, Uri(scheme: 'mailto', path: email));

Future<void> _open(BuildContext context, Uri uri) async {
  final message = context.tr.myCompanyCantOpen;
  if (!await launchUrl(uri)) {
    if (context.mounted) {
      ErrorAlertDialog.show(context: context, message: message);
    }
  }
}

/// Bottom sheet with the company's phone and email; each row opens the
/// matching app and closes the sheet.
Future<void> showContactCompanySheet(
  BuildContext context,
  DriverProfileEntity profile,
) {
  return showRoutexSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ContactCompanySheet(profile: profile),
  );
}

class _ContactCompanySheet extends StatelessWidget {
  const _ContactCompanySheet({required this.profile});

  final DriverProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final company = profile.companyName;
    final phone = profile.companyPhone;
    final email = profile.companyEmail;

    // Pops the sheet, then launches from the page underneath (still mounted).
    void openThen(Future<void> Function(BuildContext) launch) {
      final pageContext = Navigator.of(context).context;
      Navigator.pop(context);
      launch(pageContext);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceEmpty,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              CompanyLogo(
                name: company ?? '',
                logoUrl: profile.companyLogoUrl,
                size: 80,
                circle: true,
              ),
              SizedBox(height: 16.h),
              Text(
                company == null
                    ? tr.settingsContactCompany
                    : tr.contactCompanyTitle(company),
                textAlign: TextAlign.center,
                style: AppTextStyles.s24Bold.copyWith(
                  fontSize: 20.sp,
                  height: 1.35,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                tr.contactCompanyBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.s14Regular.copyWith(
                  fontSize: 15.sp,
                  height: 1.35,
                  color: AppColors.textGray,
                ),
              ),
              SizedBox(height: 20.h),
              if (phone != null) ...[
                _ContactRow(
                  icon: Icons.phone_outlined,
                  title: tr.myCompanyCall,
                  value: phone,
                  ltrValue: true,
                  onTap: () => openThen((c) => callCompany(c, phone)),
                ),
                SizedBox(height: 8.h),
              ],
              if (email != null) ...[
                _ContactRow(
                  icon: Icons.mail_outline,
                  title: tr.myCompanyEmail,
                  value: email,
                  ltrValue: true,
                  onTap: () => openThen((c) => emailCompany(c, email)),
                ),
                SizedBox(height: 8.h),
              ],
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.surfaceEmpty),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    tr.cancel,
                    style: AppTextStyles.s16Bold.copyWith(
                      fontSize: AppFonts.size16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gray row: an icon in a white circle, a title over its value, an arrow.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.ltrValue = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  /// Phone numbers and emails keep their left-to-right order in Arabic.
  final bool ltrValue;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return Material(
      color: AppColors.surfaceEmpty.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.surfaceEmpty),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(14.w, 7.h, 16.w, 7.h),
          child: Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24.r, color: AppColors.textPrimary),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.s16Bold.copyWith(
                        fontSize: AppFonts.size16.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: ltrValue ? TextDirection.ltr : null,
                      style: AppTextStyles.s14Regular.copyWith(
                        fontSize: AppFonts.size14.sp,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 24.r, color: AppColors.textGray),
            ],
          ),
        ),
      ),
    );
  }
}

/// Company logo from [logoUrl], or its initials until the company has one.
class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
    required this.name,
    required this.logoUrl,
    this.size = 56,
    this.circle = false,
  });

  final String name;
  final String? logoUrl;
  final double size;
  final bool circle;

  String get _initials => name
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final logo = logoUrl;
    return Container(
      width: size.r,
      height: size.r,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderDeactivated),
      ),
      child: logo != null
          ? Image.network(logo, fit: BoxFit.cover)
          : Text(
              _initials,
              style: AppTextStyles.s20Bold.copyWith(
                fontSize: (size * 0.3).sp,
                color: AppColors.textPrimary,
              ),
            ),
    );
  }
}
