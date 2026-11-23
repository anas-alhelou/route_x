import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/direction_mirror_extension.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import '../../domain/entities/company.dart';
import '../bloc/join_company_bloc.dart';
import '../widgets/confirm_company_card.dart';
import '../widgets/privacy_footnote.dart';
import '../widgets/what_happens_next_card.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Screen J04 (Confirm company).
class ConfirmCompanyPage extends StatelessWidget {
  const ConfirmCompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinCompanyBloc>.value(
      value: getIt<JoinCompanyBloc>(),
      child: const _ConfirmCompanyView(),
    );
  }
}

class _ConfirmCompanyView extends StatelessWidget {
  const _ConfirmCompanyView();

  /// Leaves J04. This page can be the first one in the stack (opened with
  /// `go`/`pushReplacement`), so a bare `pop()` throws "nothing to pop".
  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutersName.joinCompanyScreen);
    }
  }

  void _handleBack(BuildContext context) {
    final bloc = context.read<JoinCompanyBloc>();
    if (bloc.state.currentStep == JoinCompanyStep.enterCode) {
      // Nothing will change, so the listener below will not fire.
      _leave(context);
      return;
    }
    // Resets the flow to the code step; the listener below leaves the page.
    // Leaving here too would pop twice.
    bloc.add(const ResetToCodeInput());
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return BlocConsumer<JoinCompanyBloc, JoinCompanyState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        if (state.currentStep == JoinCompanyStep.underReview) {
          context.pushReplacementNamed(RoutersName.companyUnderReviewScreen);
        } else if (state.currentStep == JoinCompanyStep.enterCode) {
          _leave(context);
        }
      },
      builder: (context, state) {
        final bloc = context.read<JoinCompanyBloc>();
        final company = state.verifiedCompany;

        if (company == null) {
          return const RouteXLoadingOverlay(
            isLoading: true,
            child: Scaffold(
              body: SizedBox.expand(),
            ),
          );
        }

        return RouteXLoadingOverlay(
          isLoading: state.isLoading,
          child: Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.screenGutter.w,
              ),
              child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.s10.h),
                  // Top Bar: Circular 40x40 back button
                  RouteXTapScale(
                    onTap: () => _handleBack(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceWhite,
                        border: Border.all(
                          color: AppColors.borderCard,
                          width: AppSpacing.s1.w,
                        ),
                      ),
                      child: SvgPicture.asset(
                        AppAssets.icArrowLeft,
                        width: 18.w,
                        height: 18.h,
                        colorFilter: ColorFilter.mode(
                          AppColors.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ).mirroredInRtl(context),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s20.h),

                  // Header Block: "Is this your\ncompany?"
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.s32Bold.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                      children: [
                        TextSpan(text: tr.confirmCompanyTitleStart),
                        TextSpan(
                          text: tr.confirmCompanyTitleEnd,
                          style: AppTextStyles.s32Bold.copyWith(
                            color: AppColors.brandMain,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.s10.h),
                  Text(
                    tr.confirmCompanySubtitle,
                    style: AppTextStyles.s14Regular.copyWith(
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 44.h),

                  // Company Summary Card
                  ConfirmCompanyCard(
                    company: company.name.isEmpty
                        ? Company(
                            id: company.id,
                            name: company.code,
                            code: company.code,
                            logoAsset: company.logoAsset,
                          )
                        : company,
                    codeLabel: tr.confirmCompanyCodeLabel(company.code),
                  ),
                  SizedBox(height: 26.h),

                  // "What happens next" Card
                  WhatHappensNextCard(
                    title: tr.confirmCompanyWhatHappensNext,
                    step1: tr.confirmCompanyStep1(
                      company.name.isEmpty ? company.code : company.name,
                    ),
                    step2: tr.confirmCompanyStep2,
                    step3: tr.confirmCompanyStep3,
                  ),
                  SizedBox(height: 30.h),

                  // Privacy Footnote
                  PrivacyFootnote(
                    text: tr.confirmCompanyPrivacyNotice(
                      company.name.isEmpty ? company.code : company.name,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(height: AppSpacing.s32.h),

                  // Primary Button: "Send request"
                  RouteXMainButton(
                    text: tr.confirmCompanySendRequest,
                    isLoading: state.isLoading,
                    onPressed: () {
                      bloc.add(SendCompanyRequestSubmitted(company));
                    },
                  ),
                  SizedBox(height: 8.h),

                  // Secondary Button: "Not my company"
                  RouteXTapScale(
                    onTap: () => _handleBack(context),
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
                      child: Text(
                        tr.confirmCompanyNotMyCompany,
                        style: AppTextStyles.s16Bold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                ],
              ),
              ),
              ),
            ),
            ),
          ),
        ),
        );
      },
    );
  }
}
