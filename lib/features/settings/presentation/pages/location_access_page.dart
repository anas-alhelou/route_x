// lib/features/settings/presentation/pages/location_access_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../controllers/settings_cubit.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Location sharing choice (always / while using / never) and why the app
/// needs it. The page opens on what the system actually allows, and saving
/// asks the system for the chosen level (or opens the app settings when the
/// system will no longer ask). The choice is also kept on the profile through
/// [SettingsCubit].
class LocationAccessPage extends StatefulWidget {
  const LocationAccessPage({super.key, required this.profile});

  final DriverProfileEntity profile;

  @override
  State<LocationAccessPage> createState() => _LocationAccessPageState();
}

class _LocationAccessPageState extends State<LocationAccessPage> {
  late String _selected = widget.profile.locationAccess;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _syncWithSystem();
  }

  /// Shows what the system really allows, not only what was saved earlier.
  Future<void> _syncWithSystem() async {
    try {
      final always = await Permission.locationAlways.status;
      final whenInUse = await Permission.locationWhenInUse.status;
      final actual = always.isGranted
          ? 'always'
          : whenInUse.isGranted
              ? 'while_using'
              : 'never';
      if (mounted && actual != _selected) setState(() => _selected = actual);
    } catch (_) {
      // Keep the saved choice when the system cannot be asked.
    }
  }

  /// Asks the system for the chosen level, or opens the app settings when the
  /// system will not ask again.
  Future<void> _applyToSystem() async {
    try {
      if (_selected == 'never') return; // The app cannot revoke a permission.
      final whenInUse = await Permission.locationWhenInUse.request();
      if (whenInUse.isPermanentlyDenied) {
        await openAppSettings();
        return;
      }
      if (_selected == 'always' && whenInUse.isGranted) {
        final always = await Permission.locationAlways.request();
        if (always.isPermanentlyDenied) await openAppSettings();
      }
    } catch (_) {
      // The saved choice still applies; the next screen asks again.
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await _applyToSystem();
    if (!mounted) return;
    final error = await context.read<SettingsCubit>().updateProfile(
          widget.profile.copyWith(locationAccess: _selected),
        );
    if (!mounted) return;
    if (error == null) {
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
    final options = [
      (key: 'always', title: tr.settingsLocationAlways, hint: tr.locationAlwaysHint),
      (key: 'while_using', title: tr.locationWhileUsing, hint: tr.locationWhileUsingHint),
      (key: 'never', title: tr.locationNever, hint: tr.locationNeverHint),
    ];
    final iconSize = 20.r;
    final reasons = [
      (
        icon: Assets.icons.svg.carbonLocation.svg(
          width: iconSize,
          height: iconSize,
          colorFilter: const ColorFilter.mode(AppColors.brandMain, BlendMode.srcIn),
        ),
        text: tr.locationWhyDispatch,
      ),
      (
        icon: Icon(Icons.schedule, size: iconSize, color: AppColors.brandMain),
        text: tr.locationWhyEta,
      ),
      (
        icon: Icon(Icons.battery_3_bar_outlined, size: iconSize, color: AppColors.brandMain),
        text: tr.locationWhyBattery,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.settingsLocationAccess,
              subtitle: tr.locationSubtitle,
            ),
            SizedBox(height: 24.h),
            SettingsCard(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              children: [
                for (final option in options)
                  _AccessOption(
                    title: option.title,
                    hint: option.hint,
                    isSelected: _selected == option.key,
                    onTap: () => setState(() => _selected = option.key),
                  ),
              ],
            ),
            SizedBox(height: 17.h),
            Text(
              tr.locationWhyTitle,
              style: AppTextStyles.s20Bold.copyWith(
                fontSize: 18.sp,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            SettingsCard(
              spacing: 12,
              padding: EdgeInsetsDirectional.fromSTEB(12.w, 15.h, 14.w, 15.h),
              children: [
                for (final reason in reasons)
                  Row(
                    children: [
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: AppColors.iconBrand,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: reason.icon,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          reason.text,
                          style: AppTextStyles.s16Regular.copyWith(
                            fontSize: 15.sp,
                            height: 1.35,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 17.h),
            RouteXMainButton(
              isLoading: _isSaving,
              onPressed: _save,
              text: tr.editProfileSaveChanges,
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable option: title, explanation and a check / radio.
class _AccessOption extends StatelessWidget {
  const _AccessOption({
    required this.title,
    required this.hint,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String hint;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 14.w, 14.h),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.s16Bold.copyWith(
                      fontSize: AppFonts.size16.sp,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    hint,
                    style: AppTextStyles.s14Regular.copyWith(
                      fontSize: 13.sp,
                      height: 1.3,
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
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
