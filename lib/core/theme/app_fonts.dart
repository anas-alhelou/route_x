class AppFonts {
  AppFonts._();

  // --- Font Family ---
  /// Primary family: every Latin letter, digit and punctuation mark.
  static const String fontFamilySatoshi = "Satoshi";

  /// Arabic family, registered in `pubspec.yaml` with all seven weights.
  ///
  /// Never used on its own — see [fontFamilyFallback]. It is the family that
  /// actually owns the Arabic script, which Satoshi has no glyphs for.
  static const String fontFamilyArabic = "IBMPlexSansArabic";

  /// Families tried, in order, for any glyph the primary one cannot draw.
  ///
  /// Attaching this to a `TextStyle` (or to a `ThemeData`) is what makes the
  /// Arabic text render in IBM Plex Sans Arabic while the Latin letters and
  /// digits of the same string keep their Satoshi shapes: fallback resolution is
  /// per glyph, not per string or per locale, so a mixed line needs no branching
  /// and nothing has to be switched when the language changes.
  static const List<String> fontFamilyFallback = <String>[fontFamilyArabic];

  // --- Font Size ---
  static const double size10 = 10.0;
  static const double size11 = 11.0;
  static const double size12 = 12.0;
  static const double size14 = 14.0;
  static const double size15 = 15.0;
  static const double size16 = 16.0;
  static const double size20 = 20.0;
  static const double size22 = 22.0;
  static const double size24 = 24.0;
  static const double size28 = 28.0;
  static const double size32 = 32.0;
  static const double size36 = 36.0;
  static const double size48 = 48.0;

  // --- Font Line Height ---
  static const double lineHeight10 = 14.0;
  static const double lineHeight11 = 15.0;
  static const double lineHeight12 = 16.0;
  static const double lineHeight14 = 20.0;
  static const double lineHeight15 = 23.0;
  static const double lineHeight16 = 22.0;
  static const double lineHeight20 = 28.0;
  static const double lineHeight22 = 28.0;
  static const double lineHeight24 = 34.0;
  static const double lineHeight28 = 40.0;
  static const double lineHeight32 = 44.0;
  static const double lineHeight36 = 50.0;
}
