// lib/features/orders/presentation/widgets/search/search_metrics.dart

/// Layout values for the search screen, in raw dp against the 412×917 Figma
/// frame. Call `.w` / `.h` / `.r` at the point of use.
///
/// Gutters match the Orders list (26 for edges, 30 for labels), so a result
/// row sits exactly where the same order sits on the list behind it.
abstract final class SearchMetrics {
  SearchMetrics._();

  static const double gutter = 26;
  static const double labelGutter = 30;

  // ── Search field ────────────────────────────────────────────────────
  static const double fieldTop = 10;
  static const double fieldHeight = 56;
  static const double fieldRadius = 16;
  static const double fieldToCancel = 8;

  // ── Scope chips ─────────────────────────────────────────────────────
  static const double fieldToChips = 16;
  static const double chipHeight = 34;
  static const double chipGap = 9;

  // ── Results ─────────────────────────────────────────────────────────
  static const double chipsToLabel = 22;
  static const double labelToList = 10;
  static const double listToHelp = 16;

  // ── No results ──────────────────────────────────────────────────────
  /// Chips to the empty-state icon. Fixed rather than centred, so the block
  /// stays put when the keyboard opens or closes beneath it.
  static const double chipsToEmpty = 144;

  static const double bottomPadding = 32;
}
