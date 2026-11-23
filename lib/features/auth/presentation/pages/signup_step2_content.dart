import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_password_form_view.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/signup_footer_terms.dart';

/// Step 2 of the sign-up flow: create the password.
///
/// This is the final step. "Create account" validates the password and submits
/// the assembled registration to the backend from [SignupBloc]; the flow shell
/// turns `SignupStatus.registered` into navigation to OTP verification.
class SignupStep2Content extends StatefulWidget {
  const SignupStep2Content({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<SignupStep2Content> createState() => _SignupStep2ContentState();
}

class _SignupStep2ContentState extends State<SignupStep2Content>
    with AutomaticKeepAliveClientMixin<SignupStep2Content> {
  /// The [PageView] keeps this page alive, so [AuthPasswordFormView] and its
  /// `TextEditingController`s survive every page change and have to be cleared
  /// explicitly when the flow navigates backwards.
  final _formKey = GlobalKey<AuthPasswordFormViewState>();

  String _password = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _password = context.read<SignupBloc>().state.password;
  }

  void _onPasswordChanged(String password) {
    _password = password;
  }

  /// Wipes the password on any backward navigation (2 -> 1).
  ///
  /// The bloc's back handler resets `SignupState.password`, but the form's
  /// controllers are still mounted, so both the locally mirrored password and
  /// the fields themselves have to be cleared.
  ///
  /// Keyed off `currentStep` *decreasing* rather than off `state.password`
  /// becoming empty: the bloc only stores the password once step 2 is
  /// submitted, so a user who typed something and hit back without submitting
  /// would still see their text kept otherwise. Forward progress never
  /// decreases the step, so nothing is cleared while moving through the flow.
  void _onStepWentBackwards() {
    setState(() => _password = '');
    _formKey.currentState?.clearPasswords();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SignupBloc, SignupState>(
      listenWhen: (previous, current) =>
          current.currentStep < previous.currentStep,
      listener: (context, state) => _onStepWentBackwards(),
      child: AuthPasswordFormView(
        key: _formKey,
        title: context.tr.createA,
        titleHighlight: context.tr.securePassword,
        subtitle: context.tr.passwordSubtitle,
        buttonText: context.tr.createAccount,
        bottomFooter: const SignupFooterTerms(),
        initialPassword: _password,
        isScrollable: false,
        onBack: widget.onBack,
        showBackButton: false,
        signupSpacing: true,
        onSubmit: () {
          context.read<SignupBloc>().add(
            SignupStep2Submitted(password: _password),
          );
        },
        onPasswordChanged: _onPasswordChanged,
      ),
    );
  }
}
