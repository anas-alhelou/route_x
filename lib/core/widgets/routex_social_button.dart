import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class RouteXSocialButton extends StatelessWidget {
  const RouteXSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final button = SizedBox(
      width: double.infinity,
      height: AppSizes.buttonH56.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          elevation: 0,
          side: BorderSide(color: colors.border, width: 1.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: 12.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: AppFonts.size16.sp,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.controlW360),
        child: button,
      ),
    );
  }
}
