// lib/features/settings/presentation/widgets/password_rules_checklist.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

/// Live checklist of the strong-password rules, matching
/// `AuthValidators.validateStrongPassword`.
class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final rules = [
      (tr.reqMinLength, password.length >= 8),
      (tr.reqCapitalLetter, password.contains(RegExp(r'[A-Z]'))),
      (tr.reqNumber, password.contains(RegExp(r'[0-9]'))),
      (tr.reqSymbol, password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))),
    ];
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 8.w),
      child: Column(
        children: [
          for (final (label, isMet) in rules)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMet ? AppColors.brandMain : Colors.transparent,
                      border: isMet
                          ? null
                          : Border.all(color: AppColors.borderDeactivated, width: 1.5),
                    ),
                    child: isMet
                        ? Icon(Icons.check_rounded, size: 15.r, color: AppColors.textPrimary)
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.s16Regular.copyWith(
                        fontSize: AppFonts.size16.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
