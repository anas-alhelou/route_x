import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Text button styled as a text label over an underline accent, used for
/// secondary links (login, resend, secondary actions). Disables itself
/// (grey text/line, no tap) when [onTap] is null.
class AuthUnderlinedButton extends StatelessWidget {
  const AuthUnderlinedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.lineColor,
    this.lineHeight,
  });

  /// Label shown above the underline.
  final String text;

  /// Tap callback; null renders the button in a disabled, muted state.
  final VoidCallback? onTap;

  /// Overrides the default font size.
  final double? fontSize;

  /// Overrides the default label weight (bold).
  final FontWeight? fontWeight;

  /// Overrides for muted / secondary-link styling. Defaults keep the
  /// standard dark-text + green-underline treatment used elsewhere.
  final Color? textColor;
  final Color? lineColor;
  final double? lineHeight;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    final Color resolvedTextColor = isDisabled
        ? AppColors.textGray
        : (textColor ?? AppColors.brandBlack);
    final Color resolvedLineColor = isDisabled
        ? AppColors.textGray
        : (lineColor ?? AppColors.brandMain);

    return RouteXTapScale(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontFamilyFallback: AppFonts.fontFamilyFallback,
                fontSize: fontSize ?? AppFonts.size14,
                letterSpacing: (fontSize ?? AppFonts.size14) * 0.01,
                color: resolvedTextColor,
                fontWeight: fontWeight ?? FontWeight.w700,
              ),
            ),
            Container(height: lineHeight ?? 2.h, color: resolvedLineColor),
          ],
        ),
      ),
    );
  }
}
