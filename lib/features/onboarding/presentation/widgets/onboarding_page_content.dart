import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/motion.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// A single styled run of text within an onboarding headline.
///
/// The headline is modeled as a list of segments instead of a plain
/// `String` so that any onboarding page can highlight different words purely
/// through data — no widget code has to change to support a new highlight
/// pattern.
class OnboardingTextSegment {
  const OnboardingTextSegment(
    this.text, {
    this.isHighlighted = false,
    this.letterSpacing,
  });

  final String text;
  final bool isHighlighted;

  /// Optional per-segment tracking override (Figma tightens the last letter
  /// of "stop" / "order" by -4 so the punctuation sits close to it).
  final double? letterSpacing;
}

/// Content of a single onboarding page.
///
/// Built in the page from the localized strings (`context.tr`) rather than
/// hard-coded here, so the copy follows the active language.
class OnboardingSlideData {
  const OnboardingSlideData({
    required this.imageAssetPath,
    required this.titleSegments,
    required this.subtitle,
  });

  final String imageAssetPath;
  final List<OnboardingTextSegment> titleSegments;
  final String subtitle;
}

/// Renders one onboarding page's full visual content: a full-bleed hero
/// image (bleeding under the status bar) followed by the highlighted
/// headline and subtitle. The blank space below is left to the page's
/// background — the footer (page indicator + action) is owned by
/// [OnboardingPage], not this widget.
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.page,
    this.parallax = 0,
    this.isActive = true,
  });

  final OnboardingSlideData page;

  /// This page's scroll offset from being fully centered, roughly -1..1.
  /// Drives the hero image's parallax drift; 0 when not inside a
  /// [PageView] (e.g. in isolated widget tests).
  final double parallax;

  /// Whether this is the currently-settled page. Drives the headline and
  /// subtitle's reveal transition; defaults to `true` so the widget renders
  /// fully visible when used standalone.
  final bool isActive;

  /// The hero image asset's native aspect ratio (1236x1590), so it scales
  /// proportionally instead of distorting. Unlike the earlier map asset,
  /// these photos have a hard bottom edge with no built-in fade, so
  /// [_bottomFadeFraction] below fades it into the page background in code.
  static const double _imageAspectRatio = 1236 / 1590;

  /// Fraction of the image's height, measured from the bottom, over which
  /// it fades to fully transparent — so the hero image blends into the page
  /// background instead of cutting off with a hard edge.
  static const double _bottomFadeFraction = 0.45;

  /// Extra image height (each side) reserved for the parallax drift, so
  /// panning never exposes blank edges.
  static const double _parallaxBleed = 20;

  // --- Figma dev-mode spacing (design frame 412 x 917) ---
  /// Left/right inset shared by the headline and the subtitle.
  static const double _sideInset = 26;

  /// Gap between the hero image's bottom edge and the headline.
  static const double _imageToHeadlineGap = 16;

  /// Gap between the headline and the subtitle.
  static const double _headlineToSubtitleGap = 8;

  @override
  Widget build(BuildContext context) {
    final naturalImageHeight =
        MediaQuery.sizeOf(context).width / _imageAspectRatio;
    final bleed = _parallaxBleed.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full-bleed hero image: no horizontal padding and no top safe-area
        // inset, so it runs behind the status bar as in the design. Sized
        // taller than its box and clipped, so the parallax translate below
        // never reveals blank edges. A solid gradient is painted over its
        // bottom edge (rather than alpha-masking the image itself) so it
        // blends into the page background without a compositing seam.
        // The image takes its natural height when there is room, and gives
        // up only as much as the headline and subtitle need when the screen
        // is short (small phones, large text), instead of overflowing.
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight =
                  math.min(naturalImageHeight, constraints.maxHeight);
              return SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: OverflowBox(
                        minHeight: imageHeight + bleed * 2,
                        maxHeight: imageHeight + bleed * 2,
                        child: Transform.translate(
                          offset: Offset(0, parallax * bleed),
                          child: Image.asset(
                            page.imageAssetPath,
                            width: double.infinity,
                            height: imageHeight + bleed * 2,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      bottom: 0,
                      height: imageHeight * _bottomFadeFraction,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.brandBackground.withValues(alpha: 0),
                                AppColors.brandBackground,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // The headline and subtitle reveal together as this page settles
        // into view, instead of dragging pixel-for-pixel with the swipe.
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: _sideInset.w,
                end: _sideInset.w,
                top: _imageToHeadlineGap.h,
              ),
              child: _buildHeadline(),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: _sideInset.w,
                end: _sideInset.w,
                top: _headlineToSubtitleGap.h,
              ),
              child: Text(page.subtitle, style: _subtitleStyle),
            ),
          ],
        )
            .animate(target: isActive ? 1 : 0)
            .fadeIn(duration: Motion.pageTransition, curve: Curves.easeOutCubic)
            .slideX(
              begin: 0.06,
              end: 0,
              duration: Motion.pageTransition,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }

  /// Maps each [OnboardingTextSegment] to a [TextSpan], applying the highlight
  /// color only where the segment data says to.
  Widget _buildHeadline() {
    return RichText(
      text: TextSpan(
        children: [
          for (final segment in page.titleSegments)
            TextSpan(
              text: segment.text,
              style: _headlineStyle.copyWith(
                color: segment.isHighlighted
                    ? AppColors.brandMain
                    : AppColors.brandBlack,
                letterSpacing: segment.letterSpacing,
              ),
            ),
        ],
      ),
    );
  }

  /// Headline: Satoshi Black 42, letter-spacing -1.4, line-height 50 (Figma).
  static TextStyle get _headlineStyle => TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 42.sp,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.4,
    height: 50 / 42,
    color: AppColors.brandBlack,
  );

  /// Subtitle: Satoshi Regular 16, line-height 24, colour #737373 (Figma).
  static TextStyle get _subtitleStyle => TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16.sp,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.textMuted,
  );
}
