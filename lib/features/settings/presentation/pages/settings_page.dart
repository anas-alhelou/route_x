// lib/features/settings/presentation/pages/settings_page.dart
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:routex_mobile/core/bloc/theme/theme_cubit.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../controllers/settings_cubit.dart';
import '../controllers/settings_state.dart';
import '../navigation/settings_navigator.dart';
import '../widgets/company_contact.dart';
import '../widgets/logout_modal.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/quick_setting_tile.dart';
import '../widgets/settings_list_tile.dart';
import '../widgets/settings_skeleton.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/route_error_view.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_switch_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        getProfileUseCase: getIt(),
        updateProfileUseCase: getIt(),
        logoutUseCase: getIt(),
      )..loadProfile(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoggedOut) {
          context.go(RoutersName.login);
        }
      },
      builder: (context, state) {
        if (state is SettingsLoading || state is SettingsInitial) {
          return const SettingsSkeleton();
        }

        if (state is SettingsError) {
          return Scaffold(
            backgroundColor: AppColors.brandBackground,
            body: RouteErrorView(
              message: state.message,
              onRetry: () => context.read<SettingsCubit>().loadProfile(),
            ),
          );
        }

        if (state is SettingsLoaded) {
          return _SettingsContent(profile: state.profile);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.profile});

  final DriverProfileEntity profile;

  void _openWithProfile(BuildContext context, String route) =>
      SettingsNavigator.pushWithProfile(context, route, profile);

  /// "Enabled" while at least one alert type is on.
  bool get _hasAlertsOn =>
      profile.notifyNewRoutes ||
      profile.notifyOrderChanges ||
      profile.notifyDispatchMessages;

  /// On confirm the cubit logs out and emits [SettingsLoggedOut], which the
  /// view's listener turns into the move to the login page.
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showLogoutSheet(context);
    if (confirmed == true && context.mounted) {
      context.read<SettingsCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final sectionGap = SizedBox(height: 16.h);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(
            26.w,
            12.h,
            26.w,
            AppSizes.bottomNavClearance.h,
          ),
          children: [
            Text(
              tr.settingsTitle,
              style: AppTextStyles.s28Bold.copyWith(
                fontSize: AppFonts.size28.sp,
                height: 1.15,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            ProfileHeaderWidget(
              profile: profile,
              onEditPressed: () =>
                  _openWithProfile(context, RoutersName.editProfileScreen),
              onVehiclePressed: () =>
                  _openWithProfile(context, RoutersName.vehicleScreen),
            ),
            SizedBox(height: 22.h),
            Text(
              tr.settingsQuickSettings,
              style: AppTextStyles.s20Bold.copyWith(
                fontSize: AppFonts.size20.sp,
                height: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 19.h),
            _QuickSettingsGrid(
              tiles: [
                QuickSettingTile(
                  icon: Icons.near_me_outlined,
                  value: profile.navigationApp == 'routex'
                      ? 'RouteX'
                      : tr.settingsGoogleMaps,
                  label: tr.settingsNavigation,
                  onTap: () => _openWithProfile(
                    context,
                    RoutersName.navigationSettingsScreen,
                  ),
                ),
                QuickSettingTile(
                  icon: _hasAlertsOn
                      ? Icons.notifications_none
                      : Icons.notifications_off_outlined,
                  value: _hasAlertsOn
                      ? tr.settingsEnabled
                      : tr.settingsDisabled,
                  label: tr.settingsNotifications,
                  onTap: () => _openWithProfile(
                    context,
                    RoutersName.notificationsSettingsScreen,
                  ),
                ),
                QuickSettingTile(
                  icon: Icons.language,
                  value: tr.settingsLanguageName,
                  label: tr.settingsLanguage,
                  onTap: () => context.push(RoutersName.languageScreen),
                ),
                QuickSettingTile(
                  icon: Icons.contrast,
                  value: switch (context.watch<ThemeCubit>().state) {
                    ThemeMode.light => tr.settingsThemeLight,
                    ThemeMode.dark => tr.themeDark,
                    ThemeMode.system => tr.themeSystem,
                  },
                  label: tr.settingsTheme,
                  onTap: () => context.push(RoutersName.themeScreen),
                ),
              ],
            ),
            sectionGap,
            SettingsCard(
              title: tr.settingsCompany,
              padding: EdgeInsetsDirectional.fromSTEB(12.w, 16.h, 12.w, 16.h),
              children: [
                SettingsOptionTile(
                  leading: Assets.icons.svg.fleets.svg(
                    width: 36.r,
                    height: 36.r,
                  ),
                  title: profile.companyName ?? '',
                  subtitle: switch (profile.companyJoinedAt) {
                    final joined? => tr.settingsCompanyActiveJoined(
                      DateFormat(
                        'd MMM y',
                        Localizations.localeOf(context).toString(),
                      ).format(joined),
                    ),
                    null => tr.settingsCompanyActive,
                  },
                  onTap: () =>
                      _openWithProfile(context, RoutersName.myCompanyScreen),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 22.r,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            sectionGap,
            SettingsCard(
              title: tr.settingsPrivacySecurity,
              children: [
                SettingsListTile(
                  icon: Icons.lock_outline,
                  title: tr.settingsChangePassword,
                  onTap: () => context.push(
                    RoutersName.changePasswordScreen,
                    extra: profile.email,
                  ),
                ),
                SettingsListTile(
                  leading: SettingsIconBadge(
                    svg: Assets.icons.svg.carbonLocation,
                  ),
                  title: tr.settingsLocationAccess,
                  value: switch (profile.locationAccess) {
                    'while_using' => tr.locationWhileUsing,
                    'never' => tr.locationNever,
                    _ => tr.settingsLocationAlways,
                  },
                  onTap: () => _openWithProfile(
                    context,
                    RoutersName.locationAccessScreen,
                  ),
                ),
                SettingsListTile(
                  icon: Icons.shield_outlined,
                  title: tr.settingsPrivacyPolicy,
                  onTap: () {},
                ),
              ],
            ),
            sectionGap,
            SettingsCard(
              title: tr.settingsSupport,
              children: [
                SettingsListTile(
                  icon: Icons.headset_mic_outlined,
                  title: tr.settingsContactCompany,
                  subtitle: switch (profile.companyName) {
                    final company? => tr.settingsContactCompanyHint(company),
                    null => tr.settingsContactCompanyHintFallback,
                  },
                  filled: false,
                  onTap: () => showContactCompanySheet(context, profile),
                ),
                SettingsListTile(
                  icon: Icons.question_mark_rounded,
                  title: tr.settingsHelpCenter,
                  filled: false,
                  onTap: () => context.push(RoutersName.helpCenterScreen),
                ),
                SettingsListTile(
                  icon: Icons.warning_amber_rounded,
                  title: tr.settingsReportProblem,
                  filled: false,
                  onTap: () => context.push(RoutersName.reportProblemScreen),
                ),
              ],
            ),
            sectionGap,
            _LogoutButton(
              label: tr.settingsLogOut,
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two-column grid of quick setting tiles.
class _QuickSettingsGrid extends StatelessWidget {
  const _QuickSettingsGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: tiles[i]),
              SizedBox(width: 12.w),
              Expanded(
                child: i + 1 < tiles.length
                    ? tiles[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          height: 56.h,
          decoration: settingsCardDecoration(radius: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 22.r, color: AppColors.textPrimary),
              SizedBox(width: 10.w),
              Text(
                label,
                style: AppTextStyles.s16Medium.copyWith(
                  fontSize: AppFonts.size16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
