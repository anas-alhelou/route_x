import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

void main() {
  tearDown(() => AppColors.isDark = false);

  test('light palette keeps the Figma values', () {
    AppColors.isDark = false;
    expect(AppColors.brandBackground, const Color(0xFFFDFDFD));
    expect(AppColors.brandBlack, const Color(0xFF222222));
    expect(AppColors.surfaceWhite, const Color(0xFFFFFFFF));
    expect(AppColors.slateInk, const Color(0xFF0F172A));
    expect(AppColors.errorRed, const Color(0xFFEF4444));
  });

  test('dark palette flips surfaces and text but not the brand colour', () {
    AppColors.isDark = true;
    expect(AppColors.brandBackground, const Color(0xFF121212));
    expect(AppColors.brandBlack, const Color(0xFFF3F4F6));
    expect(AppColors.surfaceWhite, const Color(0xFF1E1E1E));
    expect(AppColors.brandMain, const Color(0xFF8FE600));
    expect(AppColors.onBrand, const Color(0xFF222222));
  });

  test('context scheme matches the AppColors dark values', () {
    expect(AppColorsScheme.dark.border, const Color(0xFF3A3A3A));
    expect(AppColorsScheme.dark.borderSubtle, const Color(0xFF2E2E2E));
    expect(AppColorsScheme.dark.textSecondary, const Color(0xFFA3A3A3));
    expect(AppColorsScheme.dark.error, const Color(0xFFFF3D00));
  });
}
