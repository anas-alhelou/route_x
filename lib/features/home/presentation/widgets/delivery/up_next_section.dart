// lib/features/home/presentation/widgets/delivery/up_next_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

/// "UP NEXT" card — Figma HM1 (ready, 188h), HM2 (on route, 188h), HM3/HM6 (caught up, 129h).
///
/// Inner padding 21, radius 20, border #D9D9D9.
/// - Ready state: 48x48 route icon container, title (23h), subtitle (17h),
///   full-width primary button 318x56 ("Start delivery" with nav icon).
/// - On route state: 48x48 nav icon container, title (23h), subtitle (17h),
///   full-width primary button 318x56 ("Open route" with arrow-right icon).
/// - All caught up / No orders state: 129h, 48x48 sun icon container,
///   title (23h), two-line subtitle (34h), no button.
class UpNextSection extends StatelessWidget {
  const UpNextSection({
    required this.scenario,
    required this.readyOrderCount,
    required this.companyName,
    this.nextStop,
    this.onStartDelivery,
    this.onOpenRoute,
    this.isOffline = false,
    super.key,
  });

  final DeliveryScenario scenario;
  final int readyOrderCount;
  final String companyName;
  final NextStopInfo? nextStop;
  final VoidCallback? onStartDelivery;
  final VoidCallback? onOpenRoute;
  final bool isOffline;

  bool get _isCaughtUp =>
      scenario == DeliveryScenario.allCaughtUp ||
      scenario == DeliveryScenario.noOrdersToday ||
      scenario == DeliveryScenario.noOrders;

  @override
  Widget build(BuildContext context) {
    final bool effectiveOffline =
        isOffline || scenario == DeliveryScenario.offline;
    final double cardMinHeight = _isCaughtUp ? 129.h : 188.h;
    final bool isGreenCard =
        scenario == DeliveryScenario.readyToStart ||
        scenario == DeliveryScenario.onRoute ||
        scenario == DeliveryScenario.newOrderOnRoute ||
        effectiveOffline;
    final Color cardBg = isGreenCard
        ? AppColors.surfaceUpNext
        : AppColors.surfaceWhite;
    final Color cardBorder = isGreenCard
        ? AppColors.borderUpNext
        : AppColors.borderDeactivated;

    final bool isReadyOrOffline =
        scenario == DeliveryScenario.readyToStart || effectiveOffline;
    final bool isOnRoute =
        (scenario == DeliveryScenario.onRoute ||
            scenario == DeliveryScenario.newOrderOnRoute) &&
        nextStop != null;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: cardMinHeight),
      // 21 from the outer edge in the design = 1 border + 20 padding.
      padding: EdgeInsets.all((AppSizes.cardInnerPad21 - 1).r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── "UP NEXT" label ────────────────────────────────────────────────
          Text(
            context.tr.homeUpNext,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
              height: 17 / 11,
            ),
          ),
          SizedBox(height: _isCaughtUp ? 12.h : 11.h),

          // ── Content depending on scenario ──────────────────────────────────
          if (isReadyOrOffline)
            _ReadyContent(
              orderCount: readyOrderCount,
              onStartDelivery: effectiveOffline ? null : onStartDelivery,
              isOffline: effectiveOffline,
            )
          else if (isOnRoute)
            _OnRouteContent(stop: nextStop!, onOpenRoute: onOpenRoute)
          else
            _CaughtUpContent(companyName: companyName),
        ],
      ),
    );
  }
}

// ─── HM1: Ready to start content ─────────────────────────────────────────────

class _ReadyContent extends StatelessWidget {
  const _ReadyContent({
    required this.orderCount,
    this.onStartDelivery,
    this.isOffline = false,
  });

  final int orderCount;
  final VoidCallback? onStartDelivery;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 48 x 48 Icon container — solid bright lime-green circle
            Container(
              width: AppSizes.upNextIconContainer.r,
              height: AppSizes.upNextIconContainer.r,
              decoration: const BoxDecoration(
                color: AppColors.brandMain,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.icRouteCurve,
                  width: 28.r,
                  height: 28.r,
                  colorFilter: ColorFilter.mode(
                    AppColors.brandBlack,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),

            // Title + subtitle column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr.homeOrdersReadyToGo(orderCount),
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 23 / 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    context.tr.homePlanFastestRoute,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 17 / 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Full-width primary button (318 x 56)
        RouteXMainButton(
          text: isOffline
              ? context.tr.homeConnectToStartDelivery
              : context.tr.homeStartDelivery,
          onPressed: isOffline ? null : onStartDelivery,
          borderRadius: 14,
          backgroundColor: isOffline
              ? AppColors.buttonDisabledLime
              : AppColors.brandMain,
          disabledBackgroundColor: AppColors.buttonDisabledLime,
          foregroundColor: isOffline
              ? AppColors.textButtonDisabled
              : AppColors.brandBlack,
          disabledForegroundColor: AppColors.textButtonDisabled,
          leadingWidget: SvgPicture.asset(
            AppAssets.icNavArrowFilled,
            width: 18.r,
            height: 18.r,
            colorFilter: ColorFilter.mode(
              isOffline
                  ? AppColors.textButtonDisabled
                  : AppColors.brandBlack,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── HM2: On a route content ─────────────────────────────────────────────────

class _OnRouteContent extends StatelessWidget {
  const _OnRouteContent({required this.stop, this.onOpenRoute});

  final NextStopInfo stop;
  final VoidCallback? onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 48 x 48 Icon container — circular lime-green well
            Container(
              width: AppSizes.upNextIconContainer.r,
              height: AppSizes.upNextIconContainer.r,
              decoration: const BoxDecoration(
                color: AppColors.brandMain,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.icNavArrowFilled,
                  width: 22.r,
                  height: 22.r,
                  colorFilter: ColorFilter.mode(
                    AppColors.brandBlack,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),

            // Title + subtitle column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${stop.stopLabel} · ${stop.customerName}',
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 23 / 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    stop.estimatedArrival.isEmpty
                        ? stop.address
                        : '${stop.address} · ${stop.estimatedArrival}',
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 17 / 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Full-width primary button (318 x 56)
        RouteXMainButton(
          text: context.tr.homeOpenRoute,
          onPressed: onOpenRoute,
          borderRadius: 14,
          trailingWidget: SvgPicture.asset(
            AppAssets.icArrow,
            width: 16.r,
            height: 16.r,
            colorFilter: ColorFilter.mode(
              AppColors.brandBlack,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── HM3 / HM6: All caught up / No orders content (129h, no button) ──────────

class _CaughtUpContent extends StatelessWidget {
  const _CaughtUpContent({required this.companyName});

  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 48 x 48 Sun Icon container — circular lime-green well
        Container(
          width: AppSizes.upNextIconContainer.r,
          height: AppSizes.upNextIconContainer.r,
          decoration: const BoxDecoration(
            color: AppColors.brandMain,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.icSun,
              width: 24.r,
              height: 24.r,
              colorFilter: ColorFilter.mode(
                AppColors.brandBlack,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),

        // Title (23h) + two-line subtitle (34h)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr.homeAllCaughtUp,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 23 / 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                context.tr.homeNewOrdersFromCompany(companyName),
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  height: 17 / 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
