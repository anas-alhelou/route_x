import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/route_error_page.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/forgot_password_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/login_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/otp_verification_cubit.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/navigation/signup_navigator.dart';
import 'package:routex_mobile/features/auth/presentation/pages/forgot_password_otp_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/set_new_password_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/signup_flow_page.dart';
import 'package:routex_mobile/features/auth/presentation/pages/youre_all_set_page.dart';

abstract final class AuthRoutes {
  const AuthRoutes._();

  static List<RouteBase> get routes => [
    // loginPage
    GoRoute(
      path: RoutersName.login,
      builder: (context, state) => BlocProvider<LoginBloc>(
        create: (_) => getIt<LoginBloc>(),
        child: const LoginPage(),
      ),
    ),

    // forgetPasswordPage
    GoRoute(
      path: RoutersName.forgetPasswordScreen,
      builder: (context, state) => BlocProvider.value(
        value: getIt<ForgotPasswordCubit>(),
        child: const ForgotPasswordPage(),
      ),
    ),

    // forgetPasswordOtpPage
    GoRoute(
      path: RoutersName.forgetPasswordOtpScreen,
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return BlocProvider.value(
          value: getIt<ForgotPasswordCubit>(),
          child: ForgotPasswordOtpPage(email: email),
        );
      },
    ),

    // setNewPasswordScreen
    GoRoute(
      path: RoutersName.setNewPasswordScreen,
      builder: (context, state) => BlocProvider.value(
        value: getIt<ForgotPasswordCubit>(),
        child: const SetNewPasswordPage(),
      ),
    ),

    // signupFlowScreen
    ShellRoute(
      builder: (context, state, child) {
        return child;
      },
      routes: [
        // signupFlowScreen
        GoRoute(
          path: RoutersName.signupFlowScreen,
          builder: (context, state) => const SignupFlowPage(),
        ),
        // otpVerificationScreen
        GoRoute(
          path: RoutersName.otpVerificationScreen,
          builder: (context, state) {
            final extra = state.extra;
            final args = extra is OtpVerificationArgs ? extra : null;
            final email = args?.email.trim() ?? '';
            if (email.isEmpty || args == null) {
              return const RouteErrorPage();
            }
            return BlocProvider<SignupBloc>.value(
              value: args.signupBloc,
              child: BlocProvider<OtpVerificationCubit>(
                create: (_) => OtpVerificationCubit(
                  verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
                  email: email,
                ),
                child: OtpVerificationPage(email: email),
              ),
            );
          },
        ),
        // youreAllSetScreen
        GoRoute(
          path: RoutersName.youreAllSetScreen,
          builder: (context, state) {
            final extra = state.extra;
            final hasSession = extra is YoureAllSetArgs && extra.hasSession;
            return YoureAllSetPage(hasSession: hasSession);
          },
        ),
      ],
    ),
  ];
}
