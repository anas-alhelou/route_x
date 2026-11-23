// lib/features/settings/presentation/pages/language_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/bloc/language/language_bloc.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Picks the app language. The choice only takes effect on "Apply language",
/// through the app-wide [LanguageBloc].
class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late String _selected = context.read<LanguageBloc>().state.languageCode;

  void _apply() {
    final bloc = context.read<LanguageBloc>();
    // The bloc only toggles en ↔ ar, so toggle when the choice differs.
    if (bloc.state.languageCode != _selected) {
      bloc.add(ToggleLanguageEvent());
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.settingsLanguage,
              subtitle: tr.languagePageSubtitle,
            ),
            SizedBox(height: 24.h),
            SettingsCard(
              padding: EdgeInsets.all(12.r),
              children: [
                // Language names are always written in their own language.
                _LanguageOption(
                  badge: 'En',
                  name: 'English',
                  description: tr.languagePageLtr,
                  isSelected: _selected == 'en',
                  onTap: () => setState(() => _selected = 'en'),
                ),
                _LanguageOption(
                  badge: 'ع',
                  name: 'العربية',
                  description: tr.languagePageArabicRtl,
                  isSelected: _selected == 'ar',
                  onTap: () => setState(() => _selected = 'ar'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 16.w, 14.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceEmpty.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.language, size: 24.r, color: AppColors.textPrimary),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      tr.languagePageInfo,
                      style: AppTextStyles.s16Regular.copyWith(
                        fontSize: 15.sp,
                        height: 1.35,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            RouteXMainButton(
              isLoading: false,
              onPressed: _apply,
              text: tr.languagePageApply,
            ),
          ],
        ),
      ),
    );
  }
}

/// Language row: letter badge, name, direction note and a check / radio.
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.badge,
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String badge;
  final String name;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsetsDirectional.fromSTEB(12.w, 10.5.h, 14.w, 10.5.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.iconBrand : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.brandMain : AppColors.borderDeactivated,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandMain : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(8.r),
                border: isSelected ? null : Border.all(color: AppColors.borderDeactivated),
              ),
              child: Text(
                badge,
                style: AppTextStyles.s16Bold.copyWith(
                  fontSize: AppFonts.size16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.s20Bold.copyWith(
                      fontSize: 18.sp,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.s14Regular.copyWith(
                      fontSize: AppFonts.size14.sp,
                      height: 1.3,
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.brandMain : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.borderDeactivated, width: 1.5),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16.r, color: AppColors.textPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
