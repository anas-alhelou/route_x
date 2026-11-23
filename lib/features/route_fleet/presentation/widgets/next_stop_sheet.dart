import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

class NextStopSheet extends StatefulWidget {
  const NextStopSheet({
    super.key,
    required this.nextStopNumber,
    required this.nextStopName,
    required this.nextStopAddressAndMeta,
    this.initialCountdownSeconds = 3,
    this.isFilling = false, // Emptying as per Figma spec (bar shrinks from 230/310)
    this.freezeForTesting = false, // TEMP flag to freeze countdown at 74% (230/310) with "3 s" for visual verification
    this.onGoToNextStopTapped,
    this.onCountdownFinished,
  });

  final int nextStopNumber; // e.g. 2
  final String nextStopName; // e.g. "Lina Fares"
  final String nextStopAddressAndMeta; // e.g. "Tahlia St, Al Nahda · 6 min · 1.4 km"
  final int initialCountdownSeconds;
  final bool isFilling;
  final bool freezeForTesting;
  final VoidCallback? onGoToNextStopTapped;
  final VoidCallback? onCountdownFinished;

  @override
  State<NextStopSheet> createState() => _NextStopSheetState();
}

class _NextStopSheetState extends State<NextStopSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.initialCountdownSeconds),
    );

    if (!widget.freezeForTesting) {
      _controller
        ..forward()
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.onCountdownFinished?.call();
          }
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Overline "NEXT STOP"
            Text(
              context.tr.routeNextStopCaps,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: 0.6,
                color: AppColors.textBody,
              ),
            ),
            SizedBox(height: 14.h),

            // 2. Next stop row (Badge 40x40 + Name + Meta)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandMain,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.nextStopNumber}',
                      style: AppTextStyles.s14Bold14.copyWith(color: AppColors.onBrand),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.nextStopName,
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          letterSpacing: -0.1,
                          color: AppColors.brandBlack,
                        ),
                      ),
                      Text(
                        widget.nextStopAddressAndMeta,
                        style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // 3. Auto-advance countdown bar & label using ceil of remaining seconds
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double progress = widget.freezeForTesting
                    ? (230.0 / 310.0)
                    : (widget.isFilling ? _controller.value : (1.0 - _controller.value));

                final int remainingSecs = widget.freezeForTesting
                    ? widget.initialCountdownSeconds
                    : (_controller.isAnimating || _controller.isCompleted
                        ? ((widget.initialCountdownSeconds * (1.0 - _controller.value)).ceil()).clamp(0, widget.initialCountdownSeconds)
                        : widget.initialCountdownSeconds);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 6.h,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3.r),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.borderDeactivated,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandMain),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      context.tr.routeStartingDirectionsIn(remainingSecs.toString()),
                      style: AppTextStyles.s12Medium145.copyWith(color: AppColors.textBody),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 14.h),

            // 4. Go to next stop button (Target: R14)
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandMain,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                onPressed: widget.onGoToNextStopTapped,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.routeIcNavigate,
                      width: 22.w,
                      height: 22.h,
                      colorFilter: ColorFilter.mode(AppColors.onBrand, BlendMode.srcIn),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr.routeGoToNextStop,
                      style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
