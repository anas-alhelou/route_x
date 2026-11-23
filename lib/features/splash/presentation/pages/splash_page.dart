// lib/features/splash/presentation/pages/splash_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart' show motionReduced;
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/join_company/presentation/bloc/join_company_bloc.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/splash/presentation/cubit/splash_cubit.dart';

/// The app's splash screen: shows the RouteX logo reveal animation centered
/// on screen, then navigates onward once [SplashCubit] resolves where to go.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  /// Where to go, once the cubit has decided. Navigation waits for the logo
  /// animation to finish, so the reveal is never cut off mid-way.
  String? _pendingRoute;
  bool _animationDone = false;
  bool _navigated = false;

  /// Safety net: if the Lottie file fails to load or never reports completion,
  /// the app must not stay on the splash forever.
  Timer? _fallback;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationDone = true;
        _navigateIfReady();
      }
    });
    _fallback = Timer(const Duration(seconds: 6), () {
      _animationDone = true;
      _navigateIfReady();
    });
    context.read<SplashCubit>().checkNavigationTarget();
  }

  @override
  void dispose() {
    _fallback?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Starts the reveal once the composition is parsed. With reduced motion the
  /// logo is shown in its final frame instead of playing.
  void _onCompositionLoaded(LottieComposition composition) {
    _controller.duration = composition.duration;
    if (motionReduced(context)) {
      _controller.value = 1;
      return;
    }
    _controller.forward();
  }

  void _navigateTo(String route) {
    _pendingRoute = route;
    _navigateIfReady();
  }

  void _navigateIfReady() {
    final route = _pendingRoute;
    if (_navigated || route == null || !_animationDone) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashNavigationState>(
      listener: (context, state) {
        switch (state) {
          case SplashNavigationState.navigateToHome:
            _navigateTo(RoutersName.mainLayoutScreen);
          case SplashNavigationState.navigateToCompanyRequest:
            getIt<JoinCompanyBloc>().add(const ResumeRequestRequested());
            _navigateTo(RoutersName.companyUnderReviewScreen);
          case SplashNavigationState.navigateToLogin:
            _navigateTo(RoutersName.login);
          case SplashNavigationState.navigateToOnboarding:
            _navigateTo(RoutersName.onboarding);
          case SplashNavigationState.initial:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.brandBackground,
        body: Center(
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: RepaintBoundary(
              // Driven by our own controller (not Lottie's internal one) so
              // the screen knows exactly when the reveal has finished. No
              // render cache: the animation plays once, so caching every
              // frame only adds work during that single pass.
              child: Lottie.asset(
                AppColors.isDark
                    ? AppAssets.splashAnimationDark
                    : AppAssets.splashAnimation,
                controller: _controller,
                onLoaded: _onCompositionLoaded,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
