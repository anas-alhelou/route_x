import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_auth_frame.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/widgets/dialogs/api_error_dialog.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_signup_progress.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/navigation/signup_navigator.dart';
import 'package:routex_mobile/features/auth/presentation/pages/signup_step1_content.dart';
import 'package:routex_mobile/features/auth/presentation/pages/signup_step2_content.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/signup_back_button.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';

/// Shell of the two-step sign-up flow: ① Your details, ② Password.
///
/// Owns the [SignupBloc] for the whole flow, drives the [PageView] between the
/// two steps from the bloc's `currentStep`, and pushes OTP verification once
/// the bloc reports `SignupStatus.registered` (the password step submits the
/// registration directly, so there is no review step).
class SignupFlowPage extends StatefulWidget {
  const SignupFlowPage({super.key});

  @override
  State<SignupFlowPage> createState() => _SignupFlowPageState();
}

/// Whether [_SignupFlowPageState._onCurrentStepChanged] must run for this state
/// change: the step moved, step 1 just completed, or the account was just
/// registered. The last case does not change the step, so leaving it out meant
/// a successful registration never opened the OTP screen.
@visibleForTesting
bool shouldHandleStepChange(SignupState previous, SignupState current) =>
    previous.currentStep != current.currentStep ||
    (current.status == SignupStatus.step1Complete &&
        previous.status != current.status) ||
    (current.status == SignupStatus.registered &&
        previous.status != current.status);

class _SignupFlowPageState extends State<SignupFlowPage> {
  final PageController _pageController = PageController();
  late final SignupBloc _bloc;
  int _currentPage = 0;

  /// The [SignupState.profileEditRequestId] this shell already acted on.
  ///
  /// Seeded from the bloc so the shell does not treat requests raised before it
  /// was built (or across a rebuild) as new. A fresh request can only come from
  /// "Use a different email" on the OTP screen, which asks the flow to return
  /// to Step 1 so the address can be corrected.
  late int _handledProfileEditRequestId;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<SignupBloc>();
    _handledProfileEditRequestId = _bloc.state.profileEditRequestId;
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onPageChanged() {
    if (!mounted) return;
    final page = _pageController.page;
    if (page == null) return;
    final currentPage = page.round().clamp(0, 1).toInt();
    if (currentPage == _currentPage) return;
    setState(() {
      _currentPage = currentPage;
    });
  }

  void _onBackPressed() {
    if (_currentPage == 0) {
      // Exit the signup flow entirely.
      context.pop();
      return;
    }
    if (!_pageController.hasClients) return;

    // Revert Bloc status to initial BEFORE animating so the BlocListener
    // does not see step1Complete and re-navigate forward.
    _bloc.add(const SignupBackToStep1Requested());
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onCurrentStepChanged(BuildContext context, SignupState state) {
    if (state.status == SignupStatus.registered) {
      SignupNavigator.goToOtpVerification(context);
      return;
    }

    var targetPage = state.currentStep - 1;
    if (targetPage < 0 || targetPage > 1) return;
    if (targetPage == _currentPage) {
      if (state.status != SignupStatus.step1Complete || _currentPage != 0) {
        return;
      }
      targetPage = 1;
    }
    if (!_pageController.hasClients) return;

    if (targetPage > _currentPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Returns to Step 1 when the OTP screen asks for a different email.
  ///
  /// Dispatching [SignupBackToStep1Requested] both resets the flow (status back
  /// to initial, password wiped) and, through [_onCurrentStepChanged], drives
  /// the [PageView] back to the first page.
  void _onProfileEditRequested(BuildContext context, SignupState state) {
    if (state.profileEditRequestId == _handledProfileEditRequestId) return;
    _handledProfileEditRequestId = state.profileEditRequestId;
    _bloc.add(const SignupBackToStep1Requested());
  }

  /// Reports a failure raised while the flow is on one of its two steps.
  ///
  /// Both local validation and the `POST /auth/register` request fail on Step 2,
  /// so the dialog names what went wrong and lets the user fix it before tapping
  /// "Create account" again.
  void _onFailure(BuildContext context, SignupState state) {
    if (state.currentStep > 2) return;
    context.showApiError(state.errorMessage);
  }

  /// The localized name of the step currently shown, used by the textual
  /// progress indicator (e.g. "Your details", "Password").
  String _stepLabel(BuildContext context) {
    switch (_currentPage) {
      case 0:
        return context.tr.signupStepYourDetails;
      default:
        return context.tr.signupStepPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = MultiBlocListener(
      listeners: [
        BlocListener<SignupBloc, SignupState>(
          listenWhen: shouldHandleStepChange,
          listener: _onCurrentStepChanged,
        ),
        BlocListener<SignupBloc, SignupState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == SignupStatus.failure,
          listener: _onFailure,
        ),
        BlocListener<SignupBloc, SignupState>(
          listenWhen: (previous, current) =>
              previous.profileEditRequestId != current.profileEditRequestId,
          listener: _onProfileEditRequested,
        ),
      ],
      child: PopScope(
        canPop: _currentPage == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _onBackPressed();
        },
        child: BlocBuilder<SignupBloc, SignupState>(
          builder: (context, state) {
            return RouteXLoadingOverlay(
              isLoading: state.status == SignupStatus.loading,
              child: Scaffold(
                backgroundColor: AppColors.brandBackground,
                body: RouteXAuthFrame(
                  child: Column(
                    children: [
                      // ── Back button (hidden on step 1) ───────────────────────
                      if (_currentPage != 0)
                        Padding(
                          padding: EdgeInsets.fromLTRB(26.w, 12.h, 26.w, 0),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: SignupBackButton(onPressed: _onBackPressed),
                          ),
                        ),
                      // ── Progress indicator ───────────────────────────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          26.w,
                          (_currentPage == 0 ? 29 : 12).h,
                          26.w,
                          0,
                        ),
                        child: RouteXSignupProgress(
                          currentStep: _currentPage + 1,
                          totalSteps: 2,
                          label: _stepLabel(context),
                        ),
                      ),
                      SizedBox(height: (_currentPage == 0 ? 16 : 25).h),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            SignupStep1Content(onBack: _onBackPressed),
                            SignupStep2Content(onBack: _onBackPressed),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    return BlocProvider<SignupBloc>.value(value: _bloc, child: flow);
  }
}
