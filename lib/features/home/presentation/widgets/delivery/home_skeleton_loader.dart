// lib/features/home/presentation/widgets/delivery/home_skeleton_loader.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Loading skeleton for the delivery dashboard — Figma HM0.
///
/// The skeleton mirrors the real dashboard: the section labels ("TODAY",
/// "UP NEXT", "NEEDS YOUR ATTENTION") are real text, every other piece of
/// content is a flat #D0D0D0 placeholder at the exact position and size of the
/// content it stands in for:
/// - 52 circle + two bars for the header (no bell while loading).
/// - 360 x 208 Today card with a flat 6-high progress line and 3-col stats.
/// - 360 x 188 Up next card with a 48 circle, two bars and a 56-high block.
/// - 360 x 133 Needs your attention card with two 36 circle rows.
class HomeSkeletonLoader extends StatefulWidget {
  const HomeSkeletonLoader({super.key});

  @override
  State<HomeSkeletonLoader> createState() => _HomeSkeletonLoaderState();
}

class _HomeSkeletonLoaderState extends State<HomeSkeletonLoader>
    with SingleTickerProviderStateMixin {
  static Color get _fill => AppColors.borderDeactivated; // #D0D0D0

  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _shimmer = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 6.0,
    bool isCircle = false,
  }) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Opacity(
        opacity: _shimmer.value,
        child: Container(
          width: width.w,
          height: height.h,
          decoration: BoxDecoration(
            color: _fill,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(radius.r),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return SizedBox(
      height: 17.h,
      child: Text(
        text,
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
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(20.r),
    border: Border.all(color: AppColors.borderDeactivated, width: 1),
  );

  // Same inner offset as the real cards: 21 from the edge = 1 border + 20.
  EdgeInsets get _cardPadding =>
      EdgeInsets.all((AppSizes.cardInnerPad21 - 1).r);

  Widget _statColumn({
    required double valueWidth,
    required double captionWidth,
    double valueHeight = 13,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5.3.h),
        _box(width: valueWidth, height: valueHeight, radius: 6),
        SizedBox(height: 11.7.h),
        _box(width: captionWidth, height: 8, radius: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.screenGutter.w),
      children: [
        // 6px under the 52 status bar, header row starts at top 58
        SizedBox(height: 6.h),

        // ── Header (55 high): 52 circle + date bar + greeting bar ───────────
        SizedBox(
          height: 55.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _box(width: 52, height: 52, isCircle: true),
              SizedBox(width: 12.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.3.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 103, height: 8, radius: 4),
                    SizedBox(height: 13.3.h),
                    _box(width: 165, height: 20, radius: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 46.5.h),

        // ── TODAY card (360 x 208) ──────────────────────────────────────────
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 208.h),
          padding: _cardPadding,
          decoration: _cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 17.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label(context.tr.homeToday),
                    _box(width: 58, height: 8, radius: 4),
                  ],
                ),
              ),
              SizedBox(height: 29.5.h),
              // Rounded square (number) + bar (“of N delivered”) at its foot
              SizedBox(
                height: 33.h,
                width: double.infinity,
                child: Stack(
                  children: [
                    PositionedDirectional(
                      start: 0,
                      top: 0,
                      child: _box(width: 29, height: 26, radius: 6),
                    ),
                    PositionedDirectional(
                      start: 37.w,
                      top: 21.7.h,
                      child: _box(width: 99, height: 11, radius: 5),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              _box(width: double.infinity, height: 6, radius: 0),
              SizedBox(height: 16.h),
              SizedBox(
                height: 42.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 96.w,
                      child: _statColumn(valueWidth: 66, captionWidth: 45),
                    ),
                    Container(
                      width: 1,
                      height: 42.h,
                      color: AppColors.dividerSubtle,
                    ),
                    Container(
                      width: 111.w,
                      padding: EdgeInsetsDirectional.only(start: 15.w),
                      child: _statColumn(valueWidth: 62, captionWidth: 47),
                    ),
                    Container(
                      width: 1,
                      height: 42.h,
                      color: AppColors.dividerSubtle,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsetsDirectional.only(start: 15.w),
                        child: _statColumn(valueWidth: 25, captionWidth: 83),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── UP NEXT card (360 x 188) ────────────────────────────────────────
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 188.h),
          padding: _cardPadding,
          decoration: _cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(context.tr.homeUpNext),
              SizedBox(height: 11.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(width: 48, height: 48, isCircle: true),
                  SizedBox(width: 14.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      _box(width: 170, height: 13, radius: 6),
                      SizedBox(height: 11.7.h),
                      _box(width: 195, height: 9, radius: 4),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _box(width: double.infinity, height: 56, radius: 14),
            ],
          ),
        ),
        SizedBox(height: 30.h),

        // ── NEEDS YOUR ATTENTION (two placeholder rows, 133 high) ───────────
        _label(context.tr.homeNeedsAttention),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 4.h),
          decoration: _cardDecoration,
          child: Column(
            children: [
              _attentionRow(titleWidth: 135, subtitleWidth: 129),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.attentionDividerInset.w,
                ),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.dividerSubtle,
                ),
              ),
              _attentionRow(titleWidth: 141, subtitleWidth: 157),
            ],
          ),
        ),

        // Bottom space so last card clears the floating nav bar
        SizedBox(height: AppSizes.homeBottomInset.h),
      ],
    );
  }

  Widget _attentionRow({
    required double titleWidth,
    required double subtitleWidth,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: AppSizes.attentionRowH.h),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.attentionDividerInset.w,
      ),
      child: Row(
        children: [
          _box(
            width: AppSizes.attentionIconContainer,
            height: AppSizes.attentionIconContainer,
            isCircle: true,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: titleWidth, height: 10, radius: 5),
                SizedBox(height: 10.h),
                _box(width: subtitleWidth, height: 8, radius: 4),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SvgPicture.asset(
            AppAssets.icChevronRight,
            width: 24.r,
            height: 24.r,
            colorFilter: ColorFilter.mode(
              AppColors.textMuted,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
