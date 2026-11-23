import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:routex_mobile/features/onboarding/presentation/pages/onboarding_page.dart';

abstract final class OnboardingRoutes {
  const OnboardingRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      path: RoutersName.onboarding,
      builder: (context, state) => BlocProvider<OnboardingCubit>(
        create: (_) => getIt<OnboardingCubit>(),
        child: const OnboardingPage(),
      ),
    ),
  ];
}
