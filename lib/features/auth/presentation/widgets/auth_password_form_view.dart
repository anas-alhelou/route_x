import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_check_switcher.dart';
import 'package:routex_mobile/core/widgets/routex_logo.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';
import 'package:routex_mobile/core/widgets/routex_keyboard_scroll_view.dart';
import 'package:routex_mobile/core/widgets/routex_page_header.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/password_requirement_checklist.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/signup_back_button.dart';

/// Shared password-creation view used by both the signup (step 3) and the
/// forgot-password (set new password) flows.
///
/// Renders: back button, optional top header (e.g. the step progress indicator),
/// a two-tone page title, password + confirmation fields, the live
/// password-requirement checklist and a gated submit button. Pure presentation:
/// parents receive the current password via [onPasswordChanged] and are
/// notified when submission is valid via [onSubmit].
class AuthPasswordFormView extends StatefulWidget {
  const AuthPasswordFormView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onSubmit,
    this.titleHighlight,
    this.initialPassword = '',
    this.isLoading = false,
    this.isScrollable = true,
    this.topHeader,
    this.bottomFooter,
    this.onPasswordChanged,
    this.onBack,
    this.showBackButton = true,
    this.resetLayout = false,
    this.signupSpacing = false,
  });

  /// First (dark) part of the two-tone header title.
  final String title;

  /// Second (green) part of the two-tone header title.
  final String? titleHighlight;

  /// Body text displayed under the header.
  final String subtitle;

  /// Label of the primary submit button.
  final String buttonText;

  /// Called when the submit button is pressed and the form is valid.
  final VoidCallback onSubmit;

  final String initialPassword;

  /// True while the parent is persisting the password (button shows spinner).
  final bool isLoading;

  final bool isScrollable;

  /// Optional widget rendered above the title (e.g. [RouteXSignupProgress]).
  final Widget? topHeader;

  /// Optional widget rendered below the button (e.g. terms & conditions).
  final Widget? bottomFooter;

  /// Streams the current password on every change (parent may dispatch it).
  final ValueChanged<String>? onPasswordChanged;

  final VoidCallback? onBack;

  /// Whether to render the leading back button. Hosts that already provide
  /// their own back affordance above this view (e.g. the signup flow shell)
  /// pass `false` to avoid a duplicated control.
  final bool showBackButton;

  /// Whether to use the forgot-password "Set a new password" layout: brand logo
  /// under the back button, "New Password" label, "Enter password" hints,
  /// open-eye default icons and a checklist without its own heading, all placed
  /// flat on the page background.
  final bool resetLayout;

  /// Uses the sign-up design's spacing: roomier fields, no checklist
  /// heading and the sub-title tucked under the title.
  final bool signupSpacing;

  @override
  AuthPasswordFormViewState createState() => AuthPasswordFormViewState();
}

/// State of [AuthPasswordFormView].
///
/// Public so a host that mirrors the password into its own state (the signup
/// step 3, which keeps it in `SignupBloc`) can clear these fields through a
/// `GlobalKey` when that value is wiped.
class AuthPasswordFormViewState extends State<AuthPasswordFormView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasMinLength = false;
  bool _hasCapital = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.text = widget.initialPassword;
    final password = _passwordController.text;
    _hasMinLength = password.length >= 8;
    _hasCapital = password.contains(RegExp(r'[A-Z]'));
    _hasNumber = password.contains(RegExp(r'[0-9]'));
    _hasSymbol = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_checkPasswordsMatch);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _confirmPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text == _passwordController.text;
    });
  }

  /// Real-time evaluation of the password requirements, encapsulated locally
  /// so the parent does not need to track per-character state.
  void _onPasswordChanged() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasCapital = text.contains(RegExp(r'[A-Z]'));
      _hasNumber = text.contains(RegExp(r'[0-9]'));
      _hasSymbol = text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });

    // Re-evaluate the confirm field after the primary password changes.
    _checkPasswordsMatch();
    widget.onPasswordChanged?.call(text);
  }

  bool get _requirementsMet =>
      _hasMinLength && _hasCapital && _hasNumber && _hasSymbol;

  bool get _canSubmit =>
      _requirementsMet &&
      _passwordsMatch &&
      _passwordController.text.isNotEmpty;

  /// Empties both fields and re-evaluates the requirement checklist.
  ///
  /// The controllers outlive a page change, so a host that resets its own copy
  /// of the password (the signup bloc, for instance) must also clear what is
  /// still typed here. Never runs during normal typing — only when the host
  /// asks for it.
  void clearPasswords() {
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _passwordsMatch = false;
      _hasMinLength = false;
      _hasCapital = false;
      _hasNumber = false;
      _hasSymbol = false;
    });
  }

  void _onSubmitPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Defensive domain check. The button is already disabled unless the two
    // fields match, and the confirm field deliberately has no validator, so
    // this can only fail if the two drift apart between the press and this
    // callback (e.g. the password was changed from elsewhere). It is kept as a
    // real guard rather than an `if (_passwordsMatch)`, because a confirmation
    // that does not match its password must never reach the network.
    final matchError = AuthValidators.validatePasswordMatch(
      _confirmPasswordController.text,
      _passwordController.text,
    );
    if (matchError != null) return;

    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final form = RouteXFormScope(
      child: widget.isScrollable
          ? SingleChildScrollView(
              // `viewInsets` is deliberately absent: both hosts
              // (`SignupFlowPage` and `SetNewPasswordPage`) put this view inside
              // a `Scaffold` with the default `resizeToAvoidBottomInset: true`,
              // so the body is already resized above the keyboard. Adding the
              // inset again here shrank the form a second time and left a dead
              // gap under the last field.
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(26.w, 16.h, 26.w, 24.h),
              child: _buildForm(context),
            )
          : RouteXKeyboardScrollView(
              horizontalPadding: 26.w,
              compactHeight: 700,
              builder: (context, constraints, compact, contentWidth) =>
                  _buildForm(context, compact: compact),
            ),
    );

    return form;
  }

  Widget _buildForm(BuildContext context, {bool compact = false}) {
    final fieldContentPadding = EdgeInsets.symmetric(
      horizontal: 16.w,
      vertical: (compact ? 10 : 14).h,
    );

    final fieldsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RouteXTextField(
          controller: _passwordController,
          labelText: widget.resetLayout
              ? context.tr.newPassword
              : context.tr.password,
          hintText: widget.resetLayout
              ? context.tr.enterPasswordHint
              : context.tr.enterPassword,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          contentPadding: fieldContentPadding,
          prefixIcon: Assets.icons.svg.icLock.svg(width: 20.w),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword == widget.resetLayout
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textGray,
              size: 20.sp,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            final key = AuthValidators.validateLoginPassword(value);
            return key == null ? null : context.translateValidationKey(key);
          },
        ),
        SizedBox(height: (compact ? 8 : (widget.signupSpacing ? 20 : 16)).h),
        RouteXTextField(
          controller: _confirmPasswordController,
          labelText: context.tr.confirmPassword,
          hintText: widget.resetLayout
              ? context.tr.enterPasswordHint
              : context.tr.confirmPassword,
          obscureText: _obscureConfirmPassword,
          contentPadding: fieldContentPadding,
          // The field never shows a message of its own: a mismatch is
          // reported by the disabled submit button and the green tick, not by
          // red text. Spelling out the difference between two masked fields
          // is noise, and it used to flash on every keystroke.
          autovalidateMode: AutovalidateMode.disabled,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14.w, right: 10.w),
            child: Assets.icons.svg.icLock.svg(width: 20.w),
          ),
          // Keeps the check mark in its success colour instead of inheriting
          // the field's focus tint.
          tintSuffixIcon: false,
          suffixIcon: RouteXCheckSwitcher(
            child: _passwordsMatch
                ? Icon(
                    Icons.check_circle,
                    key: const ValueKey('match'),
                    color: AppColors.brandMain,
                    size: 24.sp,
                  )
                : IconButton(
                    key: const ValueKey('toggle'),
                    icon: Icon(
                      _obscureConfirmPassword == widget.resetLayout
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textGray,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
          ),
        ),
        SizedBox(height: (compact ? 12 : 24).h),
        PasswordRequirementChecklist(
          hasMinLength: _hasMinLength,
          hasCapital: _hasCapital,
          hasNumber: _hasNumber,
          hasSymbol: _hasSymbol,
          showTitle: !widget.resetLayout && !widget.signupSpacing,
          rowSpacing: widget.signupSpacing ? 12 : 10,
          labelSpacing: widget.signupSpacing ? 12 : 8,
        ),
        SizedBox(height: (compact ? 12 : (widget.signupSpacing ? 28 : 20)).h),
        RouteXMainButton(
          isLoading: widget.isLoading,
          onPressed: _canSubmit ? _onSubmitPressed : null,
          text: widget.buttonText,
        ),
      ],
    );

    final fieldsSection = fieldsColumn;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showBackButton) ...[
            SignupBackButton(
              onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
            SizedBox(height: (compact ? 6 : 16).h),
          ],
          if (widget.resetLayout) ...[
            const RouteXLogo(),
            SizedBox(height: (compact ? 8 : 16).h),
          ],
          if (widget.topHeader != null) ...[
            widget.topHeader!,
            SizedBox(height: (compact ? 12 : 32).h),
          ],
          RouteXPageHeader(
            titleStart: widget.title,
            titleEnd: widget.titleHighlight ?? '',
            subtitle: widget.subtitle,
            titleStartSize: compact ? 24 : null,
            titleEndSize: compact ? 24 : null,
            subtitleSize: compact ? 12 : null,
            subtitleGap: compact ? 16 : (widget.signupSpacing ? 9 : 16),
          ),
          SizedBox(height: (compact ? 12 : 32).h),
          fieldsSection,
          SizedBox(height: (compact ? 12 : (widget.signupSpacing ? 36 : 32)).h),
          if (widget.bottomFooter != null) ...[
            widget.bottomFooter!,
            SizedBox(height: (compact ? 8 : 24).h),
          ],
        ],
      ),
    );
  }
}
