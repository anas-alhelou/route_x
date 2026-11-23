import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/motion.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:routex_mobile/features/onboarding/presentation/widgets/onboarding_page_content.dart';
import 'package:routex_mobile/features/onboarding/presentation/widgets/progress_next_button.dart';
import 'package:routex_mobile/features/onboarding/presentation/widgets/slide_to_start.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// The onboarding flow's screen: a set of pages with a page indicator and a
/// primary action — a tap-to-advance button on every page but the last,
/// and a slide-to-confirm control on the last one.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // ---------------------------------------------------------------------------
  // Layout spec (Figma, main frame 412 x 917). Vertical values are scaled with
  // `.h`, horizontal ones with `.w`, via the ScreenUtil design size in main.dart.
  // ---------------------------------------------------------------------------

  /// Left/right margin of the footer (page indicator + action).
  static const double _footerSideMargin = 26;

  /// Distance from the next button's bottom edge to the screen bottom. The
  /// page indicator, being shorter, ends up further from the bottom once
  /// it's vertically centered against the button on the same row — that
  /// follows automatically from the row layout below, no separate constant
  /// needed.
  static const double _footerBottomMargin = 35;

  /// On the last page, the indicator sits above the full-width slide
  /// button instead of beside a circular one — its own bottom margin and
  /// the gap down to the button.
  static const double _slideButtonBottomMargin = 45;
  static const double _indicatorToSlideButtonGap = 42;

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onDone() async {
    await context.read<OnboardingCubit>().completeOnboarding();
    if (mounted) {
      context.go(RoutersName.appPermissionsScreen);
    }
  }

  void _goToNextPage() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    _pageController.nextPage(
      duration: reduceMotion ? Duration.zero : Motion.pageTransition,
      curve: Curves.easeInOut,
    );
  }

  /// This page's offset from being fully centered (roughly -1..1), used to
  /// drive the hero image's parallax drift. 0 before the controller has
  /// attached to its [PageView].
  double _parallaxFor(int index) {
    if (!_pageController.hasClients ||
        !_pageController.position.hasContentDimensions) {
      return 0;
    }
    final page = _pageController.page ?? _currentIndex.toDouble();
    return (page - index).clamp(-1.0, 1.0) * Motion.parallaxFactor;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final page1 = OnboardingSlideData(
      imageAssetPath: AppAssets.imgOnboarding1,
      titleSegments: [
        OnboardingTextSegment(tr.onboardingHeadline1),
        OnboardingTextSegment(tr.onboardingHeadline2, isHighlighted: true),
        OnboardingTextSegment(tr.onboardingHeadline3),
        OnboardingTextSegment(tr.onboardingHeadline4, isHighlighted: true),
      ],
      subtitle: tr.onboardingSubheadline,
    );
    final page2 = OnboardingSlideData(
      imageAssetPath: AppAssets.imgOnboarding2,
      titleSegments: [
        OnboardingTextSegment(tr.onboarding2Headline1),
        ..._withTightLastLetter(tr.onboarding2Headline2),
        OnboardingTextSegment(tr.onboarding2Headline3),
        ..._withTightLastLetter(tr.onboarding2Headline4),
      ],
      subtitle: tr.onboarding2Subheadline,
    );

    final pages = <OnboardingSlideData>[page1, page2];
    final isLastPage = _currentIndex == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: Column(
        children: [
          // Full width, full height available above the footer: the hero
          // image inside bleeds under the status bar, as in the design.
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: pages.length,
              itemBuilder: (context, index) => AnimatedBuilder(
                animation: _pageController,
                builder: (context, _) => OnboardingPageContent(
                  page: pages[index],
                  parallax: _parallaxFor(index),
                  isActive: index == _currentIndex,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: _footerSideMargin.w,
              end: _footerSideMargin.w,
              bottom:
                  (isLastPage ? _slideButtonBottomMargin : _footerBottomMargin)
                      .h,
            ),
            child: isLastPage
                // The final page trades the quick tap-to-advance button for a
                // deliberate slide-to-confirm one, so completing onboarding
                // can't happen by accident.
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIndicator(pages.length),
                      SizedBox(height: _indicatorToSlideButtonGap.h),
                      SlideToStart(
                        label: tr.slideToGetStarted,
                        trackColor: AppColors.brandSecondary,
                        onCompleted: _onDone,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIndicator(pages.length),
                      ProgressNextButton(
                        label: tr.next,
                        onPressed: _goToNextPage,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Figma sets -4 tracking on the last letter of "stop," / "order." so the
  /// punctuation hugs it. Applies only to Latin "word + punctuation" strings;
  /// anything else (e.g. Arabic) is returned as one highlighted segment.
  List<OnboardingTextSegment> _withTightLastLetter(String text) {
    if (!RegExp(r'^[A-Za-z]{2,}[,.]$').hasMatch(text)) {
      return [OnboardingTextSegment(text, isHighlighted: true)];
    }
    final last = text.length - 2;
    return [
      OnboardingTextSegment(text.substring(0, last), isHighlighted: true),
      OnboardingTextSegment(
        text.substring(last, last + 1),
        isHighlighted: true,
        letterSpacing: -4,
      ),
      OnboardingTextSegment(text.substring(last + 1), isHighlighted: true),
    ];
  }

  Widget _buildIndicator(int count) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SmoothPageIndicator(
        controller: _pageController,
        count: count,
        onDotClicked: (index) => _pageController.animateToPage(
          index,
          duration: Motion.pageTransition,
          curve: Motion.pageIndicatorCurve,
        ),
        effect: ExpandingDotsEffect(
          dotWidth: 8.w,
          dotHeight: 8.h,
          spacing: 6.w,
          radius: 4.r,
          expansionFactor: 3.5,
          activeDotColor: AppColors.brandMain,
          dotColor: AppColors.surfaceEmpty,
        ),
      ),
    );
  }
}
