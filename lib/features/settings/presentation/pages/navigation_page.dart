// lib/features/settings/presentation/pages/navigation_page.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_logo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../controllers/settings_cubit.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Which app opens when the driver taps Navigate on a stop.
///
/// Expects the [SettingsCubit] of the settings screen above it.
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key, required this.profile});

  final DriverProfileEntity profile;

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late String _app;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _app = profile.navigationApp;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final error = await context.read<SettingsCubit>().updateProfile(
      widget.profile.copyWith(navigationApp: _app),
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
    final cardPadding = EdgeInsetsDirectional.fromSTEB(12.w, 16.h, 12.w, 12.h);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.settingsNavigation,
              subtitle: tr.navigationPageSubtitleStop,
            ),
            SizedBox(height: 24.h),
            SettingsCard(
              title: tr.navigationPageApp,
              padding: cardPadding,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _AppCard(
                        logo: Assets.icons.svg.gcpGoogleMapsPlatform.svg(
                          width: 40.r,
                          height: 40.r,
                        ),
                        name: tr.settingsGoogleMaps,
                        isSelected: _app == 'google_maps',
                        onTap: () => setState(() => _app = 'google_maps'),
                      ),
                    ),
                    SizedBox(width: 11.w),
                    Expanded(
                      child: _AppCard(
                        logo: Container(
                          width: 40.r,
                          height: 40.r,
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.borderDeactivated,
                            ),
                          ),
                          child: SvgPicture.asset(
                            AppAssets.icLogo,
                            fit: BoxFit.contain,
                            colorMapper: const RouteXLogoColorMapper(),
                          ),
                        ),
                        name: 'RouteX',
                        isSelected: _app == 'routex',
                        onTap: () => setState(() => _app = 'routex'),
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

/// Selectable navigation app card.
class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.logo,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final Widget logo;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 119.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.iconBrand : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.brandMain
                : AppColors.borderDeactivated,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo,
            SizedBox(height: 8.h),
            Text(
              name,
              style: AppTextStyles.s16Bold.copyWith(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
