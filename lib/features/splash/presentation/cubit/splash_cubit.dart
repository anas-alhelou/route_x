// lib/features/splash/presentation/cubit/splash_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/auth/domain/usecases/check_remembered_session_usecase.dart';
import 'package:routex_mobile/features/splash/domain/usecases/check_onboarding_status_usecase.dart';

/// Destination the splash screen hands control over to once it has decided
/// which screen opens the session.
enum SplashNavigationState {
  /// Splash is still on screen (the brand delay hasn't elapsed yet).
  initial,

  /// First run: onboarding was never completed, so show the onboarding flow.
  navigateToOnboarding,

  /// Onboarding is done but no session is remembered, so ask for credentials.
  navigateToLogin,

  /// A remembered session with usable tokens was found, so skip authentication
  /// and open the main app.
  navigateToHome,

  /// A remembered session whose driver has a company request that is not
  /// approved (pending or declined): open the request screens, not home.
  navigateToCompanyRequest,
}

/// Looks at the driver's company memberships. Returns the screen to open
/// instead of home, or null to open home. May throw when offline.
typedef MembershipChecker = Future<SplashNavigationState?> Function();

/// Decides which screen opens the app session (Single Responsibility).
///
/// Resolution order, all of it local — the network is only used for the optional membership check:
///   1. onboarding not completed → onboarding;
///   2. a remembered session with tokens still on the device → home (or the
///      company request screens when the request is not approved yet; this is
///      the only step that may use the network, with a 5 s limit);
///   3. otherwise → login.
///
/// The [SplashNavigationState] is a command for the view: the cubit never
/// navigates itself, [SplashPage] performs the actual `go_router` navigation.
class SplashCubit extends Cubit<SplashNavigationState> {
  SplashCubit({
    required this.checkOnboardingStatusUseCase,
    required this.checkRememberedSessionUseCase,
    this.membershipChecker,
  }) : super(SplashNavigationState.initial);

  /// Tells whether onboarding has been completed on this device.
  final CheckOnboardingStatusUseCase checkOnboardingStatusUseCase;

  /// Tells whether a remembered session (flag + tokens) can be restored.
  final CheckRememberedSessionUseCase checkRememberedSessionUseCase;

  /// Optional check of the company request; skipped when offline or slow.
  final MembershipChecker? membershipChecker;

  /// Resolves the entry screen after the brand delay and emits it once.
  Future<void> checkNavigationTarget() async {
    await Future.delayed(const Duration(seconds: 3));

    final destination = await _resolveEntryScreen();
    if (isClosed) return;
    emit(destination);
  }

  /// Maps the local state to the screen that should open the session.
  Future<SplashNavigationState> _resolveEntryScreen() async {
    // 1. Check if onboarding is completed.
    final isOnboardingCompleted = checkOnboardingStatusUseCase();
    if (!isOnboardingCompleted) {
      return SplashNavigationState.navigateToOnboarding;
    }

    // 2. Check if a remembered session exists.
    final remembered = await checkRememberedSessionUseCase(const NoParams());
    if (remembered.getOrElse(() => false)) {
      final checker = membershipChecker;
      if (checker != null) {
        try {
          final target = await checker().timeout(const Duration(seconds: 5));
          if (target != null) return target;
        } catch (_) {
          // Offline or slow: open home as before.
        }
      }
      return SplashNavigationState.navigateToHome;
    }

    // 3. Otherwise -> navigate to login.
    return SplashNavigationState.navigateToLogin;
  }
}
