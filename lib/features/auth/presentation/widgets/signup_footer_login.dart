import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Features the "Already have an account? Login" redirection tailored
/// strictly for the Auth feature's sign-up flow.
class SignupFooterLogin extends StatelessWidget {
  const SignupFooterLogin({super.key, required this.onLoginTapped});

  final VoidCallback onLoginTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.tr.alreadyHaveAccount,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: AppFonts.size14,
              fontWeight: FontWeight.w400,
              color: AppColors.brandBlack,
            ),
          ),

          SizedBox(width: 8.w),

          RouteXTapScale(
            onTap: onLoginTapped,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr.login,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.brandBlack,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Container(height: 2.h, color: AppColors.brandMain),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
