import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';

class RouteXOrDivider extends StatelessWidget {
  const RouteXOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        const Expanded(child: _OrLine()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8),
          child: Text(
            context.tr.or,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: AppFonts.size14.sp,
              fontWeight: FontWeight.w300,
              color: colors.textPrimary,
            ),
          ),
        ),
        const Expanded(child: _OrLine()),
      ],
    );
  }
}

class _OrLine extends StatelessWidget {
  const _OrLine();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(height: 1.h, color: colors.border);
  }
}
