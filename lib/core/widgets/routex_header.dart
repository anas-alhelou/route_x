import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_logo.dart';

/// Defines the header layout variant based on Figma UI Redesign
enum RouteXHeaderType {
  /// Includes Logo at top (Used in Onboarding, Splash, Login)
  authWithLogo,

  /// Standard Page Header without logo (Used in Dashboard & Main App Pages)
  standardPage,

  /// Multi-step Auth Header with Back button and Step Progress Bar
  stepper,
}

/// Unified Header Component matching RouteX Figma Design Guidelines.
class RouteXHeader extends StatelessWidget {
  const RouteXHeader({
    super.key,
    required this.titleStart,
    required this.titleEnd,
    required this.subtitle,
    this.type = RouteXHeaderType.authWithLogo,

    // --- Font Sizes (Optional with defaults) ---
    this.titleStartSize,
    this.titleEndSize,
    this.subtitleSize,

    // --- Colors (Optional with defaults) ---
    this.titleStartColor,
    this.titleEndColor,
    this.subtitleColor,

    // --- Custom Typography Controls ---
    this.fontFamily,
    this.titleFontWeight = FontWeight.w700,
    this.subtitleFontWeight = FontWeight.w400,
    this.titleLineHeight = 1.2,

    // --- Spacing & Stepper Parameters ---
    this.subtitleBottomPadding,
    this.topPadding,
    this.currentStep = 1,
    this.totalSteps = 4,
    this.onBackTap,
  });

  /// First part of the title
  final String titleStart;

  /// Highlighted second part of title
  final String titleEnd;

  /// Subtitle text below title
  final String subtitle;

  /// Variant type of header
  final RouteXHeaderType type;

  // --- Font Sizes ---
  final double? titleStartSize;
  final double? titleEndSize;
  final double? subtitleSize;

  // --- Colors ---
  final Color? titleStartColor;
  final Color? titleEndColor;
  final Color? subtitleColor;

  // --- Typography Specs ---
  final String? fontFamily;
  final FontWeight titleFontWeight;
  final FontWeight subtitleFontWeight;
  final double titleLineHeight;

  // --- Layout & Stepper Controls ---
  final double? subtitleBottomPadding;
  final double? topPadding;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    // Handling fallback values dynamically
    final effectiveFontFamily = fontFamily ?? AppFonts.fontFamilySatoshi;

    final effectiveTitleStartSize = titleStartSize ?? AppFonts.size32.sp;
    final effectiveTitleEndSize = titleEndSize ?? AppFonts.size32.sp;
    final effectiveSubtitleSize = subtitleSize ?? AppFonts.size14.sp;

    final effectiveTitleStartColor = titleStartColor ?? AppColors.textBlack;
    final effectiveTitleEndColor = titleEndColor ?? AppColors.brandMain;
    final effectiveSubtitleColor = subtitleColor ?? AppColors.textGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ----------------------------------------------------
        // 1. TOP SECTION (LOGO OR STEPPER BACK BUTTON)
        // ----------------------------------------------------
        if (type == RouteXHeaderType.authWithLogo) ...[
          SizedBox(height: topPadding ?? AppSizes.p24.h),
          SvgPicture.asset(
            AppAssets.icLogo,
            height: 28.h,
            fit: BoxFit.contain,
            colorMapper: const RouteXLogoColorMapper(),
          ),
          SizedBox(height: AppSizes.p24.h),
        ] else if (type == RouteXHeaderType.stepper) ...[
          SizedBox(height: topPadding ?? AppSizes.p12.h),
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20.sp,
                  color: AppColors.textBlack,
                ),
                onPressed: onBackTap ?? () => context.pop(),
              ),
              SizedBox(width: AppSizes.p16.w),
              // Step Progress Bar Indicator
              Expanded(
                child: Row(
                  children: List.generate(
                    totalSteps,
                        (index) => Expanded(
                      child: Container(
                        height: 4.h,
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          color: (index < currentStep)
                              ? AppColors.brandMain
                              : AppColors.surfaceEmpty,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.p24.h),
        ] else ...[
          if (topPadding != null) SizedBox(height: topPadding!.h),
        ],

        // ----------------------------------------------------
        // 2. DYNAMIC TITLE (RICHTEXT)
        // ----------------------------------------------------
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: effectiveFontFamily,
              fontWeight: titleFontWeight,
              height: titleLineHeight,
            ),
            children: [
              TextSpan(
                text: '$titleStart\n',
                style: TextStyle(
                  color: effectiveTitleStartColor,
                  fontSize: effectiveTitleStartSize,
                ),
              ),
              TextSpan(
                text: titleEnd,
                style: TextStyle(
                  color: effectiveTitleEndColor,
                  fontSize: effectiveTitleEndSize,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: AppSizes.p8.h),

        // ----------------------------------------------------
        // 3. SUBTITLE
        // ----------------------------------------------------
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: effectiveFontFamily,
            fontSize: effectiveSubtitleSize,
            fontWeight: subtitleFontWeight,
            color: effectiveSubtitleColor,
            height: 1.4,
          ),
        ),

        SizedBox(height: subtitleBottomPadding ?? AppSizes.p24.h),
      ],
    );
  }
}