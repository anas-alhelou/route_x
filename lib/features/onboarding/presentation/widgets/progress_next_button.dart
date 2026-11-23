import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/motion.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';

// TODO(onboarding): deliberate — ring is green (not black) and empty/gray
// at rest, filling only as tap feedback (not a resting "page X of N"
// indicator). Don't revert either without checking first.
class ProgressNextButton extends StatefulWidget {
  const ProgressNextButton({
    super.key,
    required this.onPressed,
    this.progress = 0,
    this.targetProgress = 1,
    this.label = 'Next',
    this.diameter = 64,
    this.ringDiameter = 76,
    this.ringStrokeWidth = 3,
    this.trackColor,
    this.progressColor = AppColors.brandMain,
    this.fillColor = AppColors.brandMain,
    this.iconColor = AppColors.onBrand,
  });

  final double progress;
  final double targetProgress;
  final VoidCallback onPressed;
  final String label;
  final double diameter;
  final double ringDiameter;
  final double ringStrokeWidth;
  /// Ring track; null follows the theme ([AppColors.surfaceEmpty]).
  final Color? trackColor;
  final Color progressColor;
  final Color fillColor;
  final Color iconColor;

  @override
  State<ProgressNextButton> createState() => _ProgressNextButtonState();
}

class _ProgressNextButtonState extends State<ProgressNextButton>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _ringController;
  late final AnimationController _nudgeController;
  late Animation<double> _ringAnimation;

  Timer? _idleTimer;
  bool _hasInteracted = false;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Motion.nextButtonPress,
      value: 1,
      lowerBound: 0.9,
      upperBound: 1,
    );
    _ringController = AnimationController(
      vsync: this,
      duration: Motion.nextButtonRing,
    );
    _ringAnimation = AlwaysStoppedAnimation(widget.progress);

    _nudgeController = AnimationController(
      vsync: this,
      duration: Motion.nextButtonIdleNudge,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleIdleHint());
  }

  @override
  void didUpdateWidget(covariant ProgressNextButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_ringController.isAnimating && oldWidget.progress != widget.progress) {
      _ringAnimation = AlwaysStoppedAnimation(widget.progress);
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _scaleController.dispose();
    _ringController.dispose();
    _nudgeController.dispose();
    super.dispose();
  }

  void _scheduleIdleHint() {
    if (_hasInteracted || _reduceMotion) return;
    _idleTimer = Timer.periodic(Motion.nextButtonIdleNudgeInterval, (_) {
      if (!mounted || _hasInteracted) return;
      _nudgeController.forward(from: 0).then((_) {
        if (mounted) _nudgeController.reverse();
      });
    });
  }

  void _handleTapDown(TapDownDetails details) {
    if (_reduceMotion) return;
    _scaleController.animateTo(0.94, curve: Motion.nextButtonPressCurve);
  }

  void _handleTapCancel() => _releaseScale();

  void _releaseScale() {
    if (_reduceMotion) return;
    const spring = SpringDescription(mass: 1, stiffness: 300, damping: 20);
    _scaleController.animateWith(
      SpringSimulation(spring, _scaleController.value, 1, 0),
    );
  }

  void _handleTap() {
    _hasInteracted = true;
    _idleTimer?.cancel();
    _releaseScale();

    if (_reduceMotion) {
      widget.onPressed();
      return;
    }

    _ringAnimation =
        Tween<double>(
          begin: widget.progress,
          end: widget.targetProgress,
        ).animate(
          CurvedAnimation(
            parent: _ringController,
            curve: Motion.nextButtonRingCurve,
          ),
        );
    _ringController.forward(from: 0);

    // Fires in the same handler as the ring animation above, so the page
    // transition and the ring's fill run concurrently rather than
    // sequentially.
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapCancel: _handleTapCancel,
        onTapUp: (_) {},
        onTap: _handleTap,
        child: SizedBox(
          width: widget.ringDiameter.w,
          height: widget.ringDiameter.w,
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (context, child) =>
                Transform.scale(scale: _scaleController.value, child: child),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, _) => CustomPaint(
                    size: Size(widget.ringDiameter.w, widget.ringDiameter.w),
                    painter: _RingPainter(
                      progress: _ringAnimation.value,
                      strokeWidth: widget.ringStrokeWidth.w,
                      trackColor: widget.trackColor ?? AppColors.surfaceEmpty,
                      progressColor: widget.progressColor,
                    ),
                  ),
                ),
                Container(
                  width: widget.diameter.w,
                  height: widget.diameter.w,
                  decoration: BoxDecoration(
                    color: widget.fillColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _nudgeController,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                          (isRtl ? -1 : 1) * 3.w * _nudgeController.value,
                          0,
                        ),
                        child: child,
                      ),
                      child: isRtl
                          ? Transform.flip(
                              flipX: true,
                              child: SvgPicture.asset(
                                AppAssets.icArrow,
                                width: 24.w,
                                height: 24.w,
                                colorFilter: ColorFilter.mode(
                                  widget.iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              AppAssets.icArrow,
                              width: 24.w,
                              height: 24.w,
                              colorFilter: ColorFilter.mode(
                                widget.iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the button's ring: a full track plus a progress arc swept
/// clockwise from the top (12 o'clock).
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
