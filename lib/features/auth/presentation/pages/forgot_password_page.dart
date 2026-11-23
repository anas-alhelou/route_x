import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_auth_frame.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/dialogs/api_error_dialog.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';
import 'package:routex_mobile/core/widgets/routex_logo.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_page_header.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/core/utils/formatters.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_state.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_prompt_action_row.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/signup_back_button.dart';

/// First step of the forgot-password flow â€” collects the account email.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ForgotPasswordCubit>().reset();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ForgotPasswordCubit>().submitEmail(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.step != current.step,
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success &&
            state.step == ForgotPasswordStep.otp) {
          context.pushReplacement(
            RoutersName.forgetPasswordOtpScreen,
            extra: state.email,
          );
        } else if (state.status == ForgotPasswordStatus.failure) {
          // The address is still in the state, so the request can be repeated
          // exactly as it was made.
          context.showApiError(state.error, onRetry: _onSendResetLink);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ForgotPasswordStatus.loading;
        return RouteXLoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            backgroundColor: AppColors.brandBackground,
            body: RouteXAuthFrame(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 26.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24.h),

                    // â”€â”€ Back button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    SignupBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    // â”€â”€ RouteX wordmark â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    SizedBox(height: 24.h),
                    const RouteXLogo(),
                    SizedBox(height: 16.h),

                    RouteXPageHeader(
                      titleStart: context.tr.forgetPasswordTitle,
                      titleEnd: context.tr.forgetPasswordTitleHighlight,
                      subtitle: context.tr.forgetPasswordSubtitle,
                      titleStartSize: AppFonts.size48,
                      titleEndSize: AppFonts.size48,
                    ),

                    SizedBox(height: 32.h),

                    Form(
                      key: _formKey,
                      child: RouteXFormScope(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            RouteXTextField(
                              controller: _emailController,
                              labelText: context.tr.emailAddressLabel,
                              hintText: context.tr.enterYourEmailAddress,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [EmailSuffixFormatter()],
                              onFieldSubmitted: (_) => _onSendResetLink(),
                              validator: (value) {
                                final key = AuthValidators.validateEmail(value);
                                return key == null
                                    ? null
                                    : context.translateValidationKey(key);
                              },
                            ),
                            SizedBox(height: 32.h),
                            RouteXMainButton(
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _onSendResetLink,
                              text: context.tr.sendResetLink,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),
                    AuthPromptActionRow(
                      promptText: context.tr.rememberYourPassword,
                      actionText: context.tr.login,
                      onActionTapped: () => context.go(RoutersName.login),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
