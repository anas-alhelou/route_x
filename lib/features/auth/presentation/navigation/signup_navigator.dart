import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';

class SignupNavigator {
  SignupNavigator._();

  /// Pushes the email-verification screen for the account just registered.
  ///
  /// The email must travel with the route: it is the address the OTP was sent
  /// to *and* the identifier `POST /auth/verify-otp` matches the code against.
  /// It is read from the bloc that submitted the registration so the two can
  /// never disagree.
  ///
  /// The same bloc travels along as well. The OTP screen is a sibling route, so
  /// it is not a descendant of the flow shell's `BlocProvider`, yet it has to
  /// talk back to that very bloc — e.g. to ask the flow shell to return to
  /// Step 1 after "Use a different email".
  static void goToOtpVerification(BuildContext context) {
    final bloc = context.read<SignupBloc>();
    final email = bloc.state.email.trim();
    context.push(
      RoutersName.otpVerificationScreen,
      extra: OtpVerificationArgs(email: email, signupBloc: bloc),
    );
  }
}

/// Everything the OTP route needs from the signup flow, carried as its `extra`.
///
/// Typed rather than positional so the route cannot silently mix up the email
/// and the bloc, and so a route opened without them (a deep link, for example)
/// is recognisable instead of half-initialised.
class OtpVerificationArgs {
  const OtpVerificationArgs({required this.email, required this.signupBloc});

  /// Address the code was sent to, already trimmed.
  final String email;

  /// The flow's bloc instance, so the OTP screen can dispatch back into it.
  final SignupBloc signupBloc;
}
