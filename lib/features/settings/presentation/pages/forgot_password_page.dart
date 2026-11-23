// lib/features/settings/presentation/pages/forgot_password_page.dart
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
import '../../domain/usecases/send_password_reset_code_usecase.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';

/// Forgot-password entry reached from settings (change password). Sends the
/// reset code through [SendPasswordResetCodeUseCase], then opens the code
/// screen.
class SettingsForgotPasswordPage extends StatefulWidget {
  const SettingsForgotPasswordPage({super.key, required this.email});

  /// Pre-filled with the account email.
  final String email;

  @override
  State<SettingsForgotPasswordPage> createState() => _SettingsForgotPasswordPageState();
}

class _SettingsForgotPasswordPageState extends State<SettingsForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.email);
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    setState(() => _isSending = true);
    try {
      await getIt<SendPasswordResetCodeUseCase>()(email);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ErrorAlertDialog.show(
        context: context,
        message: context.tr.somethingWentWrong,
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isSending = false);
    context.push(RoutersName.settingsOtpScreen, extra: email);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
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
                  title: tr.forgotPwTitle,
                  subtitle: tr.forgotPwSubtitle,
                ),
                SizedBox(height: 24.h),
                SettingsCard(
                  spacing: 8,
                  padding: EdgeInsetsDirectional.fromSTEB(12.w, 16.h, 12.w, 16.h),
                  children: [
                    RouteXTextField(
                      controller: _emailController,
                      labelText: tr.editProfileEmail,
                      labelInset: 4,
                      labelStyle: AppTextStyles.s16Medium.copyWith(
                        fontSize: AppFonts.size16.sp,
                        color: AppColors.textPrimary,
                      ),
                      textStyle: AppTextStyles.s16Regular.copyWith(
                        fontSize: AppFonts.size16.sp,
                        color: AppColors.textPrimary,
                      ),
                      outlinedErrorIcon: true,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _send(),
                      validator: (v) {
                        final key = AuthValidators.validateEmail(v?.trim());
                        return key == null ? null : context.translateValidationKey(key);
                      },
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: 4.w),
                      child: Text(
                        tr.forgotPwEmailHint,
                        style: AppTextStyles.s14Regular.copyWith(
                          fontSize: 13.sp,
                          height: 1.3,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 17.h),
                RouteXMainButton(
                  isLoading: _isSending,
                  onPressed: _send,
                  text: tr.forgotPwSend,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
