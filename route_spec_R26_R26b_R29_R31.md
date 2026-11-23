# route_spec_R26_R26b_R29_R31: Route update, What changed, More options, Help

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`. Frames (412 x 917): R26 `6410:54480` (card `6410:54539`), R26b `6410:54554` (sheet `6410:54614`), R29 `6410:54920` (sheet `6410:54973`), R31 `6410:55070` (sheet `6410:55130`).

**Source of this spec: exported PNG images of the frames (not read through the Figma tools: the monthly MCP limit is exhausted).** Every size below was measured from the images (1 design unit = about 2.18 px in the images) and rounded; text sizes/weights were matched to the styles used in the earlier specs (the design is consistent). Everything is marked **(img)** when it is an estimate. Verify the exact values in Figma when the tool limit renews. The navigation comes from `route_flow_prototype.md` (read from the prototype, not from the images). Font: the project keeps **Satoshi**. Tokens, the sheet container, buttons and text styles come from the earlier specs.

## 0. Common to the four screens
- All four are **the driving screen (R10 look) or the arrival screen with one modal layer on top** (no new pages): R26, R26b and R31 sit over the driving screen (maneuver banner with "Then" strip, 2 map controls, trip sheet); R29 sits over the **arrival screen** (chip "You've arrived", the L-shaped route with stops 2 and 3, the puck).
- **R26b, R29 and R31 have a scrim.** In the images the screen behind the sheet looks **blurred and washed out** (not only a white 55% layer as measured in R20 to R22): the Figma scrim probably has a **background blur** effect. The earlier frames of R20 to R22 were only read for the fill (white 55%), so their blur was never checked. **Check the blur of the scrim layer in Figma** (`effects` of node `6410:54035`, `6410:54469`, `6410:54613`, `6410:54972`, `6410:55129`) and apply the same value on all scrims. If blur is confirmed, use `BackdropFilter(ImageFilter.blur)` plus the white 55% layer. (Unverified.)
- Sheets: standard container (fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 24, sheet shadow), x = 26, width 360, bottom edge at y ≈ 891 (24 from the bottom), height depends on content. Keep your bottom-offset decision.
- List rows pattern (R26b, R29, R31): a row = **36 x 36 icon tile** (radius 8 (img), fill `#E9E9E9`) at the start, a text column with **title SemiBold/Bold 16** `#222222` and an optional **subtitle Regular 14** `#737373`, a **1px `#D0D0D0` divider** between rows (none after the last one), row padding about 14 vertical, row height 64 to 68 (img). Icon inside the tile 22 x 22 (img).

## 1. R26: Route updated (card, no scrim)
- Underneath: R10 driving screen: banner "80 m / Turn left onto Sari St / Then Stop 1 is on the right", 2 map controls at (348,250), puck (206,500) heading 0, trip sheet "10:05 arrival, 4 min, 1.1 km, stop 1 Omar Haddad". Stops 1 (current lime) and 2 visible, route as R10.
- **Update card** at (26, ~519) (img), 360 x ~173 (img), between the banner area and the trip sheet (trip sheet at y 722). Standard sheet container, padding 24:
  - Row (gap 12, centered): tile 36 x 36, radius 8, fill **amber surface `#FFF3D6`**, with a **bell icon** (outline `#222222`, not in the exported icon set); text column: title **"Route updated by Red Sea Express"** Bold 16 (SemiBold in the image; use Bold 16 like the other titles) `#222222`; subtitle **"1 stop added. Your next stop hasn't changed."** Regular 14 `#737373`. Texts from data (the company name, the count of changes, whether the next stop changed).
  - Buttons (row, gap 10): **OK** (white, 1px `#D0D0D0`, radius 8, height 52, width about 100 (img)) and **View when stopped** (lime `#8FE600`, radius 8, height 52, flex: width about 198 (img)), label Bold 16 `#222222`. (the label may be written "View what changed" in some copies; the node name says "View when stopped": use the text in the image.)
- Navigation (prototype): **OK -> R10** (close the card); **View when stopped -> R26b** (opens What changed; it is meant for when the car is stopped: no rule drawn for blocking it while moving: open question); controls: Overview -> R03, Stops -> R21, Open in maps -> R20.

## 2. R26b: What changed (sheet + scrim)
- Underneath: the R26 screen (banner, controls, trip sheet) behind the scrim/blur; the update card is **not** shown (it closed).
- **Sheet** at (26, ~494) (img), 360 x ~397 (img), bottom at 891. Content:
  - Title **"What changed"** Bold 26 / h1.12 / ls -0.52 `#222222`.
  - Subtitle **"Red Sea Express updated your route at 10:12."** Regular 14 `#737373` (time from data).
  - Three rows (pattern in section 0):
    1. **"Added · Sara Khalid"** / "Quraish St, Al Salamah · now stop 3": tile fill `#F0FAEC` with a **box/package icon in lime** (use `ic_package.svg` with a lime color filter; the stroke looks `#8FE600`).
    2. **"Removed · Yousef Nasser"** / "Cancelled by the customer": tile fill `#FFECE5` with a **red "no entry" icon** (circle with a diagonal slash, red `#FF3D00`; `ic_cancelled.svg` has a grey slash, so this red single-color variant is **not exported**).
    3. **"Route now 4 stops"** / "About 6 min longer": tile `#E9E9E9` with a **clock icon with a dotted ring** (not exported; it may be `icon/break`/`icon/eta`).
  - Button **Got it**: lime, radius 8, height 52, Bold 16, full width.
- The rows come from the route diff (added / removed / reordered / totals): define a "route change" entity in the domain (type, customer name, address, reason or new position, time of update, new totals).
- Navigation: **Got it -> R10** (close the sheet).

## 3. R29: More options (sheet + scrim, over the arrival screen)
- Underneath: arrival screen: chip "You've arrived" at the top, route with stops 2 and 3, puck at about (206,420) heading left (as R12), behind the scrim.
- **Sheet** at (26, ~465) (img), 360 x ~426 (img). Content:
  - Title **"More options"** Bold 26 / h1.12 / ls -0.52.
  - Four rows (pattern in section 0, with a subtitle each):
    1. **Try again later** / "Move this stop to the end of your route": tile grey, `ic_history.svg`.
    2. **Deliver a different stop next** / "Pick which stop to go to now": tile grey, `ic_stops.svg`.
    3. **Report wrong location** / "The pin or address doesn't match": tile grey, `ic_pin.svg`.
    4. **Get help** / "Call or message Red Sea Express": tile **lime `#8FE600`**, `ic_call.svg` (the only row with a lime tile).
  - **Close**: white, 1px `#D0D0D0`, radius 8 (img: it looks 8 to 12), height 52, Bold 16 `#222222`, full width.
- Navigation (prototype): Try again later -> **R30** (and reorders the stop to the end: see the R30 spec); Report wrong location -> **R45**; Get help -> **R31**; Close -> **R12**. "Deliver a different stop next": no link in the prototype (TODO: stop picker).

## 4. R31: Need help? (sheet + scrim, over the driving screen)
- Underneath: R10 driving screen (banner with "Then" strip, 2 map controls, trip sheet), behind the scrim.
- **Sheet** at (26, ~384) (img), 360 x ~507 (img). Content:
  - Title **"Need help?"** Bold 26 / h1.12 / ls -0.52; subtitle **"Red Sea Express dispatch · usually answers in 2 min"** Regular 14 `#737373` (company and average answer time from data).
  - Five rows (pattern in section 0; the first three have **no subtitle**):
    1. **Call dispatch**: tile grey, `ic_call.svg`.
    2. **Message dispatch**: tile grey, `ic_note.svg` (document icon).
    3. **Take a break**: tile grey, clock-with-dotted-ring icon (**not exported**).
    4. **Vehicle problem** / "Breakdown, flat tyre, accident": tile grey, van icon (**not exported**).
    5. **I feel unsafe** (title in **`#D93400`**, danger text) / "Calls 999 and alerts dispatch": tile **`#FFECE5`** with a red package-with-X icon (**not exported**; subtitle stays gray).
  - **Close**: white secondary button as in R29.
- Navigation (prototype): **Take a break -> R44**; **Close -> R10**. No link on Call / Message / Vehicle problem / I feel unsafe (TODO: dial dispatch, message, report, emergency number; the emergency number 999 is regional: it must come from settings/data, not hardcoded).
- Opened from the Help "?" control (driving screens) and from R29 "Get help".

## 5. New tokens / styles / assets
- Colors: amber surface `#FFF3D6` (added for R23), `#F0FAEC`, `#FFECE5`, `#E9E9E9`, lime `#8FE600`, danger text `#D93400`, danger icon `#FF3D00` (exist).
- Text styles (dedicated; do not change existing ones): Bold 26 / h1.12 / ls -0.52 (exists), Bold/SemiBold 16 for row titles (use the existing Bold 16 / h1.4 style), Regular 14 (exists), Bold 16 button label (exists).
- **Icons not in the exported set (need export from Figma, or TEMP placeholders marked and listed):** bell (R26), clock with dotted ring (R26b, R31), van (R31), red package with X (R31), red "no entry" circle with slash (R26b). Available: `ic_history`, `ic_stops`, `ic_pin`, `ic_call`, `ic_note`, `ic_package`.

## 6. Assumptions and open items (all estimates come from the images)
1. The scrim blur (see section 0) and its exact fill/opacity.
2. Exact sheet heights and positions (y values are from the images), row heights (64 to 68) and icon tile radius.
3. R26: title weight (SemiBold vs Bold), the text of the second button ("View when stopped"), the behavior of "View when stopped" while the car is moving, and how long the card stays.
4. R26b: the tile icon colors (lime / red / grey) and whether the rows are tappable.
5. R29: "Deliver a different stop next" has no screen in the prototype (a stop picker); the exact radius of the Close button.
6. R31: the 5 actions have no prototype links except Take a break and Close; "I feel unsafe" needs a safety flow (not designed).
7. Motion and sheet enter/exit for all four.
