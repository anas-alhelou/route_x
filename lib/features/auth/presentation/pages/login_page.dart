// lib/features/auth/presentation/pages/driver_login_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_auth_frame.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart' as theme;
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import 'package:routex_mobile/core/widgets/dialogs/api_error_dialog.dart';
import 'package:routex_mobile/core/utils/formatters.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';
import 'package:routex_mobile/core/widgets/routex_logo.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_or_divider.dart';
import 'package:routex_mobile/core/widgets/routex_page_header.dart';
import 'package:routex_mobile/core/widgets/routex_social_button.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/features/auth/domain/entities/vehicle_type.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/login_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_prompt_action_row.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_underlined_button.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/google_vehicle_step.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

bool _isTestEnvironment() {
  try {
    return Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return false;
  }
}

/// Driver Login — validates credentials and authenticates the user.
/// Updated with new UI Redesign from Figma
///
/// Must be a descendant of a [BlocProvider<LoginBloc>]. On a successful
/// login ([LoginStatus.success]) it replaces itself with the home
/// navigation screen.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Whether the Google vehicle sheet is currently on screen.
  bool _isVehicleSheetOpen = false;

  /// The route the Google vehicle sheet was pushed as, kept so the flow can
  /// close it — and wait for it to be gone — before navigating away.
  Route<void>? _vehicleSheetRoute;

  /// The last attempt the user made on this screen, kept so the failure dialog's
  /// "Try again" can repeat *that* attempt rather than guess at one.
  VoidCallback? _lastAttempt;

  @override
  void initState() {
    super.initState();
    if (_isTestEnvironment()) return;
  }

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _onLoginPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final emailPhone = _emailPhoneController.text;
    final password = _passwordController.text;
    _dispatchAttempt(() {
      context.read<LoginBloc>().add(
        LoginSubmitted(email: emailPhone, password: password),
      );
    });
  }

  void _onForgotPasswordPressed() {
    context.push(RoutersName.forgetPasswordScreen);
  }

  void _onGoogleSignInPressed() {
    _dispatchAttempt(() {
      context.read<LoginBloc>().add(const LoginGoogleSignInRequested());
    });
  }

  void _dispatchAttempt(VoidCallback attempt) {
    _lastAttempt = () {
      if (!mounted) return;
      attempt();
    };
    attempt();
  }

  void _onGoogleVehicleRequested(BuildContext context) {
    final loginBloc = context.read<LoginBloc>();
    _isVehicleSheetOpen = true;

    showRoutexSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (sheetContext) {
        _vehicleSheetRoute = ModalRoute.of(sheetContext);
        return BlocProvider<LoginBloc>.value(
          value: loginBloc,
          child: _GoogleVehicleSheet(
            onSubmit: (type, number) => loginBloc.add(
              LoginGoogleVehicleSubmitted(
                vehicleType: type,
                vehicleNumber: number,
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isVehicleSheetOpen = false;
      _vehicleSheetRoute = null;
      if (loginBloc.isClosed) return;
      if (loginBloc.state.status == LoginStatus.awaitingVehicle) {
        loginBloc.add(const LoginGoogleVehicleDismissed());
      }
    });
  }

  Future<bool> _closeGoogleVehicleSheet() async {
    final route = _vehicleSheetRoute;
    final navigator = route?.navigator;
    if (!_isVehicleSheetOpen ||
        route == null ||
        navigator == null ||
        !navigator.canPop()) {
      _isVehicleSheetOpen = false;
      _vehicleSheetRoute = null;
      return false;
    }

    final popped = route.popped;
    _isVehicleSheetOpen = false;
    navigator.pop();
    await popped;
    return true;
  }

  void _onSignUpPressed() {
    context.push(RoutersName.signupFlowScreen);
  }

  void _onFieldEdited(String _) {
    _lastAttempt = null;
    context.read<LoginBloc>().add(const LoginErrorDismissed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) async {
        if (state.status == LoginStatus.success) {
          await _closeGoogleVehicleSheet();
          if (!context.mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(RoutersName.mainLayoutScreen);
          });
        } else if (state.status == LoginStatus.awaitingVehicle) {
          _onGoogleVehicleRequested(context);
        } else if (state.status == LoginStatus.failure) {
          final fromVehicleSheet = await _closeGoogleVehicleSheet();
          if (!context.mounted) return;
          final loginBloc = context.read<LoginBloc>();
          final retry = _lastAttempt;
          context.showApiError(state.errorMessage, onRetry: retry);
          if (fromVehicleSheet) {
            if (!loginBloc.isClosed &&
                loginBloc.state.status == LoginStatus.failure) {
              loginBloc.add(const LoginGoogleVehicleDismissed());
            }
          }
        }
      },
      builder: (context, state) {
        final isLoading = state.status == LoginStatus.loading;

        return RouteXLoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            backgroundColor: theme.AppColors.brandBackground,
            body: RouteXAuthFrame(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 26.w),
                      child: RouteXFormScope(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: AppSpacing.s40.h),
                              RouteXLogo(),

                              SizedBox(height: AppSpacing.s16.h),

                              // ══════════════════════════════════════════════════════════════
                              // NEW DESIGN: Split-line hero with color accent
                              // "Welcome" on first line, "back." in green on second line
                              // ══════════════════════════════════════════════════════════════
                              RouteXPageHeader(
                                titleStart: context.tr.welcomeBack,
                                titleEnd: context.tr.welcomeBackHighlight,
                                subtitle: context.tr.loginSubtitle,
                                titleStartSize: AppFonts.size48,
                                titleEndSize: AppFonts.size48,
                              ),

                              SizedBox(height: AppSpacing.s32.h),

                              // ══════════════════════════════════════════════════════════════
                              // NEW: Combined Email/Phone TextField
                              // ══════════════════════════════════════════════════════════════
                              RouteXTextField(
                                controller: _emailPhoneController,
                                labelText: context.tr.emailOrPasswordTitle,
                                hintText: context.tr.emailOrPassword,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [EmailSuffixFormatter()],
                                onChanged: _onFieldEdited,
                                validator: (val) {
                                  final err = AuthValidators.validateEmail(val);
                                  return err != null
                                      ? context.translateValidationKey(err)
                                      : null;
                                },
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(
                                    left: 14.w,
                                    right: 10.w,
                                  ),
                                  child: Icon(
                                    Icons.email_outlined,
                                    size: 20.sp,
                                    color: theme.AppColors.textGray,
                                  ),
                                ),
                              ),

                              SizedBox(height: AppSpacing.s20.h),

                              // ══════════════════════════════════════════════════════════════
                              // Password TextField
                              // ══════════════════════════════════════════════════════════════
                              RouteXTextField(
                                controller: _passwordController,
                                labelText: context.tr.password,
                                hintText: context.tr.enterPassword,
                                obscureText: _obscurePassword,
                                onChanged: _onFieldEdited,
                                onFieldSubmitted: (_) => _onLoginPressed(),
                                validator: (val) {
                                  final err =
                                      AuthValidators.validateLoginPassword(val);
                                  return err != null
                                      ? context.translateValidationKey(err)
                                      : null;
                                },
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(
                                    left: 14.w,
                                    right: 10.w,
                                  ),
                                  child: Assets.icons.svg.icLock.svg(
                                    width: 20.w,
                                    height: 20.h,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: _togglePasswordVisibility,
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20.sp,
                                  ),
                                  color: theme.AppColors.textGray,
                                ),
                              ),

                              SizedBox(height: AppSpacing.s12.h),

                              // ══════════════════════════════════════════════════════════════
                              // NEW DESIGN: Remember Me & Forget Password on same row
                              // ══════════════════════════════════════════════════════════════
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: state.rememberMe,
                                          onChanged: (value) =>
                                              context.read<LoginBloc>().add(
                                                LoginRememberMeToggled(
                                                  value: value ?? false,
                                                ),
                                              ),
                                          activeColor:
                                              theme.AppColors.brandMain,
                                          checkColor:
                                              theme.AppColors.brandWhite,
                                          side: BorderSide(
                                            color: theme
                                                .AppColors
                                                .borderDeactivated,
                                            width: 0.75.w,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              3.r,
                                            ),
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Flexible(
                                          child: InkWell(
                                            onTap: () =>
                                                context.read<LoginBloc>().add(
                                                  LoginRememberMeToggled(
                                                    value: !state.rememberMe,
                                                  ),
                                                ),
                                            child: Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                    start: 8.w,
                                                  ),
                                              child: Text(
                                                context.tr.rememberMe,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: AppFonts
                                                      .fontFamilySatoshi,
                                                  fontFamilyFallback: AppFonts
                                                      .fontFamilyFallback,
                                                  fontSize: AppFonts.size14.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: theme
                                                      .AppColors
                                                      .brandBlack,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AuthUnderlinedButton(
                                    text: context.tr.forgotPassword,
                                    onTap: _onForgotPasswordPressed,
                                    fontSize: AppFonts.size14,
                                    fontWeight: FontWeight.w400,
                                    textColor: theme.AppColors.brandBlack,
                                    lineColor: theme.AppColors.textUnderline,
                                    lineHeight: 1.h,
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.s28.h),

                              // ══════════════════════════════════════════════════════════════
                              // Log in Button
                              // ══════════════════════════════════════════════════════════════
                              RouteXMainButton(
                                isLoading: isLoading,
                                onPressed: _onLoginPressed,
                                text: context.tr.login,
                              ),

                              SizedBox(height: AppSpacing.s32.h),

                              // or divider
                              const RouteXOrDivider(),
                              SizedBox(height: AppSpacing.s32.h),

                              // ══════════════════════════════════════════════════════════════
                              // Google Sign In Button
                              // ══════════════════════════════════════════════════════════════
                              RouteXSocialButton(
                                icon: Assets.icons.svg.icGoogleG.svg(
                                  width: 24.w,
                                  height: 24.w,
                                  fit: BoxFit.contain,
                                ),
                                label: context.tr.continueWithGoogle,
                                onPressed: isLoading
                                    ? null
                                    : _onGoogleSignInPressed,
                                isLoading: isLoading,
                              ),

                              SizedBox(height: AppSpacing.s32.h),

                              // ══════════════════════════════════════════════════════════════
                              // Sign Up Prompt
                              // ══════════════════════════════════════════════════════════════
                              AuthPromptActionRow(
                                promptText: context.tr.dontHaveAccount,
                                actionText: context.tr.signUp,
                                onActionTapped: _onSignUpPressed,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bottom sheet hosting the shared [GoogleVehicleStep] form on the login screen.
///
/// Must be rendered under a [BlocProvider<LoginBloc>] that already holds the
/// page's bloc — the sheet is a separate route and cannot reach it otherwise.
class _GoogleVehicleSheet extends StatelessWidget {
  const _GoogleVehicleSheet({required this.onSubmit});

  final void Function(VehicleType type, String number) onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        final isSubmitting = state.status == LoginStatus.loading;

        return RouteXLoadingOverlay(
          isLoading: isSubmitting,
          child: Padding(
            padding: EdgeInsets.only(
              left: 26.w,
              right: 26.w,
              top: 24.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteXPageHeader(
                    titleStart: context.tr.googleVehicleTitle,
                    titleEnd: '',
                    subtitle: context.tr.googleVehicleSubtitle,
                    titleStartSize: 24,
                    titleEndSize: 24,
                    subtitleSize: 12,
                  ),
                  SizedBox(height: 24.h),
                  GoogleVehicleStep(
                    isLoading: isSubmitting,
                    onSubmit: (type, number) => onSubmit(type, number),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(context.tr.cancel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
