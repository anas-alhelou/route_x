// lib/features/settings/presentation/pages/report_sent_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import '../widgets/success_badge.dart';

/// Confirmation after a problem report: who will hear back, where, and the
/// reference to quote to support.
class ReportSentPage extends StatelessWidget {
  const ReportSentPage({
    super.key,
    required this.firstName,
    required this.email,
    required this.reference,
  });

  final String firstName;
  final String email;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 110.h, 26.w, 32.h),
          children: [
            const Center(child: SuccessBadge()),
            SizedBox(height: 16.h),
            Text(
              tr.reportSentTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.s28Bold.copyWith(
                fontSize: 24.sp,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              tr.reportSentBody(firstName, email),
              textAlign: TextAlign.center,
              style: AppTextStyles.s16Regular.copyWith(
                fontSize: AppFonts.size16.sp,
                height: 1.35,
                color: AppColors.textGray,
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceEmpty.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  tr.reportReference(reference),
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.s14Bold.copyWith(
                    fontSize: 13.sp,
                    height: 1.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            RouteXMainButton(
              isLoading: false,
              // Settings is the first route, also when reached via Help center.
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              text: tr.passwordUpdatedBack,
            ),
          ],
        ),
      ),
    );
  }
}
