import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

/// Reusable back button for Auth screens with pixel-perfect start alignment.
class SignupBackButton extends StatelessWidget {
  const SignupBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.r), 
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: AlignmentDirectional.centerStart,
          child: Icon(
            Icons.arrow_back,
            size: 28.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
