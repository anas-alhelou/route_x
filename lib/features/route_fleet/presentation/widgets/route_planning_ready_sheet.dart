// lib/features/route_fleet/presentation/widgets/route_planning_ready_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_skeleton.dart';
import '../../domain/entities/route_stop.dart';

class _RouteIcon extends StatelessWidget {
  const _RouteIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.routeIcRoute,
      width: 18.w,
      height: 18.h,
      colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
    );
  }
}

class _NavigateIcon extends StatelessWidget {
  const _NavigateIcon({required this.isReady});
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final size = isReady ? 24.w : 22.w;
    return SvgPicture.asset(
      AppAssets.routeIcNavigate,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(isReady ? AppColors.onBrand : AppColors.brandBlack, BlendMode.srcIn),
    );
  }
}

// ── Smooth Native Spinner for Stop Row 3 in R02 ──────────────────────────────

class _StopSpinner extends StatelessWidget {
  const _StopSpinner({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32.w,
      height: 32.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3.w,
            backgroundColor: AppColors.borderDeactivated,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandMain),
          ),
          Text(
            '$index',
            style: AppTextStyles.s12Bold.copyWith(color: AppColors.brandBlack),
          ),
        ],
      ),
    );
  }
}

// ── Route Summary Chip (Pill) ────────────────────────────────────────────────

class RouteSummaryChip extends StatelessWidget {
  const RouteSummaryChip({
    super.key,
    required this.isCalculating,
    required this.stopCount,
    this.summaryText,
  });

  final bool isCalculating;
  final int stopCount;
  final String? summaryText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSizes.r100),
        boxShadow: AppTextStyles.summaryChipShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _RouteIcon(),
          SizedBox(width: 8.w),
          Text(
            context.tr.routeStopsCount(stopCount.toString()),
            style: AppTextStyles.s14Bold.copyWith(color: AppColors.brandBlack),
          ),
          SizedBox(width: 8.w),
          Text(
            isCalculating ? context.tr.routeCalculating : (summaryText ?? '6.8 km · 32 min'),
            style: AppTextStyles.s12Medium.copyWith(color: AppColors.textBody),
          ),
        ],
      ),
    );
  }
}

// ── Stop Row Component ───────────────────────────────────────────────────────

enum StopRowVariant { active, inactive, loadingSpinner }

class StopRow extends StatelessWidget {
  const StopRow({
    super.key,
    required this.index,
    required this.title,
    required this.address,
    required this.eta,
    this.variant = StopRowVariant.active,
    this.showTimeSkeleton = false,
  });

  final int index;
  final String title;
  final String address;
  final String eta;
  final StopRowVariant variant;

  /// R02: times are still being calculated, so a skeleton replaces the time text.
  final bool showTimeSkeleton;

  @override
  Widget build(BuildContext context) {
    final isActive = variant == StopRowVariant.active;
    final isLoading = variant == StopRowVariant.loadingSpinner;

    final badgeBgColor = isActive
        ? AppColors.brandMain
        : AppColors.deactivatedBadge;

    final titleStyle = AppTextStyles.s14Bold.copyWith(color: AppColors.brandBlack);
    final addressStyle = AppTextStyles.s12Regular.copyWith(color: AppColors.textBody);
    final etaStyle = AppTextStyles.s12Medium.copyWith(color: AppColors.textBody);

    return Container(
      width: 312.w,
      height: 57.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Badge / Spinner
          if (isLoading)
            _StopSpinner(index: index)
          else
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeBgColor,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: AppTextStyles.s12Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            ),
          SizedBox(width: 12.w),

          // Title & Address Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  address,
                  style: addressStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Time Text (no ETA prefix), or a skeleton while R02 calculates
          if (showTimeSkeleton)
            RouteXSkeleton.line(width: 34.w, height: 10.h, radius: 2.r)
          else
            Text(
              eta,
              style: etaStyle,
            ),
        ],
      ),
    );
  }
}

// ── Slide to Start Component ─────────────────────────────────────────────────

class SlideToStart extends StatefulWidget {
  const SlideToStart({
    super.key,
    required this.isReady,
    required this.onStartRoute,
  });

  final bool isReady;
  final VoidCallback onStartRoute;

  @override
  State<SlideToStart> createState() => _SlideToStartState();
}

class _SlideToStartState extends State<SlideToStart> {
  double _dragPosition = 0.0;
  static final double _containerWidth = 312.w;
  static final double _knobWidth = 52.w;
  static final double _maxDrag = _containerWidth - _knobWidth - 12.w; // 6 padding each side

  @override
  Widget build(BuildContext context) {
    final dragFraction = (_dragPosition / _maxDrag).clamp(0.0, 1.0);

    return Container(
      width: _containerWidth,
      height: 64.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        // R03: #F0FAEC track. R02 (calculating): #F5F6F2 track with a #F0FAEC progress part.
        color: widget.isReady ? AppColors.sliderProgressFill : AppColors.canvas,
        borderRadius: BorderRadius.circular(32.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none,
        children: [
          // R02 progress (Figma: 186 of 310 = 60% of the track)
          if (!widget.isReady)
            Positioned(
              left: -6.w,
              top: -6.h,
              bottom: -6.h,
              width: _containerWidth * 0.6,
              child: ColoredBox(color: AppColors.sliderProgressFill),
            ),

          // Label Text ("Getting your route ready" or "Slide to start route")
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: (1.0 - (dragFraction * 2)).clamp(0.0, 1.0),
              child: Text(
                widget.isReady ? context.tr.routeSlideToStart : context.tr.routeGettingRouteReady,
                style: AppTextStyles.s14Bold.copyWith(
                  color: widget.isReady ? AppColors.brandBlack : AppColors.textBody,
                ),
              ),
            ),
          ),

          // Draggable Knob / Button (52x52, radius 26 / circle)
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: widget.isReady
                  ? (details) {
                      setState(() {
                        _dragPosition += details.delta.dx;
                        if (_dragPosition < 0) _dragPosition = 0;
                        if (_dragPosition > _maxDrag) _dragPosition = _maxDrag;
                      });
                    }
                  : null,
              onHorizontalDragEnd: widget.isReady
                  ? (details) {
                      if (_dragPosition >= _maxDrag * 0.75) {
                        setState(() {
                          _dragPosition = _maxDrag;
                        });
                        widget.onStartRoute();
                      } else {
                        setState(() {
                          _dragPosition = 0.0;
                        });
                      }
                    }
                  : null,
              child: Container(
                width: 52.w,
                height: 52.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isReady ? AppColors.brandMain : AppColors.surfaceWhite,
                  border: widget.isReady
                      ? null
                      : Border.all(color: AppColors.borderDeactivated, width: 1.w),
                ),
                child: Center(
                  child: _NavigateIcon(isReady: widget.isReady),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trip Sheet Card Component ────────────────────────────────────────────────

class TripSheet extends StatelessWidget {
  const TripSheet({
    super.key,
    required this.isReady,
    required this.stops,
    this.distanceMeters,
    this.durationMinutes,
    required this.onStartRoute,
  });

  final bool isReady;
  final List<RouteStop> stops;
  final int? distanceMeters;
  final int? durationMinutes;
  final VoidCallback onStartRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      decoration: BoxDecoration(
        color: AppColors.brandBackground,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
        boxShadow: AppTextStyles.tripSheetShadow,
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Title
          if (!isReady) ...[
            Text(
              context.tr.routePlanningYourRoute,
              style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
            ),
            SizedBox(height: 4.h),
            Text(
              context.tr.routeFindingFastestOrder(stops.length.toString()),
              style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text(
              context.tr.routeYourRouteIsReady,
              style: AppTextStyles.s26Bold112.copyWith(color: AppColors.brandBlack),
            ),
            SizedBox(height: 4.h),
            Text(
              context.tr.routeStopsOrderedHint,
              style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 16.h),

          // Stop Rows (Gap 12)
          Column(
            children: List.generate(stops.length, (index) {
              final stop = stops[index];
              final isLast = index == stops.length - 1;
              StopRowVariant variant = StopRowVariant.inactive;

              if (index == 0) {
                variant = StopRowVariant.active;
              } else if (index == 2 && !isReady) {
                variant = StopRowVariant.loadingSpinner;
              }

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                child: StopRow(
                  index: index + 1,
                  title: stop.title,
                  address: stop.address,
                  eta: stop.eta,
                  variant: variant,
                  showTimeSkeleton: !isReady,
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),

          // Slide to Start Component
          SlideToStart(
            isReady: isReady,
            onStartRoute: onStartRoute,
          ),
        ],
      ),
    );
  }
}
