import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

/// Renders the RouteX brand logo SVG, left-aligned.
///
/// Used on authentication and onboarding screens as a recognisable brand
/// anchor. The logo width scales responsively via [flutter_screenutil].
/// Swaps the wordmark's hard-coded dark ink (#222222) for a light ink in dark
/// mode so "Route" stays visible; the green "X" is left untouched.
class RouteXLogoColorMapper extends ColorMapper {
  const RouteXLogoColorMapper();

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    if (AppColors.isDark && color == const Color(0xFF222222)) {
      return const Color(0xFFF2F5EC);
    }
    return color;
  }
}

class RouteXLogo extends StatelessWidget {
  const RouteXLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SvgPicture.asset(
        AppAssets.logo,
        width: 123.w,
        fit: BoxFit.contain,
        colorMapper: const RouteXLogoColorMapper(),
      ),
    );
  }
}
