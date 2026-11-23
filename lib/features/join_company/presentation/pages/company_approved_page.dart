// lib/features/join_company/presentation/pages/company_approved_page.dart
import 'package:flutter/material.dart';
import '../widgets/company_logo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/orders_today_metrics.dart';
import '../bloc/join_company_bloc.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Screen J13 — the company approved the request ("You're in!").
///
/// "Go to Home" -> HM0 (Home loading) inside the main shell.
class CompanyApprovedPage extends StatelessWidget {
  const CompanyApprovedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinCompanyBloc>.value(
      value: getIt<JoinCompanyBloc>(),
      child: const _CompanyApprovedView(),
    );
  }
}

class _CompanyApprovedView extends StatelessWidget {
  const _CompanyApprovedView();

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final state = context.watch<JoinCompanyBloc>().state;
    final status = state.reviewStatus;
    final company = status?.company ?? state.verifiedCompany;
    final companyName = company?.name ?? '';

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.screenGutter.w),
          child: Column(
            children: [
              SizedBox(height: 90.h),
              Assets.images.png.imgSuccess.image(width: 100.r, height: 100.r),
              SizedBox(height: 24.h),
              Text(
                tr.joinApprovedTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.s36Bold.scaled.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  tr.joinApprovedBody(companyName),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s16Regular.scaled.copyWith(
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              SizedBox(height: 56.h),
              _VehicleCard(
                title: status?.vehicleTitle ?? 'Toyota Hiace · Van',
                details: status?.vehicleDetails ?? 'Plate PAL-99488 · White',
                help: tr.joinApprovedVehicleHelp(companyName),
              ),
              SizedBox(height: AppSpacing.s12.h),
              _CompanyCard(
                name: companyName,
                logoAsset: company?.logoAsset ?? '',
              ),
              const Spacer(),
              RouteXTapScale(
                onTap: () => context.go(RoutersName.mainLayoutScreen),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.brandMain,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tr.joinApprovedGoHome,
                        style: AppTextStyles.s20Bold.scaled.copyWith(
                          color: AppColors.brandBlack,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 24.sp,
                        color: AppColors.brandBlack,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 34.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Your vehicle · Set by your company" card (green outline).
class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.title,
    required this.details,
    required this.help,
  });

  final String title;
  final String details;
  final String help;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s16.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
        border: Border.all(color: AppColors.brandMain, width: 1.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr.joinApprovedYourVehicle,
                  style: AppTextStyles.s16Bold.scaled.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SvgPicture.asset(
                AppAssets.icLock,
                width: 16.r,
                height: 16.r,
                colorFilter: ColorFilter.mode(
                  AppColors.textMuted,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                tr.joinApprovedSetByCompany,
                style: AppTextStyles.s14Regular.scaled.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brandMain, width: 1.5.w),
                ),
                child: SvgPicture.asset(
                  AppAssets.icVan,
                  width: 26.r,
                  height: 26.r,
                  colorFilter: const ColorFilter.mode(
                    AppColors.brandMain,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s20Medium.scaled.copyWith(
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
          SizedBox(height: 14.h),
          Text(
            help,
            style: AppTextStyles.s14Regular.scaled.copyWith(
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Red Sea Express · Your company · Active" card.
class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.name, required this.logoAsset});

  final String name;
  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.s16.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
        border: Border.all(color: AppColors.brandMain, width: 1.5.w),
      ),
      child: Row(
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
                  style: AppTextStyles.s16Bold.scaled.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  tr.joinApprovedYourCompany,
                  style: AppTextStyles.s14Regular.scaled.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandMain,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  tr.joinApprovedActive,
                  style: AppTextStyles.s14Bold.scaled.copyWith(
                    color: AppColors.textOnlineGreen,
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
