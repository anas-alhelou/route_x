import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_auth_frame.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/widgets/dialogs/api_error_dialog.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import 'package:routex_mobile/core/widgets/routex_error_dialog.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_state.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_password_form_view.dart';

/// Third step of the forgot-password flow â€” sets a new password once the OTP
/// has been verified.
class SetNewPasswordPage extends StatefulWidget {
  const SetNewPasswordPage({super.key});

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  String _password = '';

  /// The password handed to the cubit by the last submit.
  ///
  /// Separate from [_password] because that one keeps tracking the field while
  /// the request runs: a retry has to re-send what was actually submitted, not
  /// whatever the user has typed since.
  String _submittedPassword = '';

  void _onPasswordChanged(String password) {
    _password = password;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.step != current.step,
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success &&
            state.step == ForgotPasswordStep.reset) {
          RouteXErrorDialog.show(
            context: context,
            // Was the literal string `"context.tr.success"`, so the headline
            // read as source code in every language.
            title: context.tr.successTitle,
            message: context.tr.passwordResetSuccess,
          );
          context.go(RoutersName.login);
          context.read<ForgotPasswordCubit>().reset();
        } else if (state.status == ForgotPasswordStatus.failure) {
          final cubit = context.read<ForgotPasswordCubit>();
          context.showApiError(
            state.error,
            onRetry: () => cubit.resetPassword(_submittedPassword),
          );
        }
      },
      builder: (context, state) {
        if (!context.read<ForgotPasswordCubit>().hasResetToken) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(RoutersName.forgetPasswordScreen);
            }
          });
          return const SizedBox.shrink();
        }
        return RouteXLoadingOverlay(
          isLoading: state.status == ForgotPasswordStatus.loading,
          child: Scaffold(
            backgroundColor: AppColors.brandBackground,
            body: RouteXAuthFrame(
              child: AuthPasswordFormView(
                title: context.tr.setNewPasswordTitle,
                titleHighlight: context.tr.setNewPasswordTitleHighlight,
                subtitle: context.tr.setNewPasswordSubtitle,
                buttonText: context.tr.resetPasswordButton,
                resetLayout: true,
                isLoading: state.status == ForgotPasswordStatus.loading,
                onSubmit: () {
                  _submittedPassword = _password;
                  context.read<ForgotPasswordCubit>().resetPassword(_password);
                },
                onPasswordChanged: _onPasswordChanged,
              ),
            ),
          ),
        );
      },
    );
  }
}
