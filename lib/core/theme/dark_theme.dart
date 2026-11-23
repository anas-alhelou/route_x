import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';

ThemeData getDarkTheme({bool isArabic = false}) {
  const ColorScheme darkScheme = ColorScheme.dark(
    primary: AppColors.brandMain,
    onPrimary: AppColors.onBrand,
    secondary: AppColors.brandSecondary,
    onSecondary: AppColors.onBrand,
    error: Color(0xFFFF7355),
    onError: AppColors.brandWhite,
    surface: Color(0xFF1B1F16),
    onSurface: Color(0xFFF2F5EC),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkScheme,
    scaffoldBackgroundColor: const Color(0xFF131814),
    fontFamily: isArabic ? AppFonts.fontFamilyArabic : AppFonts.fontFamilySatoshi,
    fontFamilyFallback: isArabic ? [AppFonts.fontFamilySatoshi] : AppFonts.fontFamilyFallback,
    dividerTheme: const DividerThemeData(color: Color(0xFF2A2E25), thickness: 1),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1B1F16),
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1B1F16),
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: Color(0xFF1B1F16),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1B1F16),
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.brandMain),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.brandMain,
      selectionHandleColor: AppColors.brandMain,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppColorsScheme.dark,
    ],
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
