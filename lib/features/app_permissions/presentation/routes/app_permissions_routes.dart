import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/app_permissions/presentation/controllers/permissions_cubit.dart';
import 'package:routex_mobile/features/app_permissions/presentation/views/app_permissions_page.dart';

abstract final class AppPermissionsRoutes {
  const AppPermissionsRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      path: RoutersName.appPermissionsScreen,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: BlocProvider<PermissionsCubit>(
          create: (_) => getIt<PermissionsCubit>()..checkInitialStatuses(),
          child: const AppPermissionsPage(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    ),
  ];
}
