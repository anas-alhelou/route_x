import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Reusable CustomButton adhering to design specs:
/// - Width: 310.w (default), height: 56.h (default), borderRadius: 6.r (default).
/// - Text aligned at the START (Left-aligned).
/// - Trailing arrow icon aligned at the END (Right-aligned) with 24px x 24px sizing.
/// - Internal alignment using [MainAxisAlignment.spaceBetween].
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.width,
    this.height,
    this.icon = Icons.arrow_forward_rounded,
    this.iconAsset,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? width;
  final double? height;
  final IconData? icon;
  final String? iconAsset;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    final bg = backgroundColor ?? AppColors.brandMain;
    final fg = textColor ?? AppColors.onBrand;
    final radius = borderRadius ?? 6.r;
    final btnWidth = width ?? 310.w;
    final btnHeight = height ?? 56.h;
    final hasIcon = iconAsset != null || icon != null;

    return SizedBox(
      width: btnWidth,
      height: btnHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.2)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: hasIcon ? 20.w : 12.w),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: Row(
          mainAxisAlignment: hasIcon ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontSize: hasIcon ? 16.sp : 14.sp,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            if (iconAsset != null)
              Image.asset(
                iconAsset!,
                width: 24.w,
                height: 24.h,
                color: fg,
                colorBlendMode: BlendMode.srcIn,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(icon, size: 24.sp, color: fg),
          ],
        ),
      ),
    );
  }
}
