import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:routex_mobile/features/splash/presentation/pages/splash_page.dart';

abstract final class SplashRoutes {
  const SplashRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      path: RoutersName.splash,
      builder: (context, state) => BlocProvider<SplashCubit>(
        create: (_) => getIt<SplashCubit>(),
        child: const SplashPage(),
      ),
    ),
  ];
}
