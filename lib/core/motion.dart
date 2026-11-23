import 'package:flutter/animation.dart';

/// Central registry of durations, curves and physics used by the
/// onboarding flow's micro-interactions — so tuning a motion means editing
/// one constant here, not hunting through widgets.
abstract final class Motion {
  Motion._();

  // ── Next button (progress ring) ──────────────────────────────────────
  static const Duration nextButtonPress = Duration(milliseconds: 100);
  static const Curve nextButtonPressCurve = Curves.easeOut;

  static const Duration nextButtonRing = Duration(milliseconds: 450);
  static const Curve nextButtonRingCurve = Curves.easeOutCubic;

  static const Duration nextButtonIdleNudgeInterval = Duration(seconds: 3);
  static const Duration nextButtonIdleNudge = Duration(milliseconds: 400);

  // ── Page indicator ───────────────────────────────────────────────────
  static const Duration pageIndicator = Duration(milliseconds: 300);
  static const Curve pageIndicatorCurve = Curves.easeOutCubic;

  // ── Page / content transition ────────────────────────────────────────
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// The hero image trails the page scroll at 30% of the drag offset.
  static const double parallaxFactor = 0.3;

  // ── Smart animate (Figma-style screen change) ────────────────────────
  static const Duration smartAnimate = Duration(milliseconds: 400);
  static const Curve smartAnimateCurve = Curves.easeOutCubic;

  /// How far (fraction of the screen height) the incoming screen rises.
  static const double smartAnimateRise = 0.04;

  // ── Slide-to-start ────────────────────────────────────────────────────
  static const double slideCompletionThreshold = 0.8;
  static const Duration slideChevronShimmer = Duration(milliseconds: 1200);
  static const Duration slideSnapToEnd = Duration(milliseconds: 150);
  static const Duration slideCompletionDelay = Duration(milliseconds: 300);

  /// Spring used when the knob is released below the completion threshold.
  static const SpringDescription slideSpringBack = SpringDescription(
    mass: 1,
    stiffness: 400,
    damping: 30,
  );

  // ── Shake animation (invalid code) ────────────────────────────────────
  static const Duration shakeDuration = Duration(milliseconds: 400);

  // ── Check pop (password match tick, requirement rows) ───────────────
  static const Duration checkPop = Duration(milliseconds: 260);
  static const Curve checkPopIn = Curves.easeOutBack;

  // ── Screen entry animation ───────────────────────────────────────────
  static const Duration screenEntryDuration = Duration(milliseconds: 500);
  static const Curve screenEntryFadeCurve = Curves.easeOut;
  static const Curve screenEntrySlideCurve = Curves.easeOutCubic;
  static const Offset screenEntrySlideOffset = Offset(0.0, 0.12);

  // ── Online switch ────────────────────────────────────────────────────

  /// How long the Go Online switch takes to slide its knob and recolour.
  ///
  /// One value for the track and the knob: they move together, and two separate
  /// literals would let them drift apart into a switch whose knob lags its own
  /// track by a frame.
  static const Duration switchToggle = Duration(milliseconds: 180);
  static const Curve switchToggleCurve = Curves.easeOut;

  // ── Sheets and dialogs ───────────────────────────────────────────────
  // A sheet slides up from the edge it belongs to and leaves the same way, a
  // little quicker than it came. Flutter's own sheet curve is kept so the drag
  // to dismiss still feels native; only the durations are tuned.
  static const Duration sheetEnter = Duration(milliseconds: 300);
  static const Duration sheetExit = Duration(milliseconds: 220);

  /// A dialog is centred on screen, so it grows from its middle: fade plus a
  /// small scale-up. It leaves faster than it arrived.
  static const Duration dialogEnter = Duration(milliseconds: 200);
  static const Duration dialogExit = Duration(milliseconds: 150);
  static const Curve dialogCurve = Cubic(0.23, 1, 0.32, 1);
  static const Curve dialogExitCurve = Curves.easeIn;
  static const double dialogStartScale = 0.96;

  /// When the device asks for reduced motion: a quick fade, nothing travels.
  static const Duration reduced = Duration(milliseconds: 120);

  // ── Rare moments (success, empty states) ─────────────────────────────
  // Seen once in a while, so they get a slightly longer, softer arrival than
  // the working UI: a fade while growing from 90%. Never from zero.
  static const Duration popIn = Duration(milliseconds: 400);
  static const Curve popInCurve = Cubic(0.23, 1, 0.32, 1);
  static const double popInStartScale = 0.9;

  // ── Button press scale ───────────────────────────────────────────────
  static const double buttonPressScale = 0.94;
}

