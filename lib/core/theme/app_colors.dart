import 'package:flutter/material.dart';

/// Design Tokens — Colors extracted from Figma variables.
///
/// Grouped by semantic role. Prefer semantic tokens ([textPrimary],
/// [borderActive], ...) over raw palette tokens ([brandMain]) inside widgets.
abstract final class AppColors {
  AppColors._();

  /// True while the dark theme is active. Set by `main.dart` from the resolved
  /// theme brightness; every token below marked `get` returns its dark value
  /// while this is true. Tokens that stay `const` are identical in both modes.
  static bool isDark = false;

  /// Text and icons drawn on a solid brand-green fill. Fixed ink in both
  /// themes (unlike [brandBlack], which becomes light text in dark mode).
  static const Color onBrand = Color(0xFF222222);

  // =============== Brand ===============
  static const Color brandMain = Color(0xFF8FE600);
  static const Color brandSecondary = Color(0xFF9BEF00);
  // ── Slate / neutral literals used by fleet screens (light = original literal) ──
  static Color get slateInk => isDark ? const Color(0xFFF2F5EC) : const Color(0xFF0F172A);
  static Color get slateMuted => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF64748B);
  static Color get slateSoft => isDark ? const Color(0xFF868B7C) : const Color(0xFF94A3B8);
  static Color get slateBorder => isDark ? const Color(0xFF3A4032) : const Color(0xFFE2E8F0);
  static Color get hairline => isDark ? const Color(0xFF2A2E25) : const Color(0xFFEAECF0);
  static Color get slateSurface => isDark ? const Color(0xFF1B1F16) : const Color(0xFFF8FAFC);
  static Color get mistSurface => isDark ? const Color(0xFF262A21) : const Color(0xFFF2F4F7);
  static Color get slateMuted2 => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF667085);
  static Color get grey666 => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF666666);
  static Color get grey888 => isDark ? const Color(0xFF8E9484) : const Color(0xFF888888);
  static Color get ink111 => isDark ? const Color(0xFFF2F5EC) : const Color(0xFF111111);
  static Color get lineLight => isDark ? const Color(0xFF3A4032) : const Color(0xFFE5E7EB);
  static Color get lineLight2 => isDark ? const Color(0xFF3A4032) : const Color(0xFFE0E0E0);

  // ── Status literals (light = original literal) ──
  static Color get errorRed => isDark ? const Color(0xFFFF6A4D) : const Color(0xFFEF4444);
  static Color get errorRedDeep => isDark ? const Color(0xFFFF8A6E) : const Color(0xFFD32F2F);
  static Color get errorRedDark => isDark ? const Color(0xFFFF8A6E) : const Color(0xFFB91C1C);
  static Color get errorRedText => isDark ? const Color(0xFFFF8A6E) : const Color(0xFFB42318);
  static Color get blueLink => isDark ? const Color(0xFF5AA9F5) : const Color(0xFF1E88E5);
  static Color get blueStrong => isDark ? const Color(0xFF7BA3FF) : const Color(0xFF2563EB);

  // ── Pale surfaces / greys (light = original literal) ──
  static Color get paleSurface => isDark ? const Color(0xFF1B1F16) : const Color(0xFFFAFAFA);
  static Color get slatePale => isDark ? const Color(0xFF2A2E25) : const Color(0xFFF1F5F9);
  static Color get limePale => isDark ? const Color(0xFF1F2B12) : const Color(0xFFF7FEE7);
  static Color get limePale2 => isDark ? const Color(0xFF1F2B12) : const Color(0xFFF4F8EC);
  static Color get greenPale => isDark ? const Color(0xFF1E2C10) : const Color(0xFFE8F5E9);
  static Color get redPale => isDark ? const Color(0xFF3A1D16) : const Color(0xFFFEF2F2);
  static Color get redPale2 => isDark ? const Color(0xFF3A1D16) : const Color(0xFFFDECEA);
  static Color get redPale3 => isDark ? const Color(0xFF3A1D16) : const Color(0xFFFEF3F2);
  static Color get redPale4 => isDark ? const Color(0xFF3A1D16) : const Color(0xFFFFEEEE);
  static Color get redPale5 => isDark ? const Color(0xFF3A1D16) : const Color(0xFFFFFAFA);
  static Color get redBorder => isDark ? const Color(0xFF7F3030) : const Color(0xFFFECDCA);
  static Color get redBorder2 => isDark ? const Color(0xFF7F3030) : const Color(0xFFF5B5AE);
  static Color get redBorder3 => isDark ? const Color(0xFF7F3030) : const Color(0xFFFFCDD2);
  static Color get paleSurface2 => isDark ? const Color(0xFF262A21) : const Color(0xFFF5F5F5);
  static Color get slateLine => isDark ? const Color(0xFF3A4032) : const Color(0xFFCBD5E1);
  static Color get grey6B7280 => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF6B7280);
  static Color get grey757575 => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF757575);

  static Color get brandBlack => isDark ? const Color(0xFFF2F5EC) : const Color(0xFF222222);
  static Color get brandDeepBlack => isDark ? const Color(0xFFF2F5EC) : const Color(0xFF000000);
  static Color get brandBackground => isDark ? const Color(0xFF131814) : const Color(0xFFFDFDFD);
  static const Color brandWhite = Color(0xFFFFFFFF);

  // =============== Text ===============
  static const Color textBrand = Color(0xFF8FE600);
  static const Color textSecondary = Color(0xFF9BEF00);
  static Color get textBlack => isDark ? const Color(0xFFF2F5EC) : const Color(0xFF222222);
  /// Figma `color/text/gray` (#737373): placeholders, secondary copy.
  static Color get textGray => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF737373);
  static Color get textNavUnselected => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF737373);
  static const Color textError = Color(0xFFFF3D00);
  static Color get textPrimary => textBlack;
  static Color get textHint => textGray;
  static Color get textUnderline => isDark ? const Color(0xFF3A4032) : const Color(0xFFD9D9D9);

  /// Secondary/supporting copy: subtitles, captions, metadata rows.
  ///
  /// Same value as [textGray] (Figma `color/text/gray`, #737373).
  /// Introduced with the Home feature, where every muted line (stat units, fleet
  /// zones, step labels) uses this value.
  static Color get textMuted => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF737373);

  // =============== Border ===============
  static Color get borderDeactivated => isDark ? const Color(0xFF3A4032) : const Color(0xFFD0D0D0);
  static const Color borderActivated = Color(0xFF8FE600);
  static Color get borderInactive => borderDeactivated; // alias
  static const Color borderActive = borderActivated; // alias

  /// Hairline used for card outlines and dividers.
  ///
  /// Lighter than [borderDeactivated] (#D0D0D0), which marks inputs and
  /// disabled controls.
  static Color get borderSubtle => isDark ? const Color(0xFF2A2E25) : const Color(0xFFD9D9D9);

  // =============== Shadow ===============
  // Shadow tints are part of the design, not a transparent black: the same
  // elevation is drawn with two different colours across Home (#1A1F1A) and the
  // fleet search cards (#212121), so neither can be derived from the other.

  /// Tint for soft card elevation (Home sections, stat tiles).
  static Color get shadowCard => isDark ? const Color(0xFF000000) : const Color(0xFF1A1F1A);

  /// Tint for the stronger elevation used by the fleet search cards.
  static Color get shadowStrong => isDark ? const Color(0xFF000000) : const Color(0xFF212121);

  /// Tint for the switch knob's tight 3pt shadow.
  ///
  /// Green-black, not the neutral card ink: at 20% over a 18pt knob the hue is
  /// visible, and the design draws it that way.
  static const Color shadowKnob = Color(0xFF213321);

  // =============== Surface ===============
  static Color get surfaceBackground => isDark ? const Color(0xFF131814) : const Color(0xFFFDFDFD);
  static const Color surfaceHeader = Color(0xFF9BE600);
  static Color get surfaceLines => isDark ? const Color(0xFF868B7C) : const Color(0xFFA39E9E);
  static Color get surfaceEmpty => isDark ? const Color(0xFF2A2E25) : const Color(0xFFD9D9D9);
  static Color get surfaceWhite => isDark ? const Color(0xFF1B1F16) : const Color(0xFFFFFFFF);

  /// Page background for the dashboard-style screens (Home, Notifications).
  ///
  /// Distinct from [surfaceBackground] (#FDFDFD), which the lighter pages use.
  static Color get surfaceCanvas => isDark ? const Color(0xFF131814) : const Color(0xFFF9FAF8);

  /// Tinted fill for the call-to-action cards and fleet rows.
  ///
  /// A very pale brand green: paired with a solid brand foreground it marks an
  /// actionable row without the weight of a filled button.
  static Color get surfaceTint => isDark ? const Color(0xFF1F2B12) : const Color(0xFFF0FAEC);

  /// Background fill for the "UP NEXT" card in ready-to-start state.
  static Color get surfaceUpNext => isDark ? const Color(0xFF1F2B12) : const Color(0xFFF0FAEC);

  /// 1px crisp lime-green stroke for the "UP NEXT" card container.
  static const Color borderUpNext = brandMain;

  /// Clean 1px light-gray hairline for cards (TODAY, Attention).
  static Color get borderCard => isDark ? const Color(0xFF2A2E25) : const Color(0xFFEBEBEB);

  /// Faint divider between rows and stats columns.
  static Color get dividerSubtle => isDark ? const Color(0xFF2A2E25) : const Color(0xFFEEEEEE);

  /// Light gray fill for uncompleted progress segments in TODAY card.
  static Color get progressUnfilled => isDark ? const Color(0xFF2A2E25) : const Color(0xFFEDEDED);

  /// Red-orange fill for couldn't deliver / failed progress segments in TODAY card.
  static Color get progressFailed => isDark ? const Color(0xFFFF7355) : const Color(0xFFD93400);

  /// Deep green for online status and completed checklist pills.
  static Color get textOnlineGreen => isDark ? const Color(0xFF8FE600) : const Color(0xFF65A300);

  /// Pale lime-green fill for disabled action buttons (HM4 offline start button).
  static Color get buttonDisabledLime => isDark ? const Color(0xFF3A4D1A) : const Color(0xFFCEF375);

  /// Muted olive/gray-green for disabled action button label and icon (HM4).
  static Color get textButtonDisabled => isDark ? const Color(0xFFA3C066) : const Color(0xFF85A542);

  /// Needs attention: "New orders" row disc fill and border/icon.
  static Color get surfaceAttentionBlue => isDark ? const Color(0xFF1B2742) : const Color(0xFFE8EFFE);
  static Color get borderAttentionBlue => isDark ? const Color(0xFF7BA3FF) : const Color(0xFF2563EB);
  static Color get iconAttentionBlue => isDark ? const Color(0xFF7BA3FF) : const Color(0xFF2563EB);

  /// Needs attention: "Cancelled order" row disc fill and icon.
  static Color get surfaceAttentionGray => isDark ? const Color(0xFF3A4032) : const Color(0xFFD0D0D0);
  static Color get iconAttentionGray => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF737373);

  // =============== Icons ===============
  static const Color iconActivated = Color(0xFF8FE600);
  static const Color iconSaudi = Color(0xFF006C35);
  static Color get iconProfile => isDark ? const Color(0xCCF2F5EC) : const Color(0xCC222222); // alpha 0.8
  static Color get iconBrand => isDark ? const Color(0xFF1F2B12) : const Color(0xFFF0FAEC); // Figma color/icons/brand
  static Color get iconWarning => isDark ? const Color(0xFF3A1F1B) : const Color(0xFFFDE8E8);
  static Color get iconBlue => isDark ? const Color(0xFF5AA9F5) : const Color(0xFF1976D2);
  static Color get iconBlueAccent => isDark ? const Color(0xFF7BA3FF) : const Color(0xFF2563EB); // غير موجود في JSON — matches package.svg stroke
  static const Color iconGreen = Color(0xFF4CAF50);
  static const Color iconRed = Color(0xFFFF3D00);
  static const Color iconYellow = Color(0xFFFFC107);
  static const Color iconSun = Color(0xFFF59E0B);
  static Color get surfaceSun => isDark ? const Color(0xFF3A2D12) : const Color(0xFFFEF3C7);
  static Color get iconHint => isDark ? const Color(0xFF868B7C) : const Color(0xFFB3B3B3);

  /// Amber review card tokens (J10 Under review).
  static Color get surfaceAmberLight => isDark ? const Color(0xFF3A2D12) : const Color(0xFFFEF7E6);
  static const Color borderAmber = Color(0xFFF59E0B);
  static Color get textAmber => isDark ? const Color(0xFFF0B45A) : const Color(0xFFB45309);
  static Color get iconAmber => isDark ? const Color(0xFFF0B45A) : const Color(0xFFB45309);

  // =============== Badges ===============
  //
  // The fleet status pill on the Find a fleet card is a *filled* brand chip, not
  // the pale tint an earlier pass assumed: the design draws ACTIVE on solid
  // #9BEF00 with white type and a white dot, and PAUSED on solid #D9D9D9 with
  // #737373 type. Both are solid, so the old pale `surfaceBadge` / neutral pair
  // are gone rather than kept as dead aliases.

  /// Fill behind an "ACTIVE" fleet status badge.
  static const Color surfaceBadgeActive = Color(0xFF9BEF00);

  /// Fill behind a "PAUSED" fleet status badge.
  static Color get surfaceBadgePaused => isDark ? const Color(0xFF3A4032) : const Color(0xFFD9D9D9);

  /// Type and dot colour on [surfaceBadgeActive] — the fill is too saturated for
  /// #222222 to stay legible at 10pt.
  static const Color textBadgeActive = Color(0xFFFFFFFF);

  /// Type and dot colour on [surfaceBadgePaused].
  static Color get textBadgePaused => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF737373);

  // =============== Status ===============
  static const Color success = iconGreen;
  static const Color warning = iconYellow;
  static const Color error = textError;
  static Color get info => iconBlue;

  // =============== Declined ===============
  //
  // A declined join request is the one place the design leaves the neutral
  // surface family for a tinted panel. Its four values are used together on the
  // Go Online sheet's declined card and are kept together so the card cannot end
  // up with a red fill and default-coloured text.

  /// Panel behind the decline reason.
  static Color get surfaceDeclined => isDark ? const Color(0xFF3A1D16) : const Color(0xFFFEF2F2);

  /// Hairline around [surfaceDeclined].
  static Color get borderDeclined => isDark ? const Color(0xFF7F3030) : const Color(0xFFFCA5A5);

  /// Heading inside the declined panel.
  static Color get textDeclinedTitle => isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);

  /// Body copy inside the declined panel.
  static Color get textDeclinedBody => isDark ? const Color(0xFFF3C4C4) : const Color(0xFF7F1D1D);

  // =============== Sheet copy ===============
  //
  // The bottom sheets do not use [textMuted] for their body line. They draw
  // #222222 at 80% — dark enough to read as primary copy, light enough to sit
  // under a bold title without competing with it — which is why this is its own
  // token rather than another alias of #737373.

  /// The 14pt body line under a sheet title, at 80% of the primary ink.
  static Color get textBodyStrong => isDark ? const Color(0xCCF2F5EC) : const Color(0xCC222222);

  // =============== Sheets ===============
  //
  // Each blocked reason gets its own 56pt tinted disc behind its glyph. The
  // greens and reds are *not* the pale tints the icon family already carries
  // ([iconBrand] #F0FBD7, [iconWarning] #FDE8E8) — those are a stop lighter, and
  // reusing them here made the sheet's disc read as a slightly dirty version of
  // the notification bell's.

  /// Disc behind the "no fleet" and "pending" glyphs.
  static Color get surfaceSheetIcon => isDark ? const Color(0xFF1F2B12) : const Color(0xFFE8F7D4);

  /// Disc behind the "declined" glyph — a pink, not the amber of [iconWarning],
  /// because the sheet it sits on is already red-tinted.
  static Color get surfaceSheetIconDeclined => isDark ? const Color(0xFF3A1F1B) : const Color(0xFFFEECEB);

  /// Fill of a completed setup step's status pill.
  static Color get surfaceStepDone => isDark ? const Color(0xFF1F2B12) : const Color(0xFFE8F7D4);

  /// Fill of an upcoming setup step's status pill.
  static Color get surfaceStepNext => isDark ? const Color(0xFF2A2E25) : const Color(0xFFEEEEEE);

  // =============== Overlay ===============
  //
  // The modal scrim behind the Go Online sheet. Named rather than built with
  // `Colors.black54` at the call site so the sheet's backdrop can be dimmed
  // consistently if a second sheet is ever added.
  static const Color scrim = Color(0x66000000);

  // ===========================================================================
  // Merged from feature/integration-all-features (route / camera / proof-of-delivery)
  // ===========================================================================

  static Color get canvas => isDark ? const Color(0xFF0C0E0A) : const Color(0xFFF5F6F2);

  static Color get mapLand => isDark ? const Color(0xFF1A1E16) : const Color(0xFFEEF0E8);

  static Color get routeTraveledLine => isDark ? const Color(0xFF5A5F55) : const Color(0xFFB8BDB2);

  static const Color routeUpcomingCasing = Color(0xFF6FC000);

  static Color get stopBorderUpcoming => isDark ? const Color(0xFF3A4032) : const Color(0xFFCFCFCF);

  static const Color routeAccuracyFill = Color(0xFF3B6EE0);

  static const Color routeHeadingArrow = Color(0xFF3B6FE0);

  static Color get deliveredMarkerFill => isDark ? const Color(0xFF1E2C10) : const Color(0xFFEEF9DA);

  static const Color checkStroke = Color(0xFF2F9E44);

  static Color get undoText => isDark ? const Color(0xFF8FE600) : const Color(0xFF4A7A00);

  static Color get scrimWhite => isDark ? const Color(0x8C131814) : const Color(0x8CFFFFFF);

  static Color get dangerText => isDark ? const Color(0xFFFF8A6E) : const Color(0xFFD93400);

  static Color get dangerSurface => isDark ? const Color(0xFF3A1D16) : const Color(0xFFFFECE5);

  static const Color dangerIcon = Color(0xFFFF3D00);

  static Color get statusAmber => isDark ? const Color(0xFFF0B45A) : const Color(0xFFC27C00);

  static Color get amberSurface => isDark ? const Color(0xFF3A2D12) : const Color(0xFFFFF3D6);

  static Color get scrimDark => isDark ? const Color(0x52000000) : const Color(0x52222222);

  static Color get cameraPlaceholderBg => isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000);


  // =============== Photo Illustration Tokens (P01/P02) ===============
  static const Color photoBgGradientStart = Color(0xFFDBD9D1);

  static const Color photoBgGradientEnd = Color(0xFFBDB8AD);

  static const Color photoFloor = Color(0xFFA8A399);

  static const Color photoDoor = Color(0xFF8C7861);

  static const Color photoDoorFrame = Color(0xFFEDEBE5);

  static const Color photoKnob = Color(0xFFD9C78C);

  static const Color photoDoorPlate = Color(0xFFF2F0EB);

  static const Color photoPackage = Color(0xFFC79E6B);

  static const Color photoPackageTape = Color(0xFFDBBD8C);

  static const Color photoPackageLabel = Color(0xFFF7F7F2);

  static Color get textBody => isDark ? const Color(0xFFA4AA9A) : const Color(0xFF737373);

  static Color get deactivatedBadge => isDark ? const Color(0xFF3A4032) : const Color(0xFFE9E9E9);

  static Color get sliderProgressFill => isDark ? const Color(0xFF1F2B12) : const Color(0xFFF0FAEC);

  static Color get addedSurface => isDark ? const Color(0xFF1F2B12) : const Color(0xFFF0FAEC);

  // ── Added by feature/orders ──
  static Color get textWarning => isDark ? const Color(0xFFF5C542) : const Color(0xFFB7860B); // غير موجود في JSON — labels on warning-soft surfaces
  static Color get surfaceBadge => isDark ? const Color(0xFF3A4032) : const Color(0xFFE9E9E9); // Figma color/status/deactivated — inactive badges, grey pills
  static Color get surfaceInfoSoft => isDark ? const Color(0xFF1B2742) : const Color(0xFFE8EFFE); // Figma color/status/info-surface — info icon wells
  static Color get surfaceAction => isDark ? const Color(0xFF262A21) : const Color(0xFFF4F4F2); // غير موجود في JSON — tappable secondary buttons
  static Color get surfaceWarningSoft => isDark ? const Color(0xFF3A2D12) : const Color(0xFFFDF3D9); // غير موجود في JSON — gate code and similar must-read badges
  static Color get surfaceSuccessSoft => iconBrand; // delivered wells on a light row
  static Color get statusAmberSurface => isDark ? const Color(0xFF3A2D12) : const Color(0xFFFFF3D6);
  static Color get statusDangerSurface => isDark ? const Color(0xFF3A1D16) : const Color(0xFFFFECE5);
  static Color get statusSuccessSurface => isDark ? const Color(0xFF1E2C10) : const Color(0xFFEEF9DA);
  /// Brand green dark enough to read as text on a light-green surface.
  static Color get brandDark => isDark ? const Color(0xFF9BEF00) : const Color(0xFF4E8A00);
}

/// Dynamic color scheme extension for light and dark themes.
class AppColorsScheme extends ThemeExtension<AppColorsScheme> {
  const AppColorsScheme({
    required this.background,
    required this.surface,
    required this.surfaceCanvas,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderSubtle,
    required this.brandMain,
    required this.success,
    required this.warning,
    required this.error,
    required this.scrim,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceCanvas;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color borderSubtle;
  final Color brandMain;
  final Color success;
  final Color warning;
  final Color error;
  final Color scrim;
  final Color shadow;

  static const light = AppColorsScheme(
    background: Color(0xFFFDFDFD),
    surface: Color(0xFFFFFFFF),
    surfaceCanvas: Color(0xFFF9FAF8),
    textPrimary: Color(0xFF222222),
    textSecondary: Color(0xFF737373),
    textMuted: Color(0xFF737373),
    border: Color(0xFFD0D0D0),
    borderSubtle: Color(0xFFD9D9D9),
    brandMain: Color(0xFF8FE600),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFFF3D00),
    scrim: Color(0x66000000),
    shadow: Color(0xFF1A1F1A),
  );

  static const dark = AppColorsScheme(
    background: Color(0xFF131814),
    surface: Color(0xFF1B1F16),
    surfaceCanvas: Color(0xFF0C0E0A),
    textPrimary: Color(0xFFF2F5EC),
    textSecondary: Color(0xFFA4AA9A),
    textMuted: Color(0xFFA4AA9A),
    border: Color(0xFF3A4032),
    borderSubtle: Color(0xFF3A4032),
    brandMain: Color(0xFF8FE600),
    success: Color(0xFFA5E24A),
    warning: Color(0xFFF0B45A),
    error: Color(0xFFFF7355),
    scrim: Color(0x99000000),
    shadow: Color(0x66000000),
  );

  @override
  AppColorsScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceCanvas,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? borderSubtle,
    Color? brandMain,
    Color? success,
    Color? warning,
    Color? error,
    Color? scrim,
    Color? shadow,
  }) {
    return AppColorsScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceCanvas: surfaceCanvas ?? this.surfaceCanvas,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      brandMain: brandMain ?? this.brandMain,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColorsScheme lerp(ThemeExtension<AppColorsScheme>? other, double t) {
    if (other is! AppColorsScheme) return this;
    return AppColorsScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceCanvas: Color.lerp(surfaceCanvas, other.surfaceCanvas, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      brandMain: Color.lerp(brandMain, other.brandMain, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension BuildContextColorsX on BuildContext {
  AppColorsScheme get colors =>
      Theme.of(this).extension<AppColorsScheme>() ?? AppColorsScheme.light;
}
