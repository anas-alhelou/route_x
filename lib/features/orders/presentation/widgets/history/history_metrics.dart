// lib/features/orders/presentation/widgets/history/history_metrics.dart

/// Layout values for the History tab, in raw dp against the 412-wide Figma
/// frame. Call `.w` / `.h` / `.r` at the point of use.
///
/// Gutters and card shapes match the Orders tab, so switching segments
/// changes the content, not the frame around it.
abstract final class HistoryMetrics {
  HistoryMetrics._();

  static const double gutter = 26;
  static const double labelGutter = 30;

  // ── Period chips ────────────────────────────────────────────────────
  static const double segmentedToChips = 16;
  static const double chipHeight = 30;
  static const double chipGap = 4;
  static const double chipsToSummary = 18;

  /// Offline: chips to "Showing saved history", and that line to the card.
  static const double chipsToOfflineNotice = 16;
  static const double offlineNoticeToSummary = 14;

  // ── Summary card ────────────────────────────────────────────────────
  static const double cardPadding = 20;
  static const double cardRadius = 16;

  /// The summary card and what stands in for it — rounder than the cards
  /// below, as in Figma.
  static const double summaryRadius = 24;

  /// A stop record's outcome and timeline cards.
  static const double recordCardRadius = 20;
  static const double headingToFigure = 6;
  static const double figureToSentence = 6;
  static const double sentenceToChart = 22;
  static const double chartHeight = 72;
  static const double barWidth = 28;
  static const double barRadius = 6;

  /// A day with no deliveries still draws a sliver, so the axis reads as
  /// "zero" rather than "missing".
  static const double barMinHeight = 4;
  static const double barToLabel = 6;
  static const double chartToDivider = 20;
  static const double dividerToStats = 20;

  // ── Below the summary ───────────────────────────────────────────────
  static const double cardGap = 14;
  static const double cardToDaysLabel = 24;

  /// Month: "Worth a look" to the WEEKS label — wider than the day list's
  /// gap, the insight closes the summary before the list starts.
  static const double insightToWeeksLabel = 36;
  static const double labelToList = 10;
  static const double bottomPadding = 32;
}
