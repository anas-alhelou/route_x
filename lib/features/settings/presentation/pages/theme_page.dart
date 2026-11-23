// lib/features/settings/presentation/pages/theme_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/bloc/theme/theme_cubit.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Light / Dark / System picker. The choice is saved through the app-wide
/// [ThemeCubit] on "Apply theme".
class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  late ThemeMode _selected = context.read<ThemeCubit>().state;
  bool _isSaving = false;

  Future<void> _apply() async {
    setState(() => _isSaving = true);
    final saved = await context.read<ThemeCubit>().setMode(_selected);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isSaving = false);
    ErrorAlertDialog.show(
      context: context,
      message: context.tr.somethingWentWrong,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final colors = context.colors;
    final options = [
      (mode: ThemeMode.light, label: tr.settingsThemeLight),
      (mode: ThemeMode.dark, label: tr.themeDark),
      (mode: ThemeMode.system, label: tr.themeSystem),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.settingsTheme,
              subtitle: tr.themePageSubtitle,
            ),
            SizedBox(height: 24.h),
            SettingsCard(
              padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 12.w, 12.h),
              children: [
                Row(
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0) SizedBox(width: 9.w),
                      Expanded(
                        child: _ThemeOption(
                          mode: options[i].mode,
                          label: options[i].label,
                          isSelected: _selected == options[i].mode,
                          onTap: () => setState(() => _selected = options[i].mode),
                        ),
                      ),
                    ],
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 4.w),
                  child: Text(
                    tr.themePageSystemHint,
                    style: AppTextStyles.s14Regular.copyWith(
                      fontSize: 15.sp,
                      height: 1.35,
                      color: colors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            RouteXMainButton(
              isLoading: _isSaving,
              onPressed: _apply,
              text: tr.themePageApply,
            ),
          ],
        ),
      ),
    );
  }
}

/// One theme card: a phone preview with a check / radio and the label.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final ThemeMode mode;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.brandMain.withValues(alpha: 0.15) : colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colors.brandMain : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 0.63,
              child: switch (mode) {
                ThemeMode.light => const _PhonePreview(dark: false),
                ThemeMode.dark => const _PhonePreview(dark: true),
                ThemeMode.system => const _SplitPhonePreview(),
              },
            ),
            SizedBox(height: 11.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.brandMain : Colors.transparent,
                    border: isSelected
                        ? null
                        : Border.all(color: colors.border, width: 1.5),
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded, size: 16.r, color: colors.textPrimary)
                      : null,
                ),
                SizedBox(width: 7.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.s16Bold.copyWith(
                      fontSize: AppFonts.size16.sp,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Miniature screen: a title bar, two text lines and a green button.
class _PhonePreview extends StatelessWidget {
  const _PhonePreview({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final background = dark ? const Color(0xFF222222) : AppColors.brandWhite; // Figma S10 preview
    final title = dark ? AppColors.brandWhite : AppColors.brandBlack;
    final line = dark ? const Color(0xFF555555) : AppColors.surfaceEmpty; // Figma S10 preview

    Widget bar(Color color, double widthFactor, double height) => FractionallySizedBox(
          widthFactor: widthFactor,
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        );

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(10.w, 12.h, 10.w, 12.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
        border: dark ? null : Border.all(color: AppColors.borderDeactivated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(title, 0.6, 5.h),
          SizedBox(height: 7.h),
          bar(line, 1, 5.h),
          SizedBox(height: 7.h),
          bar(line, 0.75, 5.h),
          const Spacer(),
          bar(AppColors.brandMain, 1, 13.h),
        ],
      ),
    );
  }
}

/// Light preview with its end half painted as the dark one.
class _SplitPhonePreview extends StatelessWidget {
  const _SplitPhonePreview();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _PhonePreview(dark: false),
        ClipRect(
          clipper: _EndHalfClipper(Directionality.of(context)),
          child: const _PhonePreview(dark: true),
        ),
      ],
    );
  }
}

class _EndHalfClipper extends CustomClipper<Rect> {
  const _EndHalfClipper(this.direction);

  final TextDirection direction;

  @override
  Rect getClip(Size size) => direction == TextDirection.ltr
      ? Rect.fromLTRB(size.width / 2, 0, size.width, size.height)
      : Rect.fromLTRB(0, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(_EndHalfClipper oldClipper) => oldClipper.direction != direction;
}
