// lib/features/join_company/presentation/pages/company_declined_page.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/session/driver_identity.dart';
import '../widgets/company_logo.dart';
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
import 'package:routex_mobile/core/widgets/dialogs/logout_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/routex_alert_dialog.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_today_metrics.dart';
import '../bloc/join_company_bloc.dart';
import '../widgets/review_driver_header.dart';
import '../widgets/review_status_indicator.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Screen J12 — the company did not approve the request.
///
/// "Join with a different code" -> J01, "Log out" -> Login.
class CompanyDeclinedPage extends StatelessWidget {
  const CompanyDeclinedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinCompanyBloc>.value(
      value: getIt<JoinCompanyBloc>(),
      child: const _CompanyDeclinedView(),
    );
  }
}

class _CompanyDeclinedView extends StatelessWidget {
  const _CompanyDeclinedView();

  void _handleLogOut(BuildContext context) {
    context.showLogoutDialog(
      onConfirm: () {
        context.go(RoutersName.login);
      },
    );
  }

  /// Starts over from J01. The old request is withdrawn first so the code
  /// screen opens empty.
  void _joinWithDifferentCode(BuildContext context) {
    context.read<JoinCompanyBloc>().add(const CancelCompanyRequestSubmitted());
    context.go(RoutersName.joinCompanyScreen);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final bloc = context.read<JoinCompanyBloc>();
    final state = context.watch<JoinCompanyBloc>().state;
    final status = state.reviewStatus;
    final company = status?.company ?? state.verifiedCompany;
    final companyName = company?.name ?? '';
    final code = company?.code ?? '';
    final driverName = status?.driverName ?? DriverIdentity.current.value.name;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandMain,
          backgroundColor: AppColors.surfaceWhite,
          onRefresh: () async {
            bloc.add(const CheckForUpdatesRequested());
            await bloc.stream.firstWhere((s) => !s.isCheckingForUpdates);
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
                      ReviewDriverHeader(
                        driverName: tr.underReviewGreeting(driverName),
                        accountTypeLabel: tr.underReviewDriverAccount,
                        logOutLabel: tr.logOut,
                        onLogOut: () => _handleLogOut(context),
                      ),
                      SizedBox(height: 10.h),
                      ReviewStatusIndicator(
                        isChecking: state.isCheckingForUpdates,
                        idleText: tr.underReviewPullDown,
                        checkingText: tr.underReviewChecking,
                        onTap: () =>
                            bloc.add(const CheckForUpdatesRequested()),
                      ),
                      SizedBox(height: 8.h),
                      _DeclinedCard(
                        title: tr.joinDeclinedTitle(companyName),
                        reason: status?.declineReason ??
                            '“We’re only taking drivers from our company. '
                                'Sorry about that.”',
                      ),
                      SizedBox(height: 15.h),
                      _RequestCard(
                        name: companyName,
                        details: status?.companyDetails ??
                            'Jeddah • Last-mile delivery',
                        logoAsset: company?.logoAsset ?? '',
                        code: code,
                        sent: status?.sentDateLabel ?? '8 Oct • 10:42',
                        reviewed: status?.reviewedDateLabel ?? '10 Oct • 14:05',
                      ),
                      SizedBox(height: 22.h),
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: 4.w),
                        child: Text(
                          tr.joinDeclinedWhatNow,
                          style: AppTextStyles.s12Bold.scaled.copyWith(
                            letterSpacing: 1.2,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      const _WhatNowCard(),
                      const Spacer(),
                      SizedBox(height: AppSpacing.s20.h),
                      RouteXTapScale(
                        onTap: () => _joinWithDifferentCode(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 56.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.brandMain,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            tr.joinDeclinedDifferentCode,
                            style: AppTextStyles.s20Bold.scaled.copyWith(
                              color: AppColors.onBrand,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
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
                                style: AppTextStyles.s16Bold.scaled.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.s16.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The red "Not approved" card with the company's reason.
class _DeclinedCard extends StatelessWidget {
  const _DeclinedCard({required this.title, required this.reason});

  final String title;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s20.r),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
        border: Border.all(color: AppColors.textError, width: 1.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceWhite,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 26.sp,
                  color: AppColors.textError,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textError,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      context.tr.joinDeclinedBadge,
                      style: AppTextStyles.s14Bold.scaled.copyWith(
                        color: AppColors.textError,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s16.h),
          Text(
            title,
            style: AppTextStyles.s24Bold.scaled.copyWith(
              height: 28 / 24,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s14.h),
          Text(
            reason,
            style: AppTextStyles.s16Regular.scaled.copyWith(
              height: 1.25,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Company, code used, when it was sent and when it was reviewed.
class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.name,
    required this.details,
    required this.logoAsset,
    required this.code,
    required this.sent,
    required this.reviewed,
  });

  final String name;
  final String details;
  final String logoAsset;
  final String code;
  final String sent;
  final String reviewed;

  Widget _fact(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.s14Regular.scaled.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.s16Bold.scaled.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s16.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
        border: Border.all(
          color: AppColors.borderDeactivated,
          width: AppSpacing.s1.w,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: CompanyLogoImage(logo: logoAsset, size: 42.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s20Bold.scaled.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s14Regular.scaled.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, thickness: 1, color: AppColors.borderCard),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fact(context, tr.joinDeclinedCodeUsed, code),
              _fact(context, tr.joinDeclinedSent, sent),
              _fact(context, tr.joinDeclinedReviewed, reviewed),
            ],
          ),
        ],
      ),
    );
  }
}

/// "What you can do now": three reassuring rows.
class _WhatNowCard extends StatelessWidget {
  const _WhatNowCard();

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final rows = <Widget>[
      _WhatNowRow(
        icon: SvgPicture.asset(
          AppAssets.icSearch,
          width: 20.r,
          height: 20.r,
          colorFilter: ColorFilter.mode(
            AppColors.brandBlack,
            BlendMode.srcIn,
          ),
        ),
        title: tr.joinDeclinedCheckCodeTitle,
        body: tr.joinDeclinedCheckCodeBody,
      ),
      _WhatNowRow(
        icon: Icon(
          Icons.apartment_outlined,
          size: 20.sp,
          color: AppColors.brandBlack,
        ),
        title: tr.joinDeclinedAnotherCompanyTitle,
        body: tr.joinDeclinedAnotherCompanyBody,
      ),
      _WhatNowRow(
        icon: SvgPicture.asset(
          AppAssets.icPerson,
          width: 20.r,
          height: 20.r,
          colorFilter: ColorFilter.mode(
            AppColors.brandBlack,
            BlendMode.srcIn,
          ),
        ),
        title: tr.joinDeclinedAccountSavedTitle,
        body: tr.joinDeclinedAccountSavedBody,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
        border: Border.all(
          color: AppColors.borderDeactivated,
          width: AppSpacing.s1.w,
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderCard,
              ),
          ],
        ],
      ),
    );
  }
}

class _WhatNowRow extends StatelessWidget {
  const _WhatNowRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final Widget icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandMain,
            ),
            child: icon,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s16Bold.scaled.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  body,
                  style: AppTextStyles.s14Regular.scaled.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
