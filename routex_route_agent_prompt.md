# RouteX Mobile — Implement the "Route" flow from Figma (Flutter)

You are working in the Flutter project `routeX_mobile` (clean architecture: `lib/features/<feature>/{data,domain,presentation}`, `flutter_bloc`, `go_router`, `get_it`, `flutter_screenutil`, `flutter_svg`, `google_maps_flutter` / `flutter_map`, ARB localization in `lib/core/l10n` with `en` + `ar`).
The Route feature lives in `lib/features/route_fleet/`. Screens R00–R04 (loading / nothing yet / planning / ready / location needed) already exist there (`route_loading_view`, `route_empty_view`, `route_planning_view`, `route_planning_ready_sheet`, `route_location_needed_view`).

Your job: bring the Route feature in line with the new Figma design and build every missing screen/state listed below.

## 0. Source of truth

- Figma file key: `coKPQfPx4w6hLh1o4B6Yl3` ("RouteX For TaQat")
- Route section node: `6410:53324` (47 mobile frames, each 412×917)
- The project has `mcp.json` with the Figma MCP server. If the Figma MCP is connected in your session, call `get_design_context` per node ID listed in section 5 (plus a screenshot) before building each screen. If a response comes back "sparse", call it again on the child node IDs.
- Figma Starter plan has a tool-call limit. Read screens in small batches, save the notes you take, and do not re-read nodes you already have notes for.
- Everything in sections 1–4 was already read from Figma. Frames marked **READ** in section 5 are specified here in full. Frames marked **TO READ** were not read yet, so read them from Figma before building. Do not guess their layout.

## 1. Rules

1. Inspect the project first. Reuse existing widgets, `AppColors`, `AppTextStyles`, `AppSpacing`, `AppFonts`, `CustomButton` / `RoutexMainButton`, and existing assets before creating anything new. Extend them only if they can't express the design.
2. No hard-coded colors, text styles or user-facing strings. Colors go in `core/theme/app_colors.dart`. Strings go in `app_en.arb` and `app_ar.arb`, then run `flutter gen-l10n`. Arabic text needs RTL-safe layout (use `Directionality`-aware `EdgeInsetsDirectional`, `AlignmentDirectional`). Mark Arabic translations as drafts in your summary.
3. Use `flutter_screenutil` the way the rest of the project does. The design frame is 412 wide.
4. Icons are custom SVGs (24px grid, 1.75 stroke `#222`). Download each from Figma into `assets/icons/...` (or the project's existing icon folder), register it in `AppAssets` / pubspec, and render it with `flutter_svg`. Never leave Figma asset URLs (`figma.com/api/mcp/asset/...`) in code; they expire in 7 days.
5. Follow the existing bloc/cubit pattern in `route_fleet`. UI states are driven by state classes. Do not put business logic in widgets.
6. Don't redesign R00–R04. Compare them with Figma, list differences, and fix only real mismatches.
7. Verify every screen against the Figma screenshot (run the app or a widget/golden test). Report what you could not verify.

## 2. Design tokens (from Figma variables)

| Token | Hex | Notes |
|---|---|---|
| Color/brand/main (also icons/activiated, border/activiated) | `#8FE600` | lime: primary buttons, active chips, route line |
| Color/text/brand | `#8FE600` | used for ETA time and "En route" label |
| Color/text/black (brand-black) | `#222222` | |
| Color/text/gray | `#737373` | secondary text |
| Color/brand/White | `#FFFFFF` | chips, map controls |
| Color/brand/background | `#FDFDFD` | sheets / banners background |
| Color/Surface/canvas | `#F5F6F2` | "Then" strip, notes, detail lists |
| Color/icons/brand | `#F0FAEC` | selected tiles, slide-to-start track |
| Color/status/deactivated | `#E9E9E9` | inactive circles, action tiles, inputs |
| Color/border/Deactiviated | `#D0D0D0` | 1px borders, dividers |
| Color/Surface/empty | `#D9D9D9` | skeleton |
| Color/status/success-text | `#4A7A00` | "Undo" |
| Color/status/danger-text | `#D93400` | "End route", "End route early" |
| Color/status/danger-surface | `#FFECE5` | danger box background |
| Color/icons/red | `#FF3D00` | danger box border and text |
| Spacing/2, Spacing/24, layout grid padding | 2, 24, 8 | sheet inner padding is 24 |

Radii in use: sheets/banners 24, pills (chips/toast/route summary) 100, buttons 8, tiles 18, app rows 12, small notes 6 to 16, circles = half the size.
Shadows: sheet/banner `0 16 40 -8 rgba(34,34,34,.12)`; chip `0 4 16 rgba(31,36,26,.12)`; map control `0 4 12 rgba(31,36,26,.12)`; toast `0 6 20 rgba(31,36,26,.12)`; knob `0 3 10 rgba(31,36,26,.12)`.
Sheets have a 1px `#D0D0D0` border. Floating sheets sit 26px from the screen sides (360 wide on a 412 screen).

Typography: **Plus Jakarta Sans** is the main font (Regular / Medium / SemiBold / Bold / ExtraBold). Common styles: sheet title 26 Bold, -0.52 letter spacing, line height 1.12; mid title 24 Bold / 20 Bold; body 14 Regular/Medium; caption 12 Regular/Medium; overline 10 Bold, +0.6 letter spacing, uppercase; button label 16 Bold; maneuver distance 28 Bold; trip stat 18 Bold; ETA 24 Bold lime.
⚠ Inconsistency in the design: some frames (R22 "End route now?", R27 "Next stop details") use **Satoshi**, and the "R" logo mark uses **Monument Extended**. Check which fonts are already in `pubspec.yaml`. Use Plus Jakarta Sans for all body UI, keep Monument Extended only for the logo tile, and tell me about every place where Satoshi appeared so I can confirm with the designer.

Buttons: height 56 (primary / secondary in sheets) or 52 (in R27/R33), radius 8. Primary = lime fill + black text. Secondary = white fill + 1px `#D0D0D0` border. Text-only destructive = 44 to 56 high, danger-text color.

## 3. Shared components to build once (in `route_fleet/presentation/widgets/`)

All specs below are READ from Figma.

1. **MapSheet container.** Background `#FDFDFD`, 1px `#D0D0D0` border, radius 24, padding 24, sheet shadow. Children are laid out in a column with 14px gap (12 in R27, 16 in the reason sheet).
2. **RouteSummaryChip.** White pill, padding 16×10, shadow. Contents: `icon/route` 18px, "3 stops" 14 Bold, then "6.8 km · 32 min" 12 Medium gray. Position x16 y64.
3. **ManeuverBanner.** Radius 24 card, with a top part and a "Then" strip.
   - Top part, padding 14: a 60×60 lime tile (radius 16) holding a 36px maneuver icon (`icon/turn-left` and variants), then a column. The column has the distance (28 Bold, tracking -0.28) and the unit ("m", 14 Medium gray, bottom-aligned with a 4px gap), then the instruction at 16 Medium ("Turn left onto Sari St").
   - "Then" strip: `#F5F6F2` background, padding 16×10, bottom radius 24. Contents: "Then" 12 Medium gray, `icon/pin` 16px, "Stop 1 is on the right" 12 Medium black.
4. **MapControls.** A vertical column, 10px gap, of 48×48 white circles (radius 24, shadow): `icon/overview` (22px), `icon/stops` (22px), and a "?" glyph (20 ExtraBold). These map to recenter/overview, open the stops list, open help.
5. **TripSheet (driving).**
   - Stats row: ETA "10:05" (24 Bold lime) with an "arrival" caption (12 gray). Then "4 min" and "1.1 km" (18 Bold). Three equal columns.
   - 1px divider `#D0D0D0`.
   - Current-stop row: a 36px lime circle with the stop number (16 Bold), then name (14 Bold) with address and order id ("Sari St, Al Zahra · #RX-1039", 12 gray). At the end sit a 44px gray circle with `icon/call` and a 44px lime circle with `icon/navigate` ("open in maps app").
6. **ArrivedChip.** Same shape as RouteSummaryChip: `icon/arrive` 18px (flag) + "You've arrived" 14 Bold.
7. **ArrivalSheet.**
   - Header row: "STOP 1 OF 3" (10 Bold, +0.6, gray) and, on the right, `icon/eta` 16px + "Arrived 10:05" 12 Medium gray.
   - Name 26 Bold. Under it "Sari St, Al Zahra · #RX-1039" 12 gray (gap 2).
   - Quick actions: 4 equal tiles (radius 8, `#E9E9E9`, padding 8×10, 22px icon over a 12 Medium label): **Call, Note, Maps, More**.
   - Company note: `#F5F6F2`, 1px border, radius 6, padding 12×10, `icon/note` 16px + text 12 ("Call when you arrive. Building 12, 3rd floor.").
   - Outcome buttons, side by side with a 10 gap: **Couldn't deliver** (secondary, 56 high) and **Delivered** (lime, with `icon/delivered` 24px).
8. **Toast.** White pill, 1px border, padding 16×10, toast shadow. Contents: `icon/delivered` 20px, "Delivered · Omar Haddad" 14 Bold, a 1×18 divider, and "Undo" (14 Bold, `#4A7A00`).
9. **StateBanner** (rerouting / weak GPS / offline). Radius-24 card, padding 14, 12 gap. A 52×52 `#E9E9E9` tile (radius 16) with a 28px icon, then a title (18 Bold) and a message (12 gray, 270 wide). Weak GPS reads "Weak GPS signal" / "Your position may be off for a moment. Keep driving safely." with `icon/recenter`. Rerouting ("Finding a new way") and offline ("You're offline") use the same layout, so read their nodes for text, icons and tile color.
10. **Scrim.** Full-screen dim layer behind modal sheets (R16, R20, R21, R22, R26b, R29, R31, R43, R44, P04). Read node `…53833` for opacity.
11. **StopRow** (used in the ready sheet and the Stops sheet): 32px circle (lime if current, `#E9E9E9` otherwise) with the number (12 Bold), name 14 Bold + address 12 gray, and the time/ETA on the right (12 Medium gray; lime for the current stop). In the Stops sheet the current row is a card (`#F0FAEC`, 1px lime border, radius 12, padding 12) and the others have radius 16 and no fill.

## 4. Sheets / dialogs fully specified (READ)

- **Ready sheet (R03):** title "Your route is ready" 26 Bold, subtitle "Stops are ordered for the fastest drive. Times are estimates." 12 gray. Stops list: 3 StopRows (padding 10 vertical). Then **Slide to start route**: a track (`#F0FAEC`, radius 32, padding 6, 64 high) with a 52px lime knob carrying `icon/navigate`, and a 14 Bold label. It's a slide gesture; the knob returns if released early (the project already has `slide_to_start.dart` in onboarding, so reuse or generalize it). Bottom nav (360×70) is at x26 y815.
- **Reason sheet (R16 "What happened?"):** title 24 Bold, subtitle "Lina Fares · Red Sea Express will review this order." 14 gray. A 2×2 grid of reason tiles (gap 10, 104 high, radius 18, padding 14, icon 24 over a 14 Bold label). The tiles are **Customer not answering** (`icon/call`), **Wrong address** (`carbon:location` pin), **Customer refused** (`icon/cancelled`) and **Can't reach location** (`icon/navigate`). The selected tile has a `#F0FAEC` fill and a 2px lime border. The others are white with a 1px `#D0D0D0` border. Below that is a note field (`#E9E9E9`, 1px border, radius 6, label "Add a note (optional)" 12 Medium gray, value 14) and a lime button "Send to Red Sea Express".
- **Navigate-with sheet (R20):** title "Navigate with" 20 Bold, subtitle "Pick how you want directions to Omar Haddad." Three app rows (radius 12, padding 14×12, 8 gap): **RouteX** ("Turn-by-turn inside the app", selected: `#F0FAEC` fill, 2px lime border, radio dot with 6px lime ring), **Google Maps** and **Waze** (both "Opens one stop at a time", with unselected 22px radio circles). Each row has a 40px white logo tile (the RouteX one is an "R" in Monument Extended). Then a row "Always use this app" with a 52×32 switch (on = lime), a hint note box ("Come back to RouteX to mark each stop as delivered.", `#F5F6F2`, radius 12) and a lime "Start directions" button (`icon/navigate` 22px).
- **Stops sheet (R21 "Today's route"):** title 20 Bold + "0 of 3 done" 12 Medium gray; a 3-segment progress bar (6px high, radius 3, 4px gap; done = lime, rest `#E9E9E9`); 3 StopRows (the current one reads "En route · ETA 10:05" in lime, the rest "ETA 10:24" / "ETA 10:41"); secondary "Back to directions"; a text button "End route early" (15 SemiBold, `#D93400`, 44 high).
- **End route? (R22):** title "End route now?" 26 Bold, body "You still have 2 stops. Their orders go back to Red Sea Express so they can be reassigned. This can't be undone." 14 gray. A danger box (`#FFECE5`, 1px `#FF3D00`, radius 12, text 13 Medium `#FF3D00`) lists "Lina Fares · Tahlia St, Al Nahda" and "Ahmed Ali · Prince Sultan St, Al Rawdah". Buttons: lime "Keep delivering", then a text button "End route" (16 Bold, `#D93400`).
- **Next stop details (R27):** overline "NEXT STOP · 1 OF 3" (10 Bold, +1.2), name 26 Bold, "Sari St, Al Zahra · #RX-1039 · 1.1 km" 13 gray. A details list (`#F5F6F2`, 1px border, radius 16, padding 16×4) with label/value rows (padding 10): **Gate code** 4417#, **Time window** 10:00 – 10:30, **Packages** 2 · drop-off. A note row (`icon/note` 18 + 14 Medium text). Buttons: secondary **Call** and **Message** side by side (52 high), then lime **Back to map** (52 high).
- **Location sharing stopped (R33):** a row with a 42px `#FFECE5` tile (radius 8) holding the location icon; the title "Location sharing stopped" (15 SemiBold) and the message "Red Sea Express can't see your route. Turn it back on to keep delivering." (13 gray); then a lime **Turn on** button (52 high).

## 5. Screen inventory (node IDs, build order, status)

Figma frame IDs are under section `6410:53324`. "Overlay" lists the child nodes holding the UI that changes per screen. The map ("World", route line, stop pins, "Driver puck") is the same in all of them and should come from the real map widget in code.

**A. Pre-route (already exist; verify only)**
- R00 loading `6410:54367` (Skeleton 54374, Trip sheet 54375)
- R01 nothing yet `6410:53325` (Empty route 53334) — "No route right now", button "See my orders"
- R02 planning `6410:53343` (Trip sheet 53364)
- R03 ready to start `6410:53401` — **READ**
- R04 location needed `6410:54335` (Trip sheet 54357) — "Turn on location to start", "Allow location" / "Not now"

**B. Driving and delivery loop**
- R10 heading out `6410:53453` — ManeuverBanner + MapControls + TripSheet — **READ**
- R11 almost there `6410:53514` — same components, different values
- R12 arrived, stop 2 `6410:53571` — ArrivedChip + ArrivalSheet — **READ**
- R13 delivered + undo `6410:53626` — Toast `…53648` **READ**, Trip sheet `…53653` (TO READ: next-stop preview with a "Go to next stop" lime button)
- R14 driving to stop 3 `6410:53668`; R15 arrived stop 3 `6410:53730`
- R16 couldn't deliver, reason `6410:53783` — Reason sheet `…53834` **READ** over a Scrim
- R17 driving to last stop `6410:53859` (also has a Toast `…53895`); R18 arrived last stop `6410:53925`
- R19 route complete `6410:55185` (taller frame, 412×1048, scrolls) — TO READ: Date, Title "Route complete", Subtitle, To-do card ("Return Lina's package to the depot", "Directions to depot" lime button), Outcome ring ("2 of 3 delivered"), Distance and time (14.2 km / 52 min), Stops list with status rows, buttons "Done" and "See in history"

**C. Navigation helpers**
- R20 Navigate with `6410:53976` — sheet `…54036` **READ**
- R21 All stops `6410:54079` — sheet `…54139` **READ**
- R22 End route? `6410:54410` — sheet `…54470` **READ**
- R23 Rerouting `6410:54173` — StateBanner `…54194` (TO READ; "Finding a new way")
- R24 Weak GPS `6410:54227` — StateBanner `…54248` **READ**
- R25 Offline `6410:54281` — StateBanner `…54302` (TO READ; "You're offline")

**D. Updates and help**
- R26 Route changed (driving) `6410:54480` — Route update card `…54539` (TO READ; "Route updated by Red Sea Express" with "OK" and "View what changed")
- R26b What changed `6410:54554` — sheet `…54614` (TO READ; list of Added / Removed / Route now 4 stops changes + "Got it")
- R27 Next stop details `6410:54646` — sheet `…54685` **READ**
- R28 Trying to reach customer `6410:54868` — Contact steps `…54893` (TO READ; call log + "Call again" / "Message" + "Mark as couldn't deliver")
- R29 More options `6410:54920` — sheet `…54973` (TO READ; "Try again later", "Deliver a different stop next", "Report wrong location", "Get help", "Close")
- R30 Stop moved to later `6410:55006` — Toast `…55066` (TO READ)
- R31 Help `6410:55070` — sheet `…55130` (TO READ; "Need help?": Call dispatch, Message dispatch, Take a break, Vehicle problem, "I feel unsafe", Close)
- R33 Location sharing stopped `6410:54709` — sheet `…54768` **READ**
- R34 Back from Google Maps `6410:54777` — Resume card `…54836` (TO READ; "Welcome back" + "I've arrived" / "Resume")
- R35 Lock screen, ongoing route `6410:54848` — Android ongoing notification `…54852` (TO READ; "Stop 2 of 3 · Lina Fares" with Open / Navigate actions; implement as a foreground-service notification, not a Flutter screen)

**E. Depot return**
- R40 Returning to depot `6410:55252` (Return trip `…55293`); R40b Hand back at depot `6410:55308` (Hand back `…55332`); R41 Arriving (auto-detect) `6410:55344` (`…55381`); R42 Left without marking `6410:55393` (Unmarked stop `…55435`); R43 Check your packages `6410:55447` (Load check `…55500`, "Are all 3 packages in the van?"); R44 On break `6410:55529` (`…55558`, timer, "Resume route" / "Add 5 minutes"); R45 Report wrong location `6410:55569` (Draggable pin `…55590`, Hint `…55595`, Report location `…55597`: "What's wrong with the pin?" with "Send to dispatch")
  — all TO READ

**F. Proof of delivery**
- P01 / P01b / P01c photo, per stop `6410:55615` / `55669` / `55723` — full-screen camera with Close button, "Stop 1 · Omar Haddad"-style tag, framing guide, hint "Show the package and the door number", and a white bottom camera panel with a shutter button (TO READ; use the `camera` plugin or `image_picker` already in pubspec, and say which you pick)
- P02 / P02b / P02c check photo `6410:55646` / `55700` / `55754` — "Looks good?", the captured photo, "Use photo" (lime) and "Retake"
- P03 signature `6410:55777`; P03b typed signature `6410:55805` — "Ask Ahmed to sign", Draw / Type segmented control, signature pad, "Signed by" field, "Done · mark delivered" and "They can't sign"
- P04 customer can't sign `6410:55833` — sheet `…55862` over a Scrim: "Why can't they sign?" with options (They refused to sign / Hands are full or they can't use the phone / Left with the building guard / Something else) and a lime "Mark delivered with photo only", plus "Back to signature"
  — P-series all TO READ

## 6. Flow (derived from frame order and names; prototype links were not available through the MCP, so confirm the transitions in Figma Prototype mode before wiring)

1. Route tab → R00 loading → R01 (no route) **or** R02 planning → R03 ready → (R04 if location permission is missing, then back to R03).
2. R03 "Slide to start route" → R10 driving to stop 1 → R11 (≈ under 150 m) → R12 arrived.
3. R12 "Delivered" → photo (P01) → check photo (P02) → [last stop only: signature P03 / P03b, or P04 fallback] → R13 toast "Delivered · Name — Undo" → R14 driving to stop 3 → R15 → … → R17 → R18 → R19 route complete.
4. R12 "Couldn't deliver" → R16 reason sheet → "Send to Red Sea Express" → back to driving to the next stop. "More" → R29. "Note" → note editor.
5. While driving: stops control → R21; "End route early" → R22; app chooser (maps button) → R20; "?" → R31; overview recenters; banner tap → R27.
6. System states overlay the driving screens: R23 rerouting, R24 weak GPS, R25 offline, R33 location stopped, R26 route changed → R26b, R30 stop moved later, R34 return from an external maps app, R35 notification.
7. After the last delivery: R40 → R40b / R41 → R42 / R43 → R19. R44 break and R45 report-location can be opened from help/more.

## 7. Deliverables and process

1. First reply: a short plan listing (a) what already exists and matches, (b) what exists but differs from Figma, (c) what is new. Include the new files you intend to create.
2. Build in this order: shared components (section 3) → B → C → D → E → F. After each group, run `flutter analyze` and fix issues, and stop for review.
3. Add the cubit states/events for the new flow (`route_fleet_state.dart`, `route_fleet_cubit.dart`, or a new dedicated cubit if the existing one gets too big). Keep the domain layer free of Flutter imports.
4. Final report: files created or changed, new ARB keys (flag the Arabic drafts), assets added, screens verified against Figma and how, anything you skipped, and every design inconsistency you hit (font differences, missing states, unclear transitions).
