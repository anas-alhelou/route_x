# route_spec_R20_R21_R22: Navigate with, Today's route, End route now?

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, 412 x 917 each.
- R20 "Navigate with…": frame `6410:53976` (sheet node `6410:54036`)
- R21 "All stops": frame `6410:54079` (sheet node `6410:54139`)
- R22 "End route?": frame `6410:54410` (sheet node `6410:54470`)
Read via Figma MCP (design context + Plugin API read-only). Font: Figma uses Plus Jakarta Sans (R22 and R27 partly use Satoshi), the project keeps **Satoshi** (map weights 1:1). Tokens, sheet container, buttons and text styles come from `route_spec_R10.md`. This file lists what is new.

## 1. Shared layout of the three screens

All three are the **R10 driving screen underneath** (same World offset (-394,-504), puck at (174,468) heading 0, same route line, stop 1 lime, stops 2 and 3 white) with a **scrim** and a **modal sheet** on top.

| Layer | x | y | w | h |
|---|---|---|---|---|
| Maneuver banner (as R10, with "Then" strip) | 26 | 56 | 360 | 127 |
| Map controls | 348 | 250 | 48 | 106 (see note) |
| Trip sheet (driving, as R10) | 26 | 722 | 360 | 169 |
| **Scrim** | 0 | 0 | 412 | 917 |
| **Sheet** R20 "Navigate with" | 26 | 378 | 360 | 515 |
| **Sheet** R21 "Stops" | 26 | 459 | 360 | 434 |
| **Sheet** R22 "End route?" | 26 | 516 | 360 | 377 |

- **Scrim:** a full-screen rectangle, fill **`#FFFFFF` at 55% opacity** (white, not dark), covering the banner, controls and trip sheet. The scrim blocks taps on what is behind it. Tapping outside the sheet is **not defined** in the prototype (no reaction on the scrim). Ask the designer.
- Each sheet is anchored to the bottom: bottom edge at y = 893 (24 from the screen bottom), height depends on the content (hug content). The sheet container is the standard sheet (fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 24, sheet shadow). Keep your bottom-offset decision (safe area + 32) and list it as an intentional deviation.
- Note: the Map controls node is **106 high** here (two circles, 48 + 10 + 48), while R10 has 164 (three circles). It sits under the scrim, so it is hardly visible. Not read: which two controls remain. Follow R10 (three controls) and list it as an open question.
- The three modals open from the driving screens (R10/R11/R14/R17...); the screen underneath is whatever driving state is active, not a fixed R10.

## 2. R20: Navigate with (sheet 360 x 515, column gap 14)

1. **Header** (gap 4): title "Navigate with" Bold 20 / h1.25 / ls -0.1, `#222222`; subtitle "Pick how you want directions to Omar Haddad." Regular 14 / h1.45, `#737373`. The name comes from the current stop.
2. **Apps list** (column gap 8), 3 rows, each: padding 14 x 12, gap 12, items centered, radius 12, full width:
   - **Logo tile** 40 x 40, fill `#FFFFFF`, 1px `#D0D0D0`, radius 12, centered logo.
   - **Text** (flex 1): name Bold 14 / h1.4 `#222222`; description Regular 12 / h1.45 `#737373`, single line.
   - **Radio** 22 x 22 circle at the end.
   - Row 1 **RouteX** (selected): fill `#F0FAEC`, border 2px `#8FE600`; description "Turn-by-turn inside the app"; logo = an "R" in the brand font (Monument Extended, 20, line height 22, `#222222`); radio selected = white fill with a 6px `#8FE600` ring (radius 11).
   - Row 2 **Google Maps** (unselected): fill `#FFFFFF`, border 1px `#D0D0D0`; description "Opens one stop at a time"; logo = Google Maps icon 24 x 24 (`gcp:google-maps-platform`); radio unselected = white fill, 2px `#D0D0D0` ring.
   - Row 3 **Waze** (unselected): same as Google Maps; logo = Waze icon 20 x 20 (`selfhst:waze`).
   - Do not add the Monument Extended font. Reuse the existing RouteX logo widget/asset (`routex_logo.dart`) or export an SVG, and ask me if neither fits.
   - Selecting a row is local state (no navigation in the prototype). Which apps appear should come from data (installed apps / user settings), not hardcoded.
3. **Always use this app** row (space-between, centered): label Medium 14 / h1.45 `#222222`, and a switch 52 x 32: track fill `#8FE600` (the ON state in the frame), knob white circle 26 x 26 at (23,3) (right side). OFF state is **not read** (assume grey track `#E9E9E9` and knob on the left; confirm). Use a custom switch, not the Material default colors.
4. **Hand-off note** box: fill `#F5F6F2`, 1px `#D0D0D0`, radius 12, padding 12 x 10, gap 8, items start. `icon/note` 16 x 16 + text Regular 12 / h1.45 `#222222` "Come back to RouteX to mark each stop as delivered." Shown for external apps. It is visible in the frame with RouteX selected; **whether it hides when RouteX is selected is not read**.
5. **Button "Start directions"**: lime `#8FE600`, radius 8, height 56, `icon/navigate` 22 x 22 + gap 8 + label Bold 16 / h1.4 `#222222`.
- Navigation: **Start directions -> R10** (driving screen). Rows and switch: local state only.

## 3. R21: Today's route (sheet 360 x 434, column gap 14)

1. **Header** (space-between): "Today's route" Bold 20 / h1.25 / ls -0.1 `#222222`; "0 of 3 done" Medium 12 / h1.45 `#737373`.
2. **Progress bar**: 3 equal segments, 6 high, radius 3, gap 4. Done segments `#8FE600`, remaining `#E9E9E9`. In the frame: 1 lime, 2 grey (the current stop segment is lime while "0 of 3 done"; so the lime segment marks the **current** stop, not the done count). Confirm the rule (done + current).
3. **Stops list** (column gap 6), 3 rows:
   - **Current stop** row: fill `#F0FAEC`, border 1px `#8FE600`, radius 12, padding 12, gap 12. Badge 32 circle `#8FE600` with number (Bold 12 `#222222`); name Bold 14 / h1.4, address Regular 12 `#737373` ("Sari St, Al Zahra"); on the right "En route · ETA 10:05" Medium 12 / h1.45 in `#8FE600` (the lime-on-light low contrast is as designed).
   - **Upcoming rows**: no fill/border, radius 16, padding 12, gap 12. Badge 32 circle `#E9E9E9` with number; name + address; ETA at the end ("ETA 10:24", "ETA 10:41") Medium 12 `#737373`.
   - Done-stop row style is **not read** (no delivered stop in this frame).
4. **Back to directions**: secondary button (white, 1px `#D0D0D0`, radius 8, height 56, Bold 16 `#222222`).
5. **End route early**: text button, no fill, radius 16, height 44, label SemiBold 15 / h1.4 `#D93400`.
- Navigation: **Back to directions -> R10**, **End route early -> R22**. The stop rows have no reaction in the prototype.

## 4. R22: End route now? (sheet 360 x 377, column gap 14)

1. Title "End route now?" Bold 26 / h1.12 / ls -0.52 `#222222`.
2. Body: "You still have 2 stops. Their orders go back to Red Sea Express so they can be reassigned. This can't be undone." Regular 14 / h1.4 `#737373`. The numbers and the company name come from data.
3. **Danger box** ("Stops left"): fill `#FFECE5`, border 1px `#FF3D00`, radius 12, padding 14 x 12, column gap 8. One line per pending stop: "Lina Fares · Tahlia St, Al Nahda", "Ahmed Ali · Prince Sultan St, Al Rawdah", Medium 13 / h1.4 `#FF3D00`. List built from the remaining stops.
4. **Keep delivering**: primary lime button, radius 8, height 56, Bold 16 `#222222`.
5. **End route**: text button, radius 16, height 56, no fill, Bold 16 / h1.4 `#D93400`.
- Navigation: **Keep delivering -> R10**, **End route -> R19** (route complete). Ending the route is destructive: orders return to the company; keep the real action as a TODO in the data layer (no mock deletion).

## 5. New tokens / styles to check before adding
- Scrim color `#FFFFFF` at 55% (new, named).
- Danger colors: `#D93400` (status danger-text), `#FFECE5` (danger surface), `#FF3D00` (icons red). Check if they already exist.
- `#F0FAEC` (icons/brand) for the selected rows: check if it exists (it is used by SlideToStart track).
- Dedicated text styles: Bold 20 / h1.25 / ls -0.1 (also used in R12/R13), Bold 26 / h1.12 / ls -0.52, SemiBold 15 / h1.4, Medium 13 / h1.4, Regular 14 / h1.4. Do not change existing styles.
- Icons: `icon/note`, `icon/navigate`, Google Maps and Waze logos (24 / 20), RouteX logo.

## 6. Prototype summary
| From | Trigger | To |
|---|---|---|
| R20 | Start directions | R10 |
| R21 | Back to directions | R10 |
| R21 | End route early | R22 |
| R22 | Keep delivering | R10 |
| R22 | End route | R19 |
Opened from: R10/R11/R14/R17 (and other driving states) "open in maps" button -> R20; Stops control -> R21. R22 opens from R21 only.

## 7. NOT READ / open items
1. Scrim tap-to-dismiss and sheet drag behavior; sheet enter/exit motion.
2. Map controls in these frames (two circles, 106 high) vs three in R10.
3. Switch OFF state; whether the hand-off note hides when RouteX is selected.
4. Done-stop row style in R21; the progress rule (done vs current).
5. Where the app list comes from (installed apps, saved preference "Always use this app").
6. Sheet bottom at y = 893 in the frames (24 from the bottom) while the trip sheet is at 891; follow your bottom-offset decision and list it.
