// lib/features/settings/presentation/pages/password_update_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import '../widgets/success_badge.dart';

/// Shown after a successful password change. Replaces the change-password
/// page, so both its button and the system back return to settings.
class PasswordUpdatePage extends StatelessWidget {
  const PasswordUpdatePage({super.key, required this.email});

  /// Where the confirmation was sent.
  final String email;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final bodyStyle = AppTextStyles.s16Regular.copyWith(
      fontSize: AppFonts.size16.sp,
      height: 1.35,
      color: AppColors.textGray,
    );

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 110.h, 26.w, 32.h),
          children: [
            const Center(child: SuccessBadge()),
            SizedBox(height: 16.h),
            Text(
              tr.changePasswordUpdated,
              textAlign: TextAlign.center,
              style: AppTextStyles.s28Bold.copyWith(
                fontSize: 24.sp,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(tr.passwordUpdatedSentTo, textAlign: TextAlign.center, style: bodyStyle),
            Text(
              email,
              textAlign: TextAlign.center,
              style: AppTextStyles.s16Bold.copyWith(
                fontSize: AppFonts.size16.sp,
                height: 1.35,
                color: AppColors.textGray,
              ),
            ),
            Text(tr.passwordUpdatedNextLogin, textAlign: TextAlign.center, style: bodyStyle),
            SizedBox(height: 31.h),
            RouteXMainButton(
              isLoading: false,
              onPressed: () => Navigator.pop(context),
              text: tr.passwordUpdatedBack,
            ),
          ],
        ),
      ),
    );
  }
}
