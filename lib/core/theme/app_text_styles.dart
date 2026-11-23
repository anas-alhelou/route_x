import 'package:flutter/painting.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

/// Design token text styles exported from Figma.
///
/// Font family: **Satoshi** (Mapped to Inter), with
/// [AppFonts.fontFamilyFallback] attached to every style so the Arabic glyphs
/// Satoshi has no outlines for fall through to IBM Plex Sans Arabic while the
/// Latin ones keep their Satoshi shapes.
/// Font sizes use raw double values from [AppFonts].
///
/// Note: To apply responsiveness (ScreenUtil .sp), apply it inside the UI widget,
/// or use a custom copyWith extension. Do not apply .sp here to maintain `const` capability.
///
/// Naming pattern: `s{fontSize}{Weight}` - e.g. `s14Regular`, `s20SemiBold`.
/// Each style includes the matched `height` factor derived from the
/// (lineHeight / fontSize) ratio in the Figma tokens.
class AppTextStyles {
  AppTextStyles._();

  // ---------------------------------------------------------------------------
  // Font Size 10  |  Line-height 14
  // ---------------------------------------------------------------------------
  static const TextStyle s10Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size10,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight10 / AppFonts.size10,
  );

  static const TextStyle s10Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size10,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight10 / AppFonts.size10,
  );

  static const TextStyle s10SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size10,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight10 / AppFonts.size10,
  );

  static const TextStyle s10Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size10,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight10 / AppFonts.size10,
  );

  // ---------------------------------------------------------------------------
  // Font Size 11  |  Line-height 15
  // ---------------------------------------------------------------------------
  static const TextStyle s11Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size11,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight11 / AppFonts.size11,
  );

  static const TextStyle s11Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size11,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight11 / AppFonts.size11,
  );

  static const TextStyle s11SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size11,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight11 / AppFonts.size11,
  );

  static const TextStyle s11Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size11,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight11 / AppFonts.size11,
  );

  // ---------------------------------------------------------------------------
  // Font Size 12  |  Line-height 16
  // ---------------------------------------------------------------------------
  static const TextStyle s12Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight12 / AppFonts.size12,
  );

  static const TextStyle s12Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight12 / AppFonts.size12,
  );

  static const TextStyle s12SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight12 / AppFonts.size12,
  );

  static const TextStyle s12Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight12 / AppFonts.size12,
  );

  // ---------------------------------------------------------------------------
  // Font Size 14  |  Line-height 20
  // ---------------------------------------------------------------------------
  static const TextStyle s14Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight14 / AppFonts.size14,
  );

  static const TextStyle s14Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight14 / AppFonts.size14,
  );

  static const TextStyle s14SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight14 / AppFonts.size14,
  );

  static const TextStyle s14Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight14 / AppFonts.size14,
  );

  // ---------------------------------------------------------------------------
  // Font Size 16  |  Line-height 22
  // ---------------------------------------------------------------------------
  static const TextStyle s16Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight16 / AppFonts.size16,
  );

  static const TextStyle s16Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight16 / AppFonts.size16,
  );

  static const TextStyle s16SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight16 / AppFonts.size16,
  );

  static const TextStyle s16Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight16 / AppFonts.size16,
  );

  // ---------------------------------------------------------------------------
  // Font Size 20  |  Line-height 28
  // ---------------------------------------------------------------------------
  static const TextStyle s20Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size20,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight20 / AppFonts.size20,
  );

  static const TextStyle s20Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size20,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight20 / AppFonts.size20,
  );

  static const TextStyle s20SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size20,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight20 / AppFonts.size20,
  );

  static const TextStyle s20Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size20,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight20 / AppFonts.size20,
  );

  // ---------------------------------------------------------------------------
  // Font Size 24  |  Line-height 34
  // ---------------------------------------------------------------------------
  static const TextStyle s24Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight24 / AppFonts.size24,
  );

  static const TextStyle s24Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight24 / AppFonts.size24,
  );

  static const TextStyle s24SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight24 / AppFonts.size24,
  );

  static const TextStyle s24Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight24 / AppFonts.size24,
  );

  // ---------------------------------------------------------------------------
  // Font Size 28  |  Line-height 40
  // ---------------------------------------------------------------------------
  static const TextStyle s28Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size28,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight28 / AppFonts.size28,
  );

  static const TextStyle s28Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size28,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight28 / AppFonts.size28,
  );

  static const TextStyle s28SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size28,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight28 / AppFonts.size28,
  );

  static const TextStyle s28Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size28,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight28 / AppFonts.size28,
  );

  // ---------------------------------------------------------------------------
  // Font Size 32  |  Line-height 44
  // ---------------------------------------------------------------------------
  static const TextStyle s32Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size32,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight32 / AppFonts.size32,
  );

  static const TextStyle s32Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size32,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight32 / AppFonts.size32,
  );

  static const TextStyle s32SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size32,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight32 / AppFonts.size32,
  );

  static const TextStyle s32Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size32,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight32 / AppFonts.size32,
  );

  // ---------------------------------------------------------------------------
  // Font Size 36  |  Line-height 50
  // ---------------------------------------------------------------------------
  static const TextStyle s36Regular = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size36,
    fontWeight: FontWeight.w400,
    height: AppFonts.lineHeight36 / AppFonts.size36,
  );

  static const TextStyle s36Medium = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size36,
    fontWeight: FontWeight.w500,
    height: AppFonts.lineHeight36 / AppFonts.size36,
  );

  static const TextStyle s36SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size36,
    fontWeight: FontWeight.w600,
    height: AppFonts.lineHeight36 / AppFonts.size36,
  );

  static const TextStyle s36Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size36,
    fontWeight: FontWeight.w700,
    height: AppFonts.lineHeight36 / AppFonts.size36,
  );

  // ---------------------------------------------------------------------------
  // Component Roles - exact values from the Figma Home frame
  // ---------------------------------------------------------------------------
  //
  // The `s<size><Weight>` styles above derive `height` from the single
  // line-height AppFonts pairs per size. Figma does not: the same size carries
  // different line-heights depending on the component (20px is lh28 in the
  // tokens but lh26 in the Home section titles; 24px is lh34 in the tokens but
  // lh28 for the driver name and lh30 for the empty-state title). Rewriting the
  // shared ratios to match would restyle every feature that already uses them,
  // so the roles below are named after their component and carry the values
  // drawn in the design verbatim - including the negative letter-spacing the
  // large bold sizes use for optical alignment.
  static const TextStyle greetingLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w400,
    height: 18 / AppFonts.size14,
  );

  static const TextStyle driverName = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w700,
    height: 28 / AppFonts.size24,
    letterSpacing: -0.4,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size20,
    fontWeight: FontWeight.w700,
    height: 26 / AppFonts.size20,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionHint = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w400,
    height: 18 / AppFonts.size12,
  );

  static const TextStyle statValue = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size28,
    fontWeight: FontWeight.w500,
    height: 34 / AppFonts.size28,
    letterSpacing: -0.6,
  );

  static const TextStyle statUnit = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w400,
    height: 16 / AppFonts.size12,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w400,
    height: 20 / AppFonts.size14,
  );

  static const TextStyle setupTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w700,
    height: 24 / AppFonts.size16,
    letterSpacing: -0.2,
  );

  static const TextStyle setupMeta = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w400,
    height: 21 / AppFonts.size14,
  );

  static const TextStyle stepStatus = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w500,
    height: 28 / AppFonts.size24,
    letterSpacing: -0.4,
  );

  static const TextStyle actionLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w700,
    height: 22 / AppFonts.size16,
  );

  static const TextStyle fleetRowTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size15,
    fontWeight: FontWeight.w700,
    height: 21 / AppFonts.size15,
  );

  static const TextStyle joinLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w700,
    height: 18 / AppFonts.size14,
  );

  // ---------------------------------------------------------------------------
  // Component Roles - Find a fleet / Notifications / sheets
  // ---------------------------------------------------------------------------
  //
  // Same reasoning as the Home roles above: Figma's token table pairs each size
  // with one line-height, but the paged screens carry their own. Find a fleet's
  // title is 32 on a 43 line, the Notifications bar is 22 on 28, and the empty
  // state is 24 on 30 with -0.5 tracking — none of which match the token ratio
  // for their size, and all of which would be flattened if they reused
  // `s<size><Weight>`.

  /// The 32/43 page title on Find a fleet.
  static const TextStyle pageTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size32,
    fontWeight: FontWeight.w700,
    height: 43 / AppFonts.size32,
    letterSpacing: 0.32,
  );

  /// The 12/19 supporting line under a page title, and the invite footer hint.
  ///
  /// The design draws the Find a fleet subtitle on an 18 line and the sticky
  /// footer's hint on 18.85 — a 0.85pt difference that is below the threshold at
  /// which anyone can see it, and not worth a second token that the two call
  /// sites would then have to choose between.
  static const TextStyle pageSubtitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w400,
    height: 18.85 / AppFonts.size12,
  );

  /// The 22/28 title inside a top bar.
  ///
  /// The Figma frame labels this run "Plus Jakarta Sans"; that is a leftover
  /// from a template — the app ships Satoshi and the design's own Home and Find
  /// a fleet frames are already Satoshi, so only the family name differs here.
  static const TextStyle topBarTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size22,
    fontWeight: FontWeight.w700,
    height: 28 / AppFonts.size22,
    letterSpacing: -0.3,
  );

  /// The 10/15 letterspaced eyebrow above a list ("FLEETS NEAR YOU").
  static const TextStyle sectionEyebrow = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size10,
    fontWeight: FontWeight.w700,
    height: 15 / AppFonts.size10,
    letterSpacing: 1.2,
  );

  /// The 12/18 "4 results" count on the same line as the eyebrow.
  static const TextStyle resultCount = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w400,
    height: 18 / AppFonts.size12,
  );

  /// The 16/21 label on a secondary call to action.
  static const TextStyle ctaLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w700,
    height: 21 / AppFonts.size16,
  );

  /// The 16/22.5 label inside a primary call to action.
  ///
  /// Separate from [ctaLabel] because the design gives the filled button a
  /// 22.5 line against the outlined button's 21 — half a point of leading on a
  /// 16pt bold label is enough for the two to stop sitting on the same optical
  /// centre inside their 56pt buttons.
  static const TextStyle primaryCtaLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w700,
    height: 22.5 / AppFonts.size16,
  );

  /// The 12/600 city name inside the Find a fleet location pill.
  static const TextStyle pillLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w600,
  );

  /// The 12 Bold label inside a filter chip.
  static const TextStyle chipLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w700,
    height: 18 / AppFonts.size12,
  );

  /// The 10 Bold label inside a fleet status badge.
  ///
  /// Carries the 1.2 tracking the design sets: on a three-letter word like
  /// ACTIVE the tracking is most of what makes the word legible at 10pt inside a
  /// 6pt-padded pill.
  static const TextStyle badgeLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size10,
    fontWeight: FontWeight.w700,
    height: 15 / AppFonts.size10,
    letterSpacing: 1.2,
  );

  /// The 24/30 empty-state heading, with the -0.5 tracking the design sets.
  static const TextStyle emptyStateTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w700,
    height: 30 / AppFonts.size24,
    letterSpacing: -0.5,
  );

  /// The 15/23 empty-state body copy.
  static const TextStyle emptyStateBody = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size15,
    fontWeight: FontWeight.w400,
    height: 23 / AppFonts.size15,
  );

  // ---------------------------------------------------------------------------
  // Component Roles - bottom sheets, fleet code, info cards
  // ---------------------------------------------------------------------------

  /// The 24/28 heading of a bottom sheet, with the -0.4 tracking.
  ///
  /// Was 20pt in an earlier pass; the design draws the Go Online sheet titles at
  /// 24 to match the Home empty-state heading, and the three sheets are the only
  /// place in the app where a modal carries a heading this large.
  static const TextStyle sheetTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w700,
    height: 28 / AppFonts.size24,
    letterSpacing: -0.4,
  );

  /// The 14/21 body line under a sheet heading.
  ///
  /// The old 1.4 factor gave 19.6; the design's own 21 is what centres the two
  /// lines of the pending sheet's body against its 28pt title.
  static const TextStyle sheetBody = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w400,
    height: 21 / AppFonts.size14,
  );

  /// The 15 Bold label on a sheet's text button ("Not now", "Got it").
  static const TextStyle secondaryCtaLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size15,
    fontWeight: FontWeight.w700,
  );

  /// The 14 Bold underlined escape hatch under a footer ("Find a fleet instead").
  static const TextStyle underlinedLink = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w700,
  );

  /// The 14/21 Bold heading inside a [RouteXInfoCard].
  static const TextStyle infoCardTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w700,
    height: 21 / AppFonts.size14,
  );

  /// The 12/18.85 body inside a [RouteXInfoCard].
  static const TextStyle infoCardBody = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w400,
    height: 18.85 / AppFonts.size12,
  );

  /// The 24/30 character inside a fleet-code box.
  static const TextStyle codeBoxChar = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w700,
    height: 30 / AppFonts.size24,
  );

  /// The 12 Bold "Paste" label beside the clipboard glyph.
  static const TextStyle pasteLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w700,
  );

  /// The 12 Bold label on the Enter Fleet Code bar's "Help" button.
  static const TextStyle helpButtonLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w700,
  );

  /// The 12 Bold label on the pending sheet's "In review" pill.
  static const TextStyle inReviewLabel = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w700,
  );

  /// The 13 Bold "Reason from the dispatcher" heading.
  static const TextStyle reasonTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  /// The 14 Regular dispatcher's reason itself, in the primary ink.
  ///
  /// Not a muted tone: this is the one line on the declined sheet the driver
  /// actually came to read, so it is drawn as body copy rather than as a caption.
  static const TextStyle reasonBody = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w400,
  );

  /// The 14/18 Bold step name inside the sheet's setup-progress box.
  static const TextStyle progressStepName = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w700,
    height: 18 / AppFonts.size14,
  );

  /// The 12/16 Regular step status under that name.
  static const TextStyle progressStepStatus = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w400,
    height: 16 / AppFonts.size12,
  );

  /// The 13 Bold digit inside an unfinished step's marker ring.
  static const TextStyle stepMarkerNumber = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  /// The 15 Regular line above a footer CTA ("Lost your code?").
  static const TextStyle footerPrompt = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w400,
  );

  /// The 28/35 two-tone title on Enter fleet code.
  ///
  /// Its own token because it is the only title in the app that recolours half
  /// of itself: the second span is brand-green, and a shared `pageTitle` (32 on
  /// Find a fleet) would be the wrong size and line height for both halves.
  static const TextStyle codePageTitle = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 35 / 28,
  );

  /// The 13 Regular muted prompt beside a footer's underlined link.
  static const TextStyle footerLinkPrompt = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  // ===========================================================================
  // Merged from feature/integration-all-features (route / camera / proof-of-delivery)
  // ===========================================================================


  static const TextStyle s14Bold14 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size14,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );


  static const TextStyle s26Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 26.0,
    fontWeight: FontWeight.w700,
    height: 29.12 / 26.0,
    letterSpacing: -0.52,
  );


  static const TextStyle s26Black11 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 26.0,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.65,
  );


  static const TextStyle s24Black11 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size24,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.48,
  );


  static const TextStyle s38Bold105 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 38.0,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -1.14,
  );


  static const TextStyle s26Bold112 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 26.0,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.52,
  );


  static const TextStyle s22Bold115 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );


  static const TextStyle s20Bold125 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.1,
  );


  static const TextStyle s20Bold03 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );


  static const TextStyle s17ExtraBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 17.0,
    fontWeight: FontWeight.w800,
  );


  static const TextStyle s16Bold14 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size16,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );


  static const TextStyle s15Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );


  static const TextStyle s15Bold135 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );


  static const TextStyle s15SemiBold135 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );


  static const TextStyle s15SemiBold14 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );


  static const TextStyle s15Regular135 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );


  static const TextStyle s13Regular135 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );


  static const TextStyle s13Bold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );


  static const TextStyle s13SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );


  static const TextStyle s13Medium14 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );


  static const TextStyle s13Medium135 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );


  static const TextStyle s13Regular145 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );


  static const TextStyle s11Bold12 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );


  static const TextStyle s10Bold12 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );


  static const TextStyle s12BoldAmber = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: AppFonts.size12,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: Color(0xFFC27C00),
  );


  static const TextStyle s40MediumItalic = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 40.0,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );


  static const TextStyle s28Bold115 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.28,
  );


  static const TextStyle s14Medium145 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );


  static const TextStyle s16Medium145 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );


  static const TextStyle s12Medium145 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );


  static const TextStyle s24Bold12 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.24,
  );


  static const TextStyle s18Bold13 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );


  static const TextStyle s20ExtraBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 20.0,
    fontWeight: FontWeight.w800,
    height: 1.35,
  );


  static const TextStyle s15SemiBold = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    height: 20.0 / 15.0,
  );


  static const TextStyle s12Regular145 = TextStyle(
    fontFamily: AppFonts.fontFamilySatoshi,
    fontFamilyFallback: AppFonts.fontFamilyFallback,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );


  // ---------------------------------------------------------------------------
  // Shadows
  // ---------------------------------------------------------------------------
  static const List<BoxShadow> tripSheetShadow = [
    BoxShadow(
      color: Color.fromRGBO(34, 34, 34, 0.12),
      blurRadius: 40.0,
      spreadRadius: -8.0,
      offset: Offset(0, 16),
    ),
  ];


  static const List<BoxShadow> summaryChipShadow = [
    BoxShadow(
      color: Color.fromRGBO(31, 36, 26, 0.12),
      blurRadius: 16.0,
      offset: Offset(0, 4),
    ),
  ];


  static const List<BoxShadow> mapControlShadow = [
    BoxShadow(
      color: Color.fromRGBO(31, 36, 26, 0.12),
      blurRadius: 12.0,
      offset: Offset(0, 4),
    ),
  ];


  static const List<BoxShadow> toastShadow = [
    BoxShadow(
      color: Color.fromRGBO(31, 36, 26, 0.12),
      blurRadius: 20.0,
      offset: Offset(0, 6),
    ),
  ];


  static const List<BoxShadow> switchThumbShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];


  static const List<BoxShadow> proofSheetShadow = [
    BoxShadow(
      color: Color.fromRGBO(34, 34, 34, 0.12),
      blurRadius: 20.0,
      offset: Offset(0, 16),
    ),
  ];


  static const List<BoxShadow> segmentShadow = [
    BoxShadow(
      color: Color.fromRGBO(34, 34, 34, 0.08),
      blurRadius: 3.0,
      offset: Offset(0, 1),
    ),
  ];


  static const List<BoxShadow> puckBaseShadow = [
    BoxShadow(
      color: Color.fromRGBO(31, 36, 26, 0.25),
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];


  static const List<BoxShadow> stopMarkerShadow = [
    BoxShadow(
      color: Color.fromRGBO(31, 36, 26, 0.18),
      blurRadius: 10.0,
      offset: Offset(0, 3),
    ),
  ];


  static const List<BoxShadow> sliderKnobShadow = [
    BoxShadow(
      color: Color.fromRGBO(31, 36, 26, 0.12),
      blurRadius: 10.0,
      offset: Offset(0, 3),
    ),
  ];

}
