// lib/features/settings/presentation/pages/otp_screen_setting.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_otp_view.dart';
import '../../domain/usecases/send_password_reset_code_usecase.dart';
import '../../domain/usecases/verify_password_reset_code_usecase.dart';

/// Verifies the reset code for the forgot-password flow started from
/// settings, using the shared [AuthOtpView] without the wordmark.
///
/// A rejected code is shown inline (red boxes, error envelope, "The code you
/// entered is incorrect."); a failed resend is a snackbar instead, since the
/// code itself was not wrong.
class OtpScreenSetting extends StatefulWidget {
  const OtpScreenSetting({super.key, required this.email});

  /// Where the code was sent.
  final String email;

  @override
  State<OtpScreenSetting> createState() => _OtpScreenSettingState();
}

class _OtpScreenSettingState extends State<OtpScreenSetting> {
  static const _resendCooldown = 30;

  Timer? _timer;
  int _resendSeconds = _resendCooldown;
  bool _isBusy = false;
  bool _codeRejected = false;

  @override
  void initState() {
    super.initState();
    // A code was just sent, so resend starts on cooldown.
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _resendSeconds = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) timer.cancel();
    });
  }

  Future<void> _verify(String code) async {
    setState(() => _isBusy = true);
    final bool valid;
    try {
      valid = await getIt<VerifyPasswordResetCodeUseCase>()(
        email: widget.email,
        code: code,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showError(context.tr.somethingWentWrong);
      return;
    }
    if (!mounted) return;
    if (!valid) {
      setState(() {
        _isBusy = false;
        _codeRejected = true;
      });
      return;
    }
    // The code is spent, so the OTP screen is replaced, not kept below.
    context.pushReplacement(RoutersName.changePasswordForgotScreen, extra: widget.email);
  }

  Future<void> _resend() async {
    setState(() {
      _isBusy = true;
      _codeRejected = false;
    });
    try {
      await getIt<SendPasswordResetCodeUseCase>()(widget.email);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showError(context.tr.somethingWentWrong);
      return;
    }
    if (!mounted) return;
    setState(() => _isBusy = false);
    _startCooldown();
  }

  void _showError(String message) {
    ErrorAlertDialog.show(
      context: context,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final canResend = _resendSeconds <= 0 && !_isBusy;
    return RouteXLoadingOverlay(
      isLoading: _isBusy,
      child: Scaffold(
        backgroundColor: AppColors.brandBackground,
        body: SafeArea(
          child: AuthOtpView(
            showLogo: false,
            title: tr.checkYourEmail,
            titleHighlight: tr.checkYourEmailHighlight,
            subtitle: tr.settingsOtpSentMessage,
            email: widget.email,
            hasError: _codeRejected,
            // Not a validation key, so the view shows it as-is.
            errorMessage: tr.otpCodeMismatchTitle,
            isLoading: _isBusy,
            canResend: canResend,
            remainingSeconds: _resendSeconds,
            onCodeEntered: (code) {
              if (code.length == 6 && !_isBusy) _verify(code);
            },
            onErrorReset: () {
              if (_codeRejected) setState(() => _codeRejected = false);
            },
            onResendTapped: canResend ? _resend : null,
          ),
        ),
      ),
    );
  }
}
