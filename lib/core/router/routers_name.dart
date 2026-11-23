// lib/core/router/routers_name.dart
class RoutersName {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  static const String forgetPasswordScreen = '/forget_password_screen';
  static const String forgetPasswordOtpScreen = '/forget_password_otp_screen';
  static const String otpVerificationScreen = '/otp_verification_screen';
  static const String setNewPasswordScreen = '/set_new_password_screen';

  static const String signupFlowScreen = '/signup_flow_screen';
  static const String signupStep1Screen = signupFlowScreen;
  static const String youreAllSetScreen = '/youre_all_set_screen';

  static const String appPermissionsScreen = '/app_permissions_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String mainLayoutScreen = '/main_layout_screen';

  static const String findFleetScreen = '/find_fleet_screen';
  static const String notificationsScreen = '/notifications_screen';
  static const String enterFleetCodeScreen = '/enter_fleet_code_screen';
  static const String joinCompanyScreen = '/join_company_screen';
  static const String confirmCompanyScreen = '/confirm_company_screen';
  static const String companyUnderReviewScreen = '/company_under_review_screen';
  static const String companyApprovedScreen = '/company_approved_screen';
  static const String companyDeclinedScreen = '/company_declined_screen';
  static const String homeScreen = '/home_screen';
  static const String settings = '/settings';

  // ── Settings sub-pages ────────────────────────────────────────────────
  // extra: SettingsProfileArgs
  static const String editProfileScreen = '/edit_profile_screen';
  static const String vehicleScreen = '/vehicle_screen';
  static const String navigationSettingsScreen = '/navigation_settings_screen';
  static const String notificationsSettingsScreen = '/notifications_settings_screen';
  static const String locationAccessScreen = '/location_access_screen';
  static const String myCompanyScreen = '/my_company_screen';

  // no extra
  static const String languageScreen = '/language_screen';
  static const String themeScreen = '/theme_screen';
  static const String myFleetsScreen = '/my_fleets_screen';
  static const String joinWithCodeScreen = '/join_with_code_screen';
  static const String helpCenterScreen = '/help_center_screen';
  static const String reportProblemScreen = '/report_problem_screen';

  // extra: ReportSentArgs
  static const String reportSentScreen = '/report_sent_screen';

  // extra: FleetRequestArgs
  static const String fleetRequestPendingScreen = '/fleet_request_pending_screen';

  // extra: account email (String)
  static const String changePasswordScreen = '/change_password_screen';
  static const String passwordUpdatedScreen = '/password_updated_screen';
  static const String settingsForgotPasswordScreen = '/settings_forgot_password_screen';
  static const String settingsOtpScreen = '/settings_otp_screen';
  static const String changePasswordForgotScreen = '/change_password_forgot_screen';
  static const String passwordUpdatedForgotScreen = '/password_updated_forgot_screen';

  // ── Orders (feature/orders) ──
  static const String ordersScreen = '/orders_screen';
  static const String orders = ordersScreen;
}
