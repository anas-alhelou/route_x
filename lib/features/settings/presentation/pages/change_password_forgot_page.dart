// lib/features/settings/presentation/pages/change_password_forgot_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';
import '../../domain/usecases/reset_forgotten_password_usecase.dart';
import '../widgets/password_rules_checklist.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';

/// Last step of the forgot-password flow started from settings: the code is
/// verified, so only the new password and its confirmation are asked for.
/// Applies it through [ResetForgottenPasswordUseCase].
class ChangePasswordForgotPage extends StatefulWidget {
  const ChangePasswordForgotPage({super.key, required this.email});

  /// Account the password belongs to; also shown on the success screen.
  final String email;

  @override
  State<ChangePasswordForgotPage> createState() => _ChangePasswordForgotPageState();
}

class _ChangePasswordForgotPageState extends State<ChangePasswordForgotPage> {
  final _formKey = GlobalKey<FormState>();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
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
      await getIt<ResetForgottenPasswordUseCase>()(
        email: widget.email,
        newPassword: _newController.text,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      context.showErrorAlertDialog(
        message: context.tr.somethingWentWrong,
      );
      return;
    }
    if (mounted) _showSuccess();
  }

  /// Back to settings, then the success screen on top, so its "Back to
  /// settings" button lands there.
  void _showSuccess() {
    // Captured first: this page's context is gone once it is popped.
    final router = GoRouter.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    router.push(RoutersName.passwordUpdatedForgotScreen, extra: widget.email);
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
                  spacing: 20,
                  padding: EdgeInsetsDirectional.fromSTEB(12.w, 16.h, 12.w, 16.h),
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
                      onChanged: (_) => setState(() {}),
                      suffixIcon: _eye(
                        _obscureNew,
                        () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (v) =>
                          _translated(AuthValidators.validateStrongPassword(v)),
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
