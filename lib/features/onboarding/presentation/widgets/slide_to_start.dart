import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/motion.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

// TODO(onboarding): deliberate — no checkmark on completion (arrow stays
// throughout), knob is inset 6px from the track on all four sides, and
// onCompleted only fires after a 300ms hold once the knob snaps to the
// end. Don't revert any of these without checking first.
class SlideToStart extends StatefulWidget {
  const SlideToStart({
    super.key,
    required this.label,
    required this.onCompleted,
    this.semanticsLabel = 'Get started',
    this.semanticsHint = 'Double tap or slide right to continue',
    this.height = 68,
    this.knobDiameter = 56,
    this.knobPadding = 6,
    this.trackColor = AppColors.brandMain,
    this.knobColor = AppColors.brandWhite,
    this.labelColor = AppColors.onBrand,
    this.fillColor = AppColors.onBrand,
    this.iconColor = AppColors.onBrand,
  });

  final String label;
  final VoidCallback onCompleted;
  final String semanticsLabel;
  final String semanticsHint;
  final double height;
  final double knobDiameter;

  /// Gap kept between the knob and the track's edges — top/bottom, left at
  /// rest, and right when fully slid.
  final double knobPadding;
  final Color trackColor;
  final Color knobColor;
  final Color labelColor;

  /// The progress-reveal fill drawn behind the knob (used at 12% opacity).
  final Color fillColor;
  final Color iconColor;

  @override
  State<SlideToStart> createState() => _SlideToStartState();
}

class _SlideToStartState extends State<SlideToStart>
    with TickerProviderStateMixin {
  late final AnimationController _dragController;
  late final AnimationController _shimmerController;

  bool _isDragging = false;
  bool _isLocked = false;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(vsync: this, value: 0);
    _shimmerController = AnimationController(
      vsync: this,
      duration: Motion.slideChevronShimmer,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_reduceMotion) _shimmerController.repeat();
    });
  }

  @override
  void dispose() {
    _dragController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    if (_isLocked) return;
    _isDragging = true;
    _dragController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag, bool isRtl) {
    if (!_isDragging || maxDrag <= 0) return;
    final delta = (isRtl ? -details.delta.dx : details.delta.dx) / maxDrag;
    _dragController.value = (_dragController.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details, double maxDrag, bool isRtl) {
    if (!_isDragging) return;
    _isDragging = false;

    if (_dragController.value >= Motion.slideCompletionThreshold) {
      _complete();
      return;
    }

    final rawVelocity = details.primaryVelocity ?? 0;
    final velocity = maxDrag > 0
        ? (isRtl ? -rawVelocity : rawVelocity) / maxDrag
        : 0.0;
    _dragController.animateWith(
      SpringSimulation(
        Motion.slideSpringBack,
        _dragController.value,
        0,
        velocity,
      ),
    );
  }

  Future<void> _complete() async {
    if (_isLocked) return;
    setState(() => _isLocked = true);

    final reduceMotion = _reduceMotion;
    if (reduceMotion) {
      _dragController.value = 1;
      HapticFeedback.mediumImpact();
      widget.onCompleted();
      return;
    }

    // Snap the knob the rest of the way, hold briefly at the end so the
    // completion doesn't feel abrupt, then transition — no checkmark, the
    // arrow stays as-is throughout.
    await _dragController.animateTo(
      1,
      duration: Motion.slideSnapToEnd,
      curve: Curves.easeOut,
    );
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    await Future.delayed(Motion.slideCompletionDelay);
    if (!mounted) return;
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final height = widget.height.h;
    final knobDiameter = widget.knobDiameter.w;
    final knobPadding = widget.knobPadding.w;

    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      hint: widget.semanticsHint,
      onTap: _isLocked ? null : _complete,
      child: ExcludeSemantics(
        child: GestureDetector(
          // Reduced motion: any tap on the control completes it, no drag
          // required.
          onTap: _reduceMotion && !_isLocked ? _complete : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxDrag =
                  (constraints.maxWidth - knobDiameter - knobPadding * 2).clamp(
                    0.0,
                    double.infinity,
                  );

              return AnimatedBuilder(
                animation: Listenable.merge([
                  _dragController,
                  _shimmerController,
                ]),
                builder: (context, _) {
                  final fraction = _dragController.value;
                  final labelOpacity = (1 - fraction / 0.6).clamp(0.0, 1.0);
                  final chevronFade = (1 - fraction / 0.3).clamp(0.0, 1.0);

                  return SizedBox(
                    height: height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(height / 2),
                      child: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          Container(color: widget.trackColor),
                          FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: fraction,
                            child: Container(
                              color: widget.fillColor.withValues(alpha: 0.12),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Opacity(
                                opacity: labelOpacity,
                                child: Text(widget.label, style: _labelStyle),
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            end: 16.w,
                            child: Opacity(
                              opacity: chevronFade,
                              child: _Chevrons(
                                shimmer: _shimmerController.value,
                                color: widget.iconColor,
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            start: knobPadding + fraction * maxDrag,
                            child: GestureDetector(
                              key: const ValueKey('slideToStartKnob'),
                              onHorizontalDragStart: _onDragStart,
                              onHorizontalDragUpdate: (d) =>
                                  _onDragUpdate(d, maxDrag, isRtl),
                              onHorizontalDragEnd: (d) =>
                                  _onDragEnd(d, maxDrag, isRtl),
                              child: Container(
                                width: knobDiameter,
                                height: knobDiameter,
                                decoration: BoxDecoration(
                                  color: widget.knobColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.borderDeactivated,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: isRtl
                                      ? Transform.flip(
                                          flipX: true,
                                          child: SvgPicture.asset(
                                            AppAssets.icArrow,
                                            width: 20.w,
                                            height: 20.w,
                                            colorFilter: ColorFilter.mode(
                                              widget.iconColor,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          AppAssets.icArrow,
                                          width: 20.w,
                                          height: 20.w,
                                          colorFilter: ColorFilter.mode(
                                            widget.iconColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static TextStyle get _labelStyle => TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.brandBlack,
  );
}

/// Three chevrons ("›››") that shimmer left-to-right in a loop, hinting at
/// the slide direction.
class _Chevrons extends StatelessWidget {
  const _Chevrons({required this.shimmer, required this.color});

  final double shimmer;
  final Color color;

  static const int _count = 3;
  static const double _staggerSpan = 0.5;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _count; i++)
          Opacity(
            opacity: _opacityFor(i),
            child: Icon(Icons.chevron_right, color: color, size: 18.w),
          ),
      ],
    );
  }

  double _opacityFor(int index) {
    final phase = index * 0.15;
    final t = ((shimmer - phase) % 1.0 + 1.0) % 1.0;
    // 0.35 -> 1 -> 0.35 over a `_staggerSpan`-wide window, held at 0.35
    // outside it, so the three chevrons light up left-to-right in sequence.
    if (t > _staggerSpan) return 0.35;
    final u = t / _staggerSpan;
    final wave = u < 0.5 ? u * 2 : (1 - u) * 2;
    return 0.35 + wave * 0.65;
  }
}
