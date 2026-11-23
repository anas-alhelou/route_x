/// Centralized Design System Sizes & ScreenUtil Configuration
class AppSizes {
  AppSizes._(); // prevent instantiation

  // ── Figma Canvas Dimensions ───────────────────────────────────────────────
  static const double figmaDesignWidth = 412;
  static const double figmaDesignHeight = 917;

  // ── Spacing / Padding / Margins ──────────────────────────────────────────
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;

  /// Horizontal gutter of the dashboard-style screens (Home, Notifications,
  /// Find a fleet).
  ///
  /// Wider than [p24] and not part of the 4pt scale: it is what leaves a 360pt
  /// content column inside the 412pt canvas these screens are drawn on.
  static const double screenGutter = 26.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double r3 = 3.0;
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r18 = 18.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;

  /// Fully rounded: switches, filter chips, circular icon wells and back
  /// buttons. Any value past half the shape's shortest side behaves the same.
  static const double rPill = 200.0;

  // ── Icon Sizes ────────────────────────────────────────────────────────────
  static const double iconXs = 10.0;
  static const double iconSm = 20.0;
  static const double iconMd = 22.0;
  static const double iconLg = 28.0;
  static const double iconXl = 36.0;

  /// The van glyph on the "Get started" panel.
  ///
  /// 24pt sits between [iconMd] and [iconLg] but is the design's own component
  /// size here rather than a step on the icon scale, so it gets its own name
  /// instead of bending the scale around it.
  static const double setupIcon = 24.0;

  // ── Avatar Sizes ──────────────────────────────────────────────────────────
  static const double avatarSm = 40.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 52.0;
  static const double bellButton = 44.0;
  static const double cardInnerPad21 = 21.0;
  static const double upNextIconContainer = 48.0;
  static const double attentionIconContainer = 36.0;
  static const double attentionRowH = 61.0;
  static const double attentionDividerInset = 17.0;

  /// The fleet mark inside the Go Online sheet's request card.
  ///
  /// Between [avatarSm] and [avatarMd] and not a step on that scale — it is the
  /// design's own size for that one card, so it gets its own name rather than
  /// bending the two neighbours around it.
  static const double avatarRequest = 42.0;

  // ── Component Heights ─────────────────────────────────────────────────────
  static const double switchTrackH = 24.0;
  static const double switchTrackW = 44.0;
  static const double switchKnob = 18.0;
  static const double buttonH36 = 36.0;
  static const double buttonH52 = 52.0;
  static const double buttonH56 = 56.0;

  /// Height of every single-line text field (matches the 56pt buttons).
  static const double textFieldH56 = 56.0;

  /// Width of every input, button and search bar in the design: the 412pt
  /// frame minus its 26pt margins. Wider screens keep this width, centred.
  static const double controlW360 = 360.0;

  /// The selected Find-a-fleet filter chip.
  ///
  /// Two points shorter than [buttonH36]: the design draws the selected chip
  /// filled and without a border, and a selected chip one point taller than its
  /// neighbours reads as a rendering error rather than as a state change.
  static const double chipH34 = 34.0;

  /// Width of the fleet row's Join button — fixed by the design so the three
  /// rows line up down the list.
  static const double buttonW80 = 80.0;

  /// Width of the *disabled* Join button on the paused fleet card.
  ///
  /// Four points narrower than [buttonW80]: the outlined treatment has a border
  /// to draw, and the design draws it that much tighter than the filled one. It
  /// means the paused card's button does not line up with the four above it —
  /// which is exactly how the design draws it, and the disabled treatment is
  /// what makes the difference legible as "unavailable" rather than a mistake.
  static const double buttonW64 = 64.0;

  static const double rowH60 = 60.0;
  static const double rowH80 = 80.0;
  static const double statTileH = 142.0;
  static const double statTileW = 132.0;

  /// Fixed height of the Home "Quick actions" panel.
  ///
  /// The only Home section card with a declared height: the design draws it at
  /// 200 so its two rows sit centred in a fixed panel rather than hugging the
  /// title, and the card would otherwise shrink-wrap to its content.
  static const double quickActionsCardH = 200.0;

  // ── Top Bars ──────────────────────────────────────────────────────────────
  //
  // The three paged screens in this flow do not share a bar height: the two
  // dashboard screens that open from Home use a 50pt bar and Find a fleet uses
  // 56pt for its taller location pill. Both values are named so a screen picks
  // its own instead of defaulting to whichever one was written first.

  /// Height of the Notifications top bar.
  static const double topBarH50 = 50.0;

  /// Height of the Find a fleet top bar — sized by its 40pt location pill.
  static const double topBarH56 = 56.0;

  /// Height of the city pill on the Find a Fleet top bar.
  static const double pillH40 = 40.0;

  /// Width of that pill — fixed by the design, not derived from the city name.
  ///
  /// A pill that grew with its label would move the pin and the text every time
  /// a city with a longer name was localized, and the pin would stop lining up
  /// with anything below it.
  static const double pillW88 = 88.0;

  /// Circular hit target of a top bar's back button.
  static const double backButton = 40.0;

  /// The 32pt chevron drawn inside [backButton].
  static const double backButtonIcon = 32.0;

  // ── Location Pill ─────────────────────────────────────────────────────────
  static const double locationPillH = 40.0;

  // ── Fleet List ────────────────────────────────────────────────────────────
  static const double fleetCardH = 105.0;

  // ── Notifications ─────────────────────────────────────────────────────────
  static const double illustrationW = 170.0;
  static const double illustrationH = 154.0;

  /// Fixed width of the "Notification settings" button.
  ///
  /// The design centres a 240pt button in the empty state rather than letting it
  /// span the content column, so it does not scale with the screen the way the
  /// other full-width buttons do.
  static const double settingsButtonW = 240.0;

  // ── Bottom Sheet ──────────────────────────────────────────────────────────

  /// Width of the drag handle at the top of a modal sheet.
  static const double sheetHandleW = 40.0;

  /// Thickness of that handle.
  static const double sheetHandleH = 4.0;

  /// The tinted circle behind a sheet's leading icon.
  static const double sheetIconWell = 56.0;

  /// Diameter of a step marker inside the sheet's setup-progress box.
  static const double stepMarker = 28.0;

  // ── Enter Fleet Code ──────────────────────────────────────────────────────

  /// Side of a single code box. Paired with [codeBoxH].
  static const double codeBoxW = 52.0;

  /// Height of a single code box — taller than wide, as the design draws it.
  static const double codeBoxH = 60.0;

  /// The "Help" button on the Enter Fleet Code bar.
  static const double helpButtonW = 80.0;

  /// Height of that button, matching the bar's own controls.
  static const double helpButtonH = 40.0;

  // ── Badges ────────────────────────────────────────────────────────────────

  /// Diameter of the status dot inside a fleet badge.
  ///
  /// Six points, not five: the design's badge is a solid fill, and at that
  /// contrast a 5pt dot reads as a speck rather than as a status indicator.
  static const double badgeDot = 6.0;

  // ── Bottom Navigation ──────────────────────────────────────────────────────
  //
  // Figma: "BottomNav light / Home active" on the 412×917 Home canvas
  // (node 4831:4474 component set). The bar is a floating capsule, not a
  // docked Material bar: it sits 26pt in from each side and 32pt above the
  // screen bottom (on top of the safe-area inset).

  /// Height of the floating bottom nav capsule.
  static const double bottomNavH = 70.0;

  /// Corner radius of the capsule. Past half the height, so it reads as a
  /// full pill rather than a rounded rectangle.
  static const double bottomNavRadius = 45.0;

  /// Padding inside the capsule, on every edge.
  static const double bottomNavPad = 8.0;

  /// Side inset of the bar on the 412 canvas — leaves a 360pt capsule.
  static const double bottomNavSideGutter = 26.0;

  /// Gap from the screen bottom (above the safe area) to the capsule.
  static const double bottomNavBottomGap = 32.0;

  /// Space a scrolling page must leave at its end so its last item can be
  /// scrolled above the floating bottom bar: bar height + gap above the screen
  /// bottom + a little air.
  static const double bottomNavClearance = bottomNavH + bottomNavBottomGap + 16.0;

  /// Icon well of an *inactive* tab — a 36pt circle with no fill.
  static const double bottomNavWellInactive = 36.0;

  /// Width of the *active* tab's filled pill (the well expands on select).
  static const double bottomNavWellActiveW = 60.0;

  /// Height of the *active* tab's filled pill.
  static const double bottomNavWellActiveH = 40.0;

  /// Corner radius of the active pill / inactive well.
  static const double bottomNavWellRadius = 20.0;

  /// Glyph size drawn inside the icon well.
  static const double bottomNavIcon = 30.0;

  /// Label row height — Satoshi 12 on a 10.5px line box.
  static const double bottomNavLabelH = 11.0;

  /// Hairline stroke around the capsule.
  static const double bottomNavStroke = 1.0;

  // ── Bottom Inset ──────────────────────────────────────────────────────────

  /// Bottom inset Home leaves below its last section.
  ///
  /// Home is hosted inside MainLayout's `IndexedStack` and the bottom bar floats
  /// over the page rather than pushing it, so the scroll view has to reserve
  /// room for the bar itself plus its safe-area inset and the design's gap.
  ///
  /// 32 (bottom gap) + 70 (bar height) + 16 (gap to last card) = 118.
  static const double homeBottomInset = 118.0;

  /// Bottom inset Find a fleet leaves so the sticky invite footer never covers
  /// the last card: the footer's own 127pt plus the 32pt of breathing room the
  /// design draws between the list and the footer's top edge.
  static const double findFleetBottomInset = 159.0;

  // ===========================================================================
  // Merged from feature/integration-all-features (route / camera / proof-of-delivery)
  // ===========================================================================

  // ── Bottom Navigation Bar Geometry ──────────────────────────────────────
  static const double navBottomPadding = 32.0;

  static const double navHeight = 64.0;

  static const double sheetBottomGap = 26.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double r5 = 5.0;

  static const double r26 = 26.0;

  static const double r45 = 45.0;

  static const double r100 = 100.0;
}
