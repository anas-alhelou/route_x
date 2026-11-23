import 'package:flutter/material.dart';
import 'package:routex_mobile/core/session/driver_identity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/utils/bidi_isolate.dart';
import 'package:routex_mobile/core/widgets/dialogs/logout_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/routex_alert_dialog.dart';
import '../../domain/entities/company_review_status.dart';
import '../bloc/join_company_bloc.dart';
import '../widgets/cancel_request_sheet.dart';
import '../widgets/review_driver_header.dart';
import '../widgets/review_status_card.dart';
import '../widgets/review_status_indicator.dart';
import '../widgets/review_timeline_card.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Screen J10 (Under review) & J10b (Checking for updates).
class CompanyUnderReviewPage extends StatelessWidget {
  const CompanyUnderReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinCompanyBloc>.value(
      value: getIt<JoinCompanyBloc>(),
      child: const _CompanyUnderReviewView(),
    );
  }
}

class _CompanyUnderReviewView extends StatelessWidget {
  const _CompanyUnderReviewView();

  void _handleLogOut(BuildContext context) {
    context.showLogoutDialog(
      onConfirm: () {
        context.go(RoutersName.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return BlocConsumer<JoinCompanyBloc, JoinCompanyState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep ||
          previous.reviewStatus?.currentStep !=
              current.reviewStatus?.currentStep,
      listener: (context, state) {
        // Leaving after "Cancel request" is done in its onConfirm, once. Doing
        // it here as well would navigate twice.
        if (state.currentStep == JoinCompanyStep.enterCode) return;
        // Figma J10b -> J13 / J12: the company answered while we checked.
        switch (state.reviewStatus?.currentStep) {
          case CompanyReviewStep.approved:
            context.pushReplacementNamed(RoutersName.companyApprovedScreen);
          case CompanyReviewStep.declined:
            context.pushReplacementNamed(RoutersName.companyDeclinedScreen);
          default:
            break;
        }
      },
      builder: (context, state) {
        final bloc = context.read<JoinCompanyBloc>();
        final companyName = bidiIsolate(
          state.reviewStatus?.company.name ??
              state.verifiedCompany?.name ??
              '',
        );
        final rawDriverName =
            state.reviewStatus?.driverName ?? DriverIdentity.current.value.name;
        final driverName = bidiIsolate(rawDriverName);

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.brandMain,
              backgroundColor: AppColors.surfaceWhite,
              onRefresh: () async {
                bloc.add(const CheckForUpdatesRequested());
                // Wait for the update cycle to complete
                await bloc.stream
                    .firstWhere((s) => !s.isCheckingForUpdates);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.screenGutter.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.s10.h),
                    // Top Identity Header
                    ReviewDriverHeader(
                      driverName: tr.underReviewGreeting(driverName),
                      avatarName: rawDriverName,
                      accountTypeLabel: tr.underReviewDriverAccount,
                      logOutLabel: tr.logOut,
                      onLogOut: () => _handleLogOut(context),
                    ),
                    SizedBox(height: 10.h),

                    // Pull-to-refresh / Tap-to-refresh Indicator Row (J10 & J10b)
                    ReviewStatusIndicator(
                      isChecking: state.isCheckingForUpdates,
                      idleText: tr.underReviewPullDown,
                      checkingText: tr.underReviewChecking,
                      onTap: () {
                        bloc.add(const CheckForUpdatesRequested());
                      },
                    ),
                    SizedBox(height: 8.h),

                    // Amber Status Card: "Waiting for Red Sea Express"
                    ReviewStatusCard(
                      title: tr.underReviewWaitingFor(companyName),
                      subtitle: tr.underReviewWaitingBody,
                      badgeLabel: tr.underReviewBadge,
                    ),
                    SizedBox(height: AppSpacing.s16.h),

                    // "Your request" Timeline Card
                    ReviewTimelineCard(
                      cardTitle: tr.underReviewYourRequest,
                      step1Title: tr.underReviewStepSent,
                      step1Time: state.reviewStatus?.sentTimeFormatted ??
                          tr.underReviewStepSentTime,
                      step2Title: tr.underReviewStepReview,
                      step2Subtitle: tr.underReviewStepInProgress,
                      step3Title: tr.underReviewStepOrders,
                    ),
                    const Spacer(),
                    SizedBox(height: AppSpacing.s32.h),

                    // Outlined button: "Contact support"
                    RouteXTapScale(
                      onTap: () {
                        RouteXAlertDialog.show(
                          context: context,
                          title: context.tr.successTitle,
                          message: tr.underReviewContactSupport,
                          icon: Icons.info_outline,
                          iconColor: AppColors.brandMain,
                          confirmLabel: context.tr.routeOk,
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        height: 56.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.borderDeactivated,
                            width: AppSpacing.s1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.icChatBubble,
                              width: 18.w,
                              height: 18.h,
                              colorFilter: ColorFilter.mode(
                                AppColors.textPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              tr.underReviewContactSupport,
                              style: AppTextStyles.s16Bold.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s8.h),

                    // Text button: "Cancel request" (Figma J10)
                    Center(
                      child: RouteXTapScale(
                        onTap: () async {
                          // Figma J11: a bottom sheet, not a centred dialog.
                          final confirmed = await showCancelRequestSheet(
                            context: context,
                            companyName: companyName,
                          );
                          if (confirmed != true || !context.mounted) return;
                          // Local cancel (no backend endpoint yet): the bloc
                          // clears the flow state, then we go to J01 once.
                          bloc.add(const CancelCompanyRequestSubmitted());
                          context.go(RoutersName.joinCompanyScreen);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          height: 44.h,
                          child: Center(
                            child: Text(
                              tr.underReviewCancelRequest,
                              style: AppTextStyles.s16Bold.copyWith(
                                color: AppColors.dangerText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s8.h),
                  ],
                ),
                ),
                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
