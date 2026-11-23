// lib/features/orders/presentation/widgets/orders_today/orders_today_metrics.dart
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The Orders / Today screen is specified in absolute dp against the 412×917
/// Figma frame, and the two gutters it uses (26 for anything with a card
/// edge, 30 for the section labels that sit optically inside that edge) have
/// to stay in step across six widgets. Collecting them here means a redline
/// change is one edit, not a hunt.
///
/// Values are raw dp — call `.w` / `.h` at the point of use so ScreenUtil can
/// scale them.
abstract final class OrdersTodayMetrics {
  OrdersTodayMetrics._();

  /// Gutter for every element that draws an edge: the header, the segmented
  /// control, the banner, and both lists.
  static const double gutter = 26;

  /// Gutter for the TODAY / UPCOMING labels, inset 4dp further so their text
  /// lines up optically with the card content rather than the card edge.
  static const double labelGutter = 30;

  // ── Header ──────────────────────────────────────────────────────────
  static const double titleTop = 12;
  static const double searchTop = 8;
  static const double searchSize = 44;
  static const double searchWidth = 70;

  // ── Vertical rhythm, top to bottom ──────────────────────────────────
  /// Title baseline block to the segmented control.
  static const double titleToSegmented = 18;
  static const double segmentedToBanner = 24;

  /// Offline only: segmented control to the "Showing saved orders" line,
  /// and that line to whatever follows it.
  static const double segmentedToOfflineNotice = 16;
  static const double offlineNoticeToContent = 20;
  static const double bannerToTodayLabel = 24;
  static const double todayLabelToList = 10;
  static const double todayListToUpcomingLabel = 7;
  static const double upcomingLabelToList = 10;

  /// Clears the bottom navigation bar so the last card is never half-hidden.
  static const double bottomPadding = 32;

  /// The arrival toast floats this far above the bottom navigation bar.
  static const double arrivalToastBottom = 18;

  /// Segmented control (plus its 24dp gap) to the empty-state icon. Fixed,
  /// not centred: it lands at the same height as the search screen's empty
  /// state, so the two read as one pattern.
  static const double emptyTop = 122;

  // ── Shared shapes ───────────────────────────────────────────────────
  static const double cardRadius = 16;
  static const double segmentedHeight = 40;
  static const double segmentedRadius = 12;
  static const double rowMinHeight = 56;
  static const double leadingBadgeSize = 32;
}

/// Applies ScreenUtil's font scaling to a const [TextStyle] from
/// `AppTextStyles`, which cannot bake `.sp` in without losing `const`.
extension ResponsiveTextStyle on TextStyle {
  TextStyle get scaled => copyWith(fontSize: fontSize?.sp);
}
