// lib/features/orders/presentation/widgets/order_detail/order_detail_metrics.dart

/// Layout values for the order detail screen, in raw dp against the 412×917
/// Figma frame. Call `.w` / `.h` / `.r` at the point of use.
///
/// The horizontal gutter is deliberately the Today list's 26dp: the detail
/// slides in from that list, and cards that keep their edge through the
/// transition read as the same object opening up rather than a new page.
abstract final class OrderDetailMetrics {
  OrderDetailMetrics._();

  static const double gutter = 26;

  // ── Back row ────────────────────────────────────────────────────────
  static const double backTop = 2;
  static const double backHeight = 44;

  // ── Hero, top to bottom ─────────────────────────────────────────────
  static const double backToStatus = 12;
  static const double statusToName = 8;
  static const double subtitleToActions = 18;

  // ── Action row ──────────────────────────────────────────────────────
  static const double actionHeight = 72;
  static const double actionGap = 12;
  static const double actionRadius = 16;

  // ── Info cards ──────────────────────────────────────────────────────
  static const double actionsToFirstCard = 16;
  static const double cardGap = 12;
  static const double cardPaddingH = 20;
  static const double cardPaddingV = 18;
  static const double cardRadius = 16;

  /// Section label ("ADDRESS") to the card's first line of content.
  static const double labelToContent = 4;

  // ── Footer button ───────────────────────────────────────────────────
  static const double lastCardToButton = 16;
  static const double buttonHeight = 56;
  static const double buttonRadius = 8;

  static const double bottomPadding = 32;
}
