# route_spec_R16_R28_R19: Couldn't deliver, Trying to reach customer, Route complete (plus R17/R18 variants)

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, 412 x 917 each (R19 scrolls).
| Frame | Node | Content |
|---|---|---|
| R16 | `6410:53783` | "What happened?" reason sheet over the arrival screen |
| R28 | `6410:54868` | "Trying to reach {customer}" contact steps |
| R17 | `6410:53859` | driving to the last stop, with a toast |
| R18 | `6410:53925` | arrived at the last stop |
| R19 | `6410:55185` | Route complete (scrollable page) |

Read via Figma MCP (design context + Plugin API read-only). Font: Figma uses Satoshi in R19 and R16 text, Plus Jakarta Sans in R28; the project keeps **Satoshi** (map weights 1:1, including Satoshi **Black**, which exists in pubspec). Tokens, sheet container, buttons and text styles come from the earlier specs; this file lists what is new. Frame names are one stop behind the content (see R12/R13 spec); build from the content, data-driven.

## 1. R16: What happened? (reason sheet)

Same pattern as R20 to R22: the arrival screen is underneath, with a scrim and a modal sheet.
- **Underneath:** the arrival screen (chip "You've arrived" at (125,64) and the Arrival sheet, 360 x 276 at y615, for stop 2: **no company note**, so it is shorter than the 331 high sheet of R12). Map: World (-334,-360), puck (174,388) heading rotated -90 (left). Stops: stop 1 **delivered** (`#EEF9DA`, check), stop 2 **current** (lime `#8FE600`, 3px white stroke, number), stop 3 upcoming (white, 2px `#CFCFCF`). Route line: traveled 160 x 240, upcoming 160 x 140 (same 5 layers as R11).
- **Scrim:** full screen, `#FFFFFF` at 55% (same as R20 to R22).
- **Reason sheet** (360 x 510 at (26,377), bottom at 887): standard sheet container (padding 24, column gap 16). Content is the same as in the earlier read:
  - Title "What happened?" Bold 24 / h1.2 / ls -0.24 `#222222`; subtitle "{customer} · {company} will review this order." Regular 14 / h1.45 `#737373`.
  - **2 x 2 grid of tiles** (gap 10, each radius 18, padding 14, height 104, icon 24 over a Bold 14 / h1.4 label): **Customer not answering** (icon call), **Wrong address** (location pin), **Customer refused** (icon cancelled), **Can't reach location** (icon navigate). Selected tile: fill `#F0FAEC`, 2px `#8FE600`; others white, 1px `#D0D0D0`. In the frame "Customer not answering" is selected.
  - **Note field**: fill `#E9E9E9`, 1px `#D0D0D0`, radius 6, padding 14 x 12: label "Add a note (optional)" Medium 12 `#737373`, value 14 Regular `#222222` (text input).
  - **Send to {company}**: lime, radius 8, height 56, Bold 16.
- **Navigation (prototype):** tile "Customer not answering" -> **R28**; **Send to Red Sea Express -> R17** (next stop). The other tiles have no link (local selection). The reasons come from data (reason codes).

## 2. R28: Trying to reach {customer} (sheet, no scrim)

No scrim here. Map and chip as R16 (puck rotated -90, same route); the Arrived chip is 152 wide (R16: 156), so its text is probably different ("not read": the chip text/icon).
- **Contact steps sheet** (360 x 476 at (26,417)): standard sheet container, padding 24, column gap 12:
  1. Overline "STOP 2 OF 3 · LINA FARES": Bold 10 / h1.35 / ls +1.2, `#737373`, uppercase.
  2. Title "Trying to reach Lina": Bold 26 / h1.12 / ls -0.52 `#222222`.
  3. **Wait timer** (row, gap 16, centered): ring 72 x 72 + text. Ring: a grey track `#D0D0D0` and a lime `#8FE600` arc for the remaining/elapsed part (arc starts at the top; about 65% of the ring is lime in the frame), center text "2:14" ExtraBold 17 `#222222` (the time left of the 5-minute wait). Text beside it (width 224): "Wait a few more minutes before marking this stop. Red Sea Express asks for 2 calls and a 5-minute wait." Regular 13 / h1.45 `#737373`. The numbers (2 calls, 5 minutes) come from company rules (data).
  4. **Contact log** box: fill `#F5F6F2`, 1px `#D0D0D0`, radius 16, padding 14 x 6. Rows (py 8, space-between): left label SemiBold 14 `#222222` ("Called", "Called", "Message sent"), right Regular 13 `#737373` ("10:21 · no answer", "10:23 · no answer", "10:23").
  5. **Actions** (row, gap 10, equal widths, height 52, white, 1px `#D0D0D0`, radius 8, Bold 16): **Call again**, **Message**.
  6. **Mark as couldn't deliver**: full width, height 52, fill `#FFECE5`, 1px `#FF3D00`, radius 8, label Bold 16 `#FF3D00`.
  7. Footnote "Available after the 5-minute wait": Medium 12 `#737373`, centered.
- The button looks enabled in the frame while the footnote says it is only available after the wait. **The disabled style is not drawn:** ask the designer; assume disabled (reduced opacity) until the timer ends, and make that one rule in one place.
- **Navigation (prototype):** Mark as couldn't deliver -> R17. Call again / Message: no link (TODO: dial, open messaging).

## 3. R17: Driving to the last stop (variant of R10 with a toast)

Same components as R10: Maneuver banner (with "Then" strip), Map controls, Trip sheet. Differences:
- Banner: "40 m", "Turn left onto Hira St", Then "Prince Sultan St". Icon turn-left.
- **Toast** at (55,214), 298 x 42 (under the banner; width hugs its content, centered): text **"Sent to Red Sea Express for review"** (Bold 14). Same toast widget as R13 (white pill, 1px `#D0D0D0`, shadow `0 6 20`), but without the "Undo" part; the leading icon is **not read** (the R13 icon is `icon/delivered`).
- **Map controls at y = 280** (R10: 250; R11: 190): the controls sit lower because of the toast. Use the top offset from the spec per state.
- Trip sheet: "10:41 arrival", "5 min", "0.9 km"; badge "3"; "Ahmed Ali"; "Prince Sultan St, Al Rawdah · #RX-1042".
- Map: World (-394,-236), puck (174,468) heading 0, traveled 160 x 284, upcoming 160 x 96. Stops: stop 1 delivered (check), **stop 2 failed**: fill `#FFECE5`, 3px white stroke, an icon inside (probably the red X; the child is a frame: not read), stop 3 current (lime, "3").
- New marker state: **failed** (fill `#FFECE5`). The delivered marker is `#EEF9DA` with a check `#2F9E44` (see R12/R13 spec).

## 4. R18: Arrived at the last stop (variant of R12)

- Chip "You've arrived" (125,64, 156 x 40), Arrival sheet 360 x 276 at y615 (no company note: the sheet is shorter).
- Header: **"LAST STOP"** (replaces "STOP n OF N") and "Arrived 10:41". Name "Ahmed Ali", "Prince Sultan St, Al Rawdah · #RX-1042". Quick actions (Call, Note, Maps, More) and the outcome buttons (Couldn't deliver, Delivered).
- Map: World (-234,-220), puck (174,388) heading 0 (pointing up). Only the **traveled** path is drawn (160 x 380); there is no upcoming path (last stop). Stops 1 delivered, 2 failed (`#FFECE5`), 3 current (lime).
- The company note appears only if the data has one (so the sheet is 276 or 331 high).
- Navigation: Delivered -> P01c (photo, then signature, see the P01 to P04 spec); Couldn't deliver -> R16; Maps -> R20; More -> R29.

## 5. R19: Route complete (scrollable page)

A full page (no map), background `#FDFDFD`, content scrolls (a marker at y=1133 shows the scroll end; the frame is 412 x 1048). Bottom actions scroll with the content (they sit at y=915 and y=975, below the frame fold on small devices).
Layers (x26, width 360):
1. **Date** (y72): "SUNDAY, 11 OCTOBER" Bold 11 / h1.35 / ls +1.2 `#737373` (from the current date).
2. **Title** (y90): "Route complete" Bold 38 / h1.05 / ls -1.14 `#222222`.
3. **Subtitle** (y142): "You're almost done, Hamza. One thing left." Regular 15 / h1.35 `#737373`. Driver name from data. The text changes when nothing is left to do (not read).
4. **To-do card** (y178, 360 x 234): standard card (fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 24, sheet shadow), column gap 10:
   - Overline "1 THING LEFT" Bold 10 / ls +1.2 in amber `#C27C00`.
   - Title "Return Lina's package to the depot" Bold 20 / h1.25 / ls -0.3 `#222222` (width 312).
   - Meta "Red Sea Express hub, Al Rawdah · 3.1 km away" Regular 13 `#737373`.
   - Spacer 6, then the button **Directions to depot**: lime `#8FE600`, **radius 6**, height 56, padding left 24 right 20, label Bold 16 `#222222` on the left and an arrow icon 16 x 12 on the right (space-between).
   - The card appears **only if there are packages to return** (data). Otherwise the page moves up (not read).
5. **Outcome** (y452, row, gap 20): a **donut chart 104 x 104** (lime arc for delivered, red-orange arc for failed, rounded caps, a thin gap between arcs; draw it with a CustomPainter from the counts; the exact colors and stroke width are in the donut SVG: read them from the export, the red looks like `#D93400`) and a text column (gap 8): "2 of 3 delivered" Satoshi **Black** 26 / h1.1 / ls -0.65 `#222222`; legend rows (dot 8 + text Medium 14 `#737373`, gap 8): lime dot "2 delivered", red dot "1 couldn't deliver".
6. **Metrics** (y584, row, gap 40): each is a value (Black 24 / h1.1 / ls -0.48 `#222222`, with a unit Bold 14 `#737373` baseline-aligned, gap 4) over a label Medium 13 / h1.35 `#737373` (gap 2): "14.2 km / Driven today", "52 min / On the road".
7. **Divider** (y658): 1px `#D0D0D0`.
8. **Stops list** (y682): overline "STOPS" Bold 10 / ls +1.2 `#737373`; then one row per stop (py 12, gap 12, centered), separated by 1px `#D0D0D0` dividers:
   - Status icon 30 x 30: **delivered** = lime circle with a check; **failed** = `#FFECE5` circle with a red X (exported SVGs).
   - Text column: name Bold 15 / h1.35 `#222222`; status line Regular 13 `#737373` ("Delivered"), or for failed in red `#FF3D00`: "{reason} · sent for review" ("Customer not answering · sent for review").
   - Time at the end: Medium 13 `#737373` (10:05, 10:24, 10:43).
9. **Done** (y915): lime, **radius 12**, height 56, Bold 16 `#222222`.
10. **See in history** (y975): text button, height 48, centered, Bold 14 `#222222`.
- Navigation (prototype): **Directions to depot -> R40**; **Done -> Home tab**. "See in history": no link (TODO: history). Reached from: R22 End route, and P03/P03b/P04 (last delivery done).
- All values (counts, distance, duration, stops, reasons, times, driver name, depot name and distance) come from the route data. The distance, time and the return-package task need the summary from the route data layer: define a summary entity.

## 6. New tokens, styles and assets
- Marker state **failed**: fill `#FFECE5` (existing danger surface token) with an icon.
- Satoshi Black styles: Black 26 / h1.1 / ls -0.65; Black 24 / h1.1 / ls -0.48. Other dedicated styles: Bold 38 / h1.05 / ls -1.14; Bold 11 / ls +1.2; Bold 10 / ls +1.2 (also amber via copyWith); Bold 20 / h1.25 / ls -0.3 (note: different letter spacing from the -0.1 style); ExtraBold 17 (timer); Bold 15 / h1.35; Medium 13 / h1.35; Regular 13 / h1.45. Do not change existing styles.
- Colors: amber `#C27C00` (exists after the P01 to P04 work), danger `#FF3D00` / `#D93400` / `#FFECE5` (exist), `#2F9E44`, `#EEF9DA` (exist).
- SVG assets: icon-arrow (R19 button), outcome donut colors, status icons (delivered, failed), call/cancelled/location/navigate icons for the tiles, timer ring (draw with CustomPainter).

## 7. NOT READ / open items
1. R28: the Arrived chip text/icon (152 wide), the disabled style of "Mark as couldn't deliver", what Call again / Message open, and the timer arc direction (elapsed or remaining) and update rule.
2. R17: the leading icon of the toast, the icon inside the failed marker, and how long the toast stays.
3. R19: what the page shows when there is nothing to return, the "history" destination, the donut stroke/colors (from the SVG), and the empty/zero cases (0 failed, 0 delivered).
4. R14 (driving to stop 3) and R15 (arrived stop 3) were not read here; they are expected to be R10/R12 with other data (check them against Figma when implementing).
5. Motion: toast, donut animation, sheet enter/exit.
6. R16: the "Customer not answering" tile opens R28 in the prototype, but "Send to company" also exists on the same sheet. Confirm the real rule: does choosing that reason always open the contact steps first (call twice and wait 5 minutes), and only then allow sending?
