import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Footer linking to the terms of service and privacy policy, rendered
/// under the sign-up form as localized, tappable text spans.
class SignupFooterTerms extends StatelessWidget {
  const SignupFooterTerms({super.key});

  @override
  Widget build(BuildContext context) {
    // Figma: 360 wide, hugging its two lines (45 high at 16/1.4).
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.controlW360),
        child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontFamilyFallback: AppFonts.fontFamilyFallback,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.brandDeepBlack,
            height: 1.4,
          ),
          children: [
            TextSpan(text: context.tr.byCreatingAccount),
            TextSpan(
              text: context.tr.termsOfService,
              style: const TextStyle(
                color: AppColors.brandMain,
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            TextSpan(text: context.tr.and),
            TextSpan(
              text: context.tr.privacyPolicy,
              style: const TextStyle(
                color: AppColors.brandMain,
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
          ],
        ),
        ),
      ),
    );
  }
}
