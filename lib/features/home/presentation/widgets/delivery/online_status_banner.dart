// lib/features/home/presentation/widgets/delivery/online_status_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

/// First-day content — Figma HM5 (Node 6410:56288).
///
/// Layout:
/// 1. "Waiting for first order" card: 360 x 145 (live dot 18x18 animated, heading 25h, 2-line body).
/// 2. 22px space.
/// 3. "HOW YOUR DAY WORKS" label.
/// 4. 10px space.
/// 5. "How it works" card: 360 x 245 with 3 steps (28x28 numbered green circle, 2px connector, bold title + 1-line desc).
/// 6. 22px space.
/// 7. "BEFORE YOUR FIRST ORDER" label.
/// 8. 10px space.
/// 9. Checklist card: 360 x 192 with 3 rows 60h separated by dividers inset 17
///    (36x36 lime icon container + styled value pill on right, e.g. "✓ On", "✓ Always", "Toyota Hiace").
class OnlineStatusBanner extends StatelessWidget {
  const OnlineStatusBanner({
    required this.dashboard,
    super.key,
  });

  final DeliveryDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Waiting for first order card (360 x 145) ──────────────────────
        _WaitingForOrderCard(companyName: dashboard.companyName),
        SizedBox(height: 22.h),

        // ── 2. "HOW YOUR DAY WORKS" label ───────────────────────────────────
        SizedBox(
          height: 17.h,
          child: Text(
            context.tr.homeHowYourDayWorks,
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
        ),
        SizedBox(height: 8.h),

        // ── 3. "How it works" card (360 x 245) ──────────────────────────────
        _HowItWorksCard(steps: dashboard.firstDaySteps),
        SizedBox(height: 22.h),

        // ── 4. "BEFORE YOUR FIRST ORDER" label ──────────────────────────────
        SizedBox(
          height: 17.h,
          child: Text(
            context.tr.homeBeforeFirstOrder,
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
        ),
        SizedBox(height: 8.h),

        // ── 5. Checklist card (360 x 192) ───────────────────────────────────
        _ChecklistCard(items: dashboard.firstDayChecklist),
      ],
    );
  }
}

// ─── Waiting for first order card (360 x 145) ─────────────────────────────────

class _WaitingForOrderCard extends StatefulWidget {
  const _WaitingForOrderCard({required this.companyName});

  final String companyName;

  @override
  State<_WaitingForOrderCard> createState() => _WaitingForOrderCardState();
}

class _WaitingForOrderCardState extends State<_WaitingForOrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 145.h),
      // 21 from the outer edge in the design = 1 border + 20 padding.
      padding: EdgeInsets.all((AppSizes.cardInnerPad21 - 1).r),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live dot + "You're online with..."
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Opacity(
                  opacity: _pulse.value,
                  child: Container(
                    width: 18.r,
                    height: 18.r,
                    decoration: BoxDecoration(
                      color: AppColors.deliveredMarkerFill,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: AppColors.brandMain,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  context.tr.homeOnlineWithCompany(widget.companyName),
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Heading (20sp, 26 high)
          Text(
            context.tr.homeWaitingFirstOrder,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
              height: 26 / 20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),

          // Two-line description
          Text(
            context.tr.homeWaitingFirstOrderBody,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              height: 20 / 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── How it works card (360 x 245) ───────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({this.steps = const []});

  final List<FirstDayStep> steps;

  @override
  Widget build(BuildContext context) {
    final effectiveSteps = steps.isNotEmpty
        ? steps
        : [
            FirstDayStep(
              stepNumber: 1,
              title: context.tr.homeStep1Title,
              description: context.tr.homeStep1Desc,
            ),
            FirstDayStep(
              stepNumber: 2,
              title: context.tr.homeStep2Title,
              description: context.tr.homeStep2Desc,
            ),
            FirstDayStep(
              stepNumber: 3,
              title: context.tr.homeStep3Title,
              description: context.tr.homeStep3Desc,
            ),
          ];

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 244.h),
      padding: EdgeInsets.symmetric(
        horizontal: (AppSizes.cardInnerPad21 - 1).w,
        vertical: (AppSizes.cardInnerPad21 - 1).h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(effectiveSteps.length, (index) {
          final step = effectiveSteps[index];
          final isLast = index == effectiveSteps.length - 1;
          return _StepRow(
            number: '${step.stepNumber}',
            title: step.title,
            desc: step.description,
            isLast: isLast,
          );
        }),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.desc,
    required this.isLast,
  });

  final String number;
  final String title;
  final String desc;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isLast ? 42.h : 80.h,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number circle (28x28 in lime-green) + vertical connector (2px)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.stepMarker.r,
              height: AppSizes.stepMarker.r,
              decoration: const BoxDecoration(
                color: AppColors.brandMain,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlack,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 42.h,
                color: AppColors.borderDeactivated,
              ),
          ],
        ),
        SizedBox(width: 14.w),

        // Text column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 20 / 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                desc,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontFamilyFallback: AppFonts.fontFamilyFallback,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  height: 18 / 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}

// ─── Checklist card (360 x 192) ───────────────────────────────────────────────

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.items});

  final List<FirstDayCheckItem> items;

  @override
  Widget build(BuildContext context) {
    final effectiveItems = items.isNotEmpty
        ? items
        : [
            FirstDayCheckItem(
              id: 'c1',
              title: context.tr.homeNotificationsSetting,
              status: context.tr.homeStatusOn,
              iconAsset: AppAssets.icBell,
            ),
            FirstDayCheckItem(
              id: 'c2',
              title: context.tr.homeLocationAccess,
              status: context.tr.homeStatusAlways,
              iconAsset: AppAssets.icPin,
            ),
            FirstDayCheckItem(
              id: 'c3',
              title: context.tr.homeYourVehicle,
              status: context.tr.homeStatusToyotaHiace,
              iconAsset: AppAssets.icVan,
            ),
          ];

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 192.h),
      // 4px inner padding top/bottom: rows are 60 high, card is 192.
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(effectiveItems.length, (index) {
          final item = effectiveItems[index];
          final isLast = index == effectiveItems.length - 1;
          final iconPath = item.iconAsset ??
              (index == 0
                  ? AppAssets.icBell
                  : index == 1
                      ? AppAssets.icPin
                      : AppAssets.icVan);

          return Column(
            children: [
              _ChecklistRow(
                iconAsset: iconPath,
                title: item.title,
                pillText: item.status,
                pillFill: index == effectiveItems.length - 1
                    ? AppColors.surfaceUpNext
                    : AppColors.deliveredMarkerFill,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSizes.attentionDividerInset.w,
                  endIndent: AppSizes.attentionDividerInset.w,
                  color: AppColors.dividerSubtle,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.iconAsset,
    required this.title,
    required this.pillText,
    required this.pillFill,
  });

  final String iconAsset;
  final String title;
  final String pillText;
  final Color pillFill;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 60.h),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.attentionDividerInset.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 36 x 36 Icon container — lime green circle
          Container(
            width: AppSizes.attentionIconContainer.r,
            height: AppSizes.attentionIconContainer.r,
            decoration: const BoxDecoration(
              color: AppColors.brandMain,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                iconAsset,
                width: 18.r,
                height: 18.r,
                colorFilter: ColorFilter.mode(
                  AppColors.brandBlack,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),

          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontFamilyFallback: AppFonts.fontFamilyFallback,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status pill on the right
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: pillFill,
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(
                color: AppColors.brandMain,
                width: 1,
              ),
            ),
            child: Text(
              pillText,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontFamilyFallback: AppFonts.fontFamilyFallback,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.brandMain,
                height: 16 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
