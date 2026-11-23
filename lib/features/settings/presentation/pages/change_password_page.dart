// lib/features/settings/presentation/pages/change_password_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_underlined_button.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../widgets/password_rules_checklist.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';

/// Current password, a new one checked live against the strong-password rules,
/// and its confirmation. [email] receives the confirmation message.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _translated(String? key) =>
      key == null ? null : context.translateValidationKey(key);

  Future<void> _update() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await getIt<ChangePasswordUseCase>()(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ErrorAlertDialog.show(
        context: context,
        message: context.tr.somethingWentWrong,
      );
      return;
    }
    if (!mounted) return;
    // Replaces this page, so leaving the success screen lands on settings.
    context.pushReplacement(RoutersName.passwordUpdatedScreen, extra: widget.email);
  }

  Widget _eye(bool obscured, VoidCallback onTap) => IconButton(
        onPressed: onTap,
        icon: Icon(
          obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 22.r,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final labelStyle = AppTextStyles.s16Medium.copyWith(
      fontSize: AppFonts.size16.sp,
      color: AppColors.textPrimary,
    );
    final inputStyle = AppTextStyles.s16Regular.copyWith(
      fontSize: AppFonts.size16.sp,
      color: AppColors.textPrimary,
    );
    final cardPadding = EdgeInsetsDirectional.fromSTEB(12.w, 16.h, 12.w, 16.h);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: RouteXFormScope(
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
              children: [
                SettingsPageHeader(
                  title: tr.settingsChangePassword,
                  subtitle: tr.changePasswordSubtitle,
                ),
                SizedBox(height: 24.h),
                SettingsCard(
                  padding: cardPadding,
                  children: [
                    RouteXTextField(
                      controller: _currentController,
                      labelText: tr.changePasswordCurrent,
                      labelStyle: labelStyle,
                      labelInset: 4,
                      textStyle: inputStyle,
                      outlinedErrorIcon: true,
                      obscureText: _obscureCurrent,
                      textInputAction: TextInputAction.next,
                      suffixIcon: _eye(
                        _obscureCurrent,
                        () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                      validator: (v) => _translated(AuthValidators.validateLoginPassword(v)),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AuthUnderlinedButton(
                        text: tr.forgotPassword,
                        fontSize: AppFonts.size16.sp,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.textPrimary,
                        lineColor: AppColors.borderDeactivated,
                        onTap: () => context.push(
                          RoutersName.settingsForgotPasswordScreen,
                          extra: widget.email,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 17.h),
                SettingsCard(
                  spacing: 20,
                  padding: cardPadding,
                  children: [
                    RouteXTextField(
                      controller: _newController,
                      labelText: tr.changePasswordNew,
                      labelStyle: labelStyle,
                      labelInset: 4,
                      textStyle: inputStyle,
                      outlinedErrorIcon: true,
                      obscureText: _obscureNew,
                      textInputAction: TextInputAction.next,
                      // Rebuilds the checklist as the user types.
                      onChanged: (_) => setState(() {}),
                      suffixIcon: _eye(
                        _obscureNew,
                        () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (v) => _translated(AuthValidators.validateStrongPassword(v)),
                    ),
                    PasswordRulesChecklist(password: _newController.text),
                    RouteXTextField(
                      controller: _confirmController,
                      labelText: tr.changePasswordConfirm,
                      hintText: tr.changePasswordConfirmHint,
                      labelStyle: labelStyle,
                      labelInset: 4,
                      textStyle: inputStyle,
                      outlinedErrorIcon: true,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      suffixIcon: _eye(
                        _obscureConfirm,
                        () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) => _translated(
                        AuthValidators.validatePasswordMatch(v, _newController.text),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 17.h),
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(14.w, 13.h, 16.w, 13.h),
                  decoration: settingsCardDecoration(radius: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: const BoxDecoration(
                          color: AppColors.brandMain,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mail_outline, size: 20.r, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.changePasswordConfirmationTo,
                              style: AppTextStyles.s16Regular.copyWith(
                                fontSize: 15.sp,
                                height: 1.35,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              widget.email,
                              style: AppTextStyles.s16Bold.copyWith(
                                fontSize: 15.sp,
                                height: 1.35,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 17.h),
                RouteXMainButton(
                  isLoading: _isSaving,
                  onPressed: _update,
                  text: tr.changePasswordUpdate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
