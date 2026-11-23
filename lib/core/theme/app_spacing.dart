/// The app's 4pt spacing scale.
///
/// Every value is unitless so callers can run it through ScreenUtil (`.w`, `.h`)
/// or use it raw where the design fixes the measurement in logical pixels.
class AppSpacing {
  AppSpacing._();

  static const double s0 = 0.0;
  static const double s1 = 1.0;
  static const double s2 = 2.0;

  /// Half a point: the app's one off-scale border, used wherever a brand-green
  /// outline needs to read as slightly stronger than a hairline without becoming
  /// a visible 2pt frame.
  ///
  /// Not on the integer scale on purpose — a 1.5pt stroke is the design's own
  /// weight, so rounding it to [s2] would double the apparent line weight.
  static const double s1_5 = 1.5;
  static const double s3 = 3.0;
  static const double s4 = 4.0;
  static const double s5 = 5.0;
  static const double s6 = 6.0;
  static const double s7 = 7.0;
  static const double s8 = 8.0;
  static const double s9 = 9.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s13 = 13.0;
  static const double s14 = 14.0;
  static const double s15 = 15.0;
  static const double s16 = 16.0;
  static const double s18 = 18.0;
  static const double s20 = 20.0;
  static const double s22 = 22.0;
  static const double s24 = 24.0;
  static const double s26 = 26.0;
  static const double s28 = 28.0;
  static const double s30 = 30.0;
  static const double s32 = 32.0;
  static const double s34 = 34.0;
  static const double s36 = 36.0;
  static const double s40 = 40.0;
  static const double s45 = 45.0;
  static const double s48 = 48.0;
  static const double s52 = 52.0;
  static const double s56 = 56.0;
  static const double s64 = 64.0;
  static const double s70 = 70.0;
  static const double s96 = 96.0;
}
