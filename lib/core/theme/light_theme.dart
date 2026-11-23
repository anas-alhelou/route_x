import 'package:flutter/material.dart';
import 'package:routex_mobile/core/animations/app_animations.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';

ThemeData getLightTheme({bool isArabic = false}) {
  const ColorScheme lightScheme = ColorScheme.light(
    primary: AppColors.brandMain,
    onPrimary: AppColors.brandWhite,
    secondary: AppColors.brandSecondary,
    onSecondary: AppColors.onBrand,
    error: AppColors.textError,
    onError: AppColors.brandWhite,
    // Literal light values: this theme must stay light even while
    // AppColors.isDark is true (the dark theme is a separate ThemeData).
    surface: Color(0xFFFDFDFD),
    onSurface: Color(0xFF222222),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightScheme,
    scaffoldBackgroundColor: const Color(0xFFFDFDFD),
    // When Arabic is selected, IBM Plex Sans Arabic is primary; otherwise Satoshi.
    fontFamily: isArabic ? AppFonts.fontFamilyArabic : AppFonts.fontFamilySatoshi,
    fontFamilyFallback: isArabic ? [AppFonts.fontFamilySatoshi] : AppFonts.fontFamilyFallback,
    extensions: const <ThemeExtension<dynamic>>[
      AppColorsScheme.light,
    ],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AppCustomPageTransitionBuilder(),
        TargetPlatform.iOS: AppCustomPageTransitionBuilder(),
        TargetPlatform.fuchsia: AppCustomPageTransitionBuilder(),
      },
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.s36Bold,
      displayMedium: AppTextStyles.s32Bold,
      displaySmall: AppTextStyles.s28Bold,
      headlineLarge: AppTextStyles.s24SemiBold,
      headlineMedium: AppTextStyles.s20SemiBold,
      headlineSmall: AppTextStyles.s16SemiBold,
      titleLarge: AppTextStyles.s16Bold,
      titleMedium: AppTextStyles.s14SemiBold,
      titleSmall: AppTextStyles.s12SemiBold,
      bodyLarge: AppTextStyles.s16Regular,
      bodyMedium: AppTextStyles.s14Regular,
      bodySmall: AppTextStyles.s12Regular,
      labelLarge: AppTextStyles.s14Medium,
      labelMedium: AppTextStyles.s12Medium,
      labelSmall: AppTextStyles.s10Medium,
    ),
  );
}
