import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

import 'package:routex_mobile/core/theme/app_fonts.dart';

class RouteXPageHeader extends StatelessWidget {
  const RouteXPageHeader({
    super.key,  
    required this.titleStart,
    required this.titleEnd,
    required this.subtitle,
    this.titleStartSize,
    this.titleEndSize,
    this.subtitleSize,
    this.subtitleGap = 16,
  });

  final String titleStart;
  final String titleEnd;
  final String subtitle;
  final double? titleStartSize;
  final double? titleEndSize;
  final double? subtitleSize;

  /// Space between the title and the subtitle.
  final double subtitleGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: titleStartSize ?? AppFonts.size32.sp,
              fontWeight: FontWeight.w700,
              height: 1.214,
              letterSpacing: (titleStartSize ?? AppFonts.size32) * 0.01,
            ),
            children: [
              TextSpan(
                text: '$titleStart\n',
                style: TextStyle(
                  color: AppColors.brandBlack,
                  fontSize: titleStartSize ?? AppFonts.size32.sp,
                ),
              ),
              TextSpan(
                text: titleEnd,
                style: TextStyle(
                  color: AppColors.brandMain,
                  fontSize: titleEndSize ?? AppFonts.size32.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: subtitleGap.h),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontFamilyFallback: AppFonts.fontFamilyFallback,
            fontSize: subtitleSize ?? AppFonts.size14.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: (subtitleSize ?? AppFonts.size14) * 0.01,
            color: AppColors.brandBlack,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
