// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/route_error_page.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/smart_animate_route.dart';
import 'package:routex_mobile/features/app_permissions/presentation/routes/app_permissions_routes.dart';
import 'package:routex_mobile/features/auth/presentation/routes/auth_routes.dart';
import 'package:routex_mobile/features/home/presentation/routes/home_routes.dart';
import 'package:routex_mobile/features/join_company/presentation/routes/join_company_routes.dart';
import 'package:routex_mobile/features/main_layout/presentation/pages/main_layout_screen.dart';
import 'package:routex_mobile/features/notifications/presentation/routes/notifications_routes.dart';
import 'package:routex_mobile/features/onboarding/presentation/routes/onboarding_routes.dart';
import 'package:routex_mobile/features/orders/presentation/pages/orders_today_page.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/settings/domain/entities/driver_profile_entity.dart';
import 'package:routex_mobile/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:routex_mobile/features/settings/presentation/navigation/settings_navigator.dart';
import 'package:routex_mobile/features/settings/presentation/pages/change_password_forgot_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/change_password_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/forgot_password_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/help_center_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/join_with_code_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/language_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/location_access_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/my_company_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/my_fleets_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/myfleets_request_pending_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/navigation_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/notifications_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/otp_screen_setting.dart';
import 'package:routex_mobile/features/settings/presentation/pages/password_update_forgot.dart';
import 'package:routex_mobile/features/settings/presentation/pages/password_update_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/report_problem_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/report_sent_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/settings_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/theme_page.dart';
import 'package:routex_mobile/features/settings/presentation/pages/vehicle_page.dart';
import 'package:routex_mobile/features/splash/presentation/routes/splash_routes.dart';

export 'package:routex_mobile/core/router/route_error_page.dart';

abstract final class AppRouter {
  /// Settings pages that edit the profile share the settings screen's cubit,
  /// passed as [SettingsProfileArgs]; without it there is nothing to edit.
  static Widget _withProfile(
    GoRouterState state,
    Widget Function(DriverProfileEntity profile) page,
  ) {
    final args = state.extra;
    if (args is! SettingsProfileArgs) return const RouteErrorPage(error: null);
    return BlocProvider<SettingsCubit>.value(
      value: args.cubit,
      child: page(args.profile),
    );
  }

  /// Password pages need the account email as `extra`.
  static Widget _withEmail(
    GoRouterState state,
    Widget Function(String email) page,
  ) {
    final email = state.extra;
    if (email is! String || email.trim().isEmpty) {
      return const RouteErrorPage(error: null);
    }
    return page(email);
  }

  static final GoRouter router = GoRouter(
    initialLocation: RoutersName.splash,
    routes: [
      ...HomeRoutes.routes,
      ...NotificationsRoutes.routes,
      ...JoinCompanyRoutes.routes,
      ...SplashRoutes.routes,
      ...OnboardingRoutes.routes,
      ...AuthRoutes.routes,
      ...AppPermissionsRoutes.routes,
      // Route & Fleet shell (map + bottom navigation). Kept from
      // feature/integration-all-features so the route/fleet flow stays reachable.
      GoRoute(
        path: RoutersName.mainLayoutScreen,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: BlocProvider<RouteFleetCubit>(
            create: (_) => getIt<RouteFleetCubit>(),
            child: const MainLayoutScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      // Orders (feature/orders). The Orders tab inside MainLayout hosts the same
      // page; this route keeps it reachable directly.
      GoRoute(
        path: RoutersName.ordersScreen,
        builder: (context, state) => const OrdersTodayPage(),
      ),
      // SettingsPage provides its own SettingsCubit, so no BlocProvider here.
      GoRoute(
        path: RoutersName.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // ── Settings sub-pages ──────────────────────────────────────────
      GoRoute(
        path: RoutersName.editProfileScreen,
        builder: (context, state) =>
            _withProfile(state, (profile) => EditProfilePage(profile: profile)),
      ),
      GoRoute(
        path: RoutersName.vehicleScreen,
        builder: (context, state) =>
            _withProfile(state, (profile) => VehiclePage(profile: profile)),
      ),
      GoRoute(
        path: RoutersName.navigationSettingsScreen,
        builder: (context, state) =>
            _withProfile(state, (profile) => NavigationPage(profile: profile)),
      ),
      GoRoute(
        path: RoutersName.notificationsSettingsScreen,
        builder: (context, state) => _withProfile(
          state,
          (profile) => NotificationsPage(profile: profile),
        ),
      ),
      GoRoute(
        path: RoutersName.locationAccessScreen,
        builder: (context, state) => _withProfile(
          state,
          (profile) => LocationAccessPage(profile: profile),
        ),
      ),
      GoRoute(
        path: RoutersName.myCompanyScreen,
        builder: (context, state) =>
            _withProfile(state, (profile) => MyCompanyPage(profile: profile)),
      ),
      GoRoute(
        path: RoutersName.languageScreen,
        builder: (context, state) => const LanguagePage(),
      ),
      GoRoute(
        path: RoutersName.themeScreen,
        builder: (context, state) => const ThemePage(),
      ),
      GoRoute(
        path: RoutersName.myFleetsScreen,
        builder: (context, state) => const MyFleetsPage(),
      ),
      GoRoute(
        path: RoutersName.joinWithCodeScreen,
        builder: (context, state) => const JoinWithCodePage(),
      ),
      GoRoute(
        path: RoutersName.helpCenterScreen,
        builder: (context, state) => const HelpCenterPage(),
      ),
      GoRoute(
        path: RoutersName.reportProblemScreen,
        builder: (context, state) => const ReportProblemPage(),
      ),
      GoRoute(
        path: RoutersName.reportSentScreen,
        builder: (context, state) {
          final args = state.extra;
          if (args is! ReportSentArgs) {
            return const RouteErrorPage(error: null);
          }
          return ReportSentPage(
            firstName: args.firstName,
            email: args.email,
            reference: args.reference,
          );
        },
      ),
      GoRoute(
        path: RoutersName.fleetRequestPendingScreen,
        builder: (context, state) {
          final args = state.extra;
          if (args is! FleetRequestArgs) {
            return const RouteErrorPage(error: null);
          }
          return MyFleetsRequestPendingPage(
            fleet: args.fleet,
            sentAt: args.sentAt,
          );
        },
      ),
      GoRoute(
        path: RoutersName.changePasswordScreen,
        builder: (context, state) =>
            _withEmail(state, (email) => ChangePasswordPage(email: email)),
      ),
      GoRoute(
        path: RoutersName.passwordUpdatedScreen,
        builder: (context, state) =>
            _withEmail(state, (email) => PasswordUpdatePage(email: email)),
      ),
      GoRoute(
        path: RoutersName.settingsForgotPasswordScreen,
        builder: (context, state) => _withEmail(
          state,
          (email) => SettingsForgotPasswordPage(email: email),
        ),
      ),
      GoRoute(
        path: RoutersName.settingsOtpScreen,
        builder: (context, state) =>
            _withEmail(state, (email) => OtpScreenSetting(email: email)),
      ),
      GoRoute(
        path: RoutersName.changePasswordForgotScreen,
        pageBuilder: (context, state) => SmartAnimatePage<void>(
          key: state.pageKey,
          child: _withEmail(
            state,
            (email) => ChangePasswordForgotPage(email: email),
          ),
        ),
      ),
      GoRoute(
        path: RoutersName.passwordUpdatedForgotScreen,
        pageBuilder: (context, state) => SmartAnimatePage<void>(
          key: state.pageKey,
          child: _withEmail(
            state,
            (email) => PasswordUpdateForgotPage(email: email),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => RouteErrorPage(error: state.error),
  );
}
