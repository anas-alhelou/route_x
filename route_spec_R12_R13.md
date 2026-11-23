# route_spec_R12_R13: Arrived · Delivered (undo)

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`.
- R12 "Arrived · stop 2": frame `6410:53571`, 412 x 917
- R13 "Delivered · undo": frame `6410:53626`, 412 x 917
Read via Figma MCP (design context + Plugin API read-only). Font: Figma uses Plus Jakarta Sans, the project keeps **Satoshi** (map weights 1:1). Tokens and container styles are the same as `route_spec_R10.md` and `route_spec_R11.md`. This file only lists what is new.

⚠ **Naming inconsistency in the design (ask the designer):** the frame is called "R12 · Arrived · stop 2", but the sheet says "STOP 1 OF 3", the customer is Omar Haddad (stop 1) and the map marker highlighted as current is stop 1. R13 then says "Delivered · Omar Haddad" and "NEXT STOP 2 · Lina Fares". So the content is the arrival at **stop 1**. Implement from the content (data-driven), not from the frame name.

## 1. Shared map layer (R12 and R13 are identical)

World offset (-314, -520), puck frame at (174, 388) 64 x 64 (so the puck center is at (206, 420), higher than in R10/R11 because the sheet is taller).
- Driver puck: same structure as R11 (accuracy 64 `#3B6EE0` 14%, base 34 white with shadow, heading arrow `#3B6FE0` rotated 90 degrees, i.e. pointing left).
- Route line: traveled segment 80 x 80 (`#FFFFFF` 12 + `#B8BDB2` 6), upcoming 160 x 300 (`#FFFFFF` 14 + `#6FC000` 9 + `#8FE600` 6). Same layers as R11 section 5 of `route_spec_R11.md`.
- Stop markers (38 x 38):
  - **R12:** stop 1 current: `#8FE600`, 3px white stroke, number "1" `#222222`; stops 2 and 3: white, 2px `#CFCFCF`.
  - **R13:** stop 1 **delivered**: fill `#EEF9DA`, 3px white stroke, same shadow, **no number**; a check mark instead: a 16 x 16 frame at (11,11) with a vector 10.67 x 7.33 at (2.67,4), stroke `#2F9E44` 2.13, no fill. Stops 2 and 3 stay white with `#CFCFCF`, numbers 2 and 3 (stop 2 is not highlighted yet in R13).
- New tokens needed: delivered marker fill `#EEF9DA`, check stroke `#2F9E44`.
- No Map controls and no Maneuver banner in R12 and R13. No bottom nav.

## 2. R12 layers

| Layer | Node | x | y | w | h |
|---|---|---|---|---|---|
| World | 53572 | -314 | -520 | 900 | 1500 |
| Driver puck | 53586 | 174 | 388 | 64 | 64 |
| Status bar | 53591 | 0 | 0 | 412 | 52 |
| Arrived chip | 53592 | 125 | 64 | 156 | 40 |
| Arrival sheet | 53595 | 26 | 562 | 360 | 331 |

- Arrival sheet bottom is at y = 893 (R10/R13 sheets end at 891). A 2 px difference in the design; use the same bottom offset rule as the other sheets and list it as a deviation if it differs.

### Arrived chip (node 53592, 156 x 40)
White pill, radius 100, padding 16 x 10, gap 8, shadow `0 4 16 rgba(31,36,26,0.12)`. `icon/arrive` 18 x 18 (flag) + "You've arrived" Bold 14, h1.4, `#222222`. Horizontally centered. It shares the chip style with RouteSummaryChip.

### Arrival sheet (node 53595, 360 x 331)
Container: fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 24, column gap 14, sheet shadow. Inner layers (x25):
1. **Header row** (y25, h17, space-between): "STOP 1 OF 3" Bold 10, h1.4, letter spacing +0.6, `#737373`, uppercase. On the right `icon/eta` 16 x 16 + "Arrived 10:05" Medium 12 / h1.45 `#737373`, gap 6.
2. **Name block** (y56, h50, gap 2): "Omar Haddad" Bold 26 / h1.2 / ls -0.52, `#222222`; below "Sari St, Al Zahra · #RX-1039" Regular 12 / h1.45, `#737373`.
3. **Quick actions** (y120, h63): 4 equal tiles, gap 10, each fill `#E9E9E9`, radius 8, padding 8 x 10, column gap 4, centered: icon 22 x 22 + label Medium 12 / h1.45 `#222222`.
   - **Call** (`icon/call`), **Note** (`icon/note`), **Maps** (`icon/navigate`), **More** (`icon/stops`).
4. **Company note** (y197, h39): fill `#F5F6F2`, 1px `#D0D0D0`, radius 6, padding 12 x 10, gap 8, items start. `icon/note` 16 x 16 + text Regular 12 / h1.45 `#222222` ("Call when you arrive. Building 12, 3rd floor."). Shown only if the data has a company note.
5. **Outcome buttons** (y250, h56, gap 10, equal widths):
   - **Couldn't deliver**: white fill, 1px `#D0D0D0`, radius 8, height 56, label Bold 16 / h1.4 `#222222`.
   - **Delivered**: fill `#8FE600`, radius 8, height 56, `icon/delivered` 24 x 24 + gap 8 + label Bold 16 `#222222`.
- Icons to export as SVG: `icon/arrive` (6280:8539), `icon/eta` (6280:8542), `icon/call` (6280:8535), `icon/note` (6280:8545), `icon/navigate` (6238:10645), `icon/stops` (6280:8529), `icon/delivered` (6280:8549).

### Prototype for R12 (from Figma reactions)
- Maps tile -> R20, More tile -> R29, Couldn't deliver -> R16, **Delivered -> P01 (photo)**. Call and Note have no link (TODO).
- Arrival at R12 is also reachable from R11 (after 2.5 s in the demo; in the real app it is the arrival detection), R41, R34, R45, P01 Close, R29 Close, R42 Go back.

## 3. R13 layers

| Layer | Node | x | y | w | h |
|---|---|---|---|---|---|
| Driver puck | 53642 | 174 | 388 | 64 | 64 |
| Toast | 53648 | 57 | 64 | 294 | 42 |
| Trip sheet ("next stop") | 53653 | 26 | 656 | 360 | 235 |

### Toast (node 53648, 294 x 42)
White pill, 1px `#D0D0D0`, radius 100, padding 16 x 10, gap 10, shadow `0 6 20 rgba(31,36,26,0.12)`. `icon/delivered` 20 x 20, "Delivered · Omar Haddad" Bold 14 `#222222`, a divider 1 x 18 `#D0D0D0`, "Undo" Bold 14, `#4A7A00`. Horizontally centered. **Undo** reverts the delivery (the data layer needs an undo of the stop status; the prototype has no link for it, so it stays a callback/TODO).

### Next-stop sheet (node 53653, 360 x 235)
Container as other sheets (padding 24, gap 14).
1. Overline "NEXT STOP": Bold 10 / h1.4 / ls +0.6, `#737373` (uppercase), y25 h14.
2. Row (y53, h42, gap 12, centered): badge 40 x 40 circle (radius 20) `#8FE600` with the number "2" Bold 14 / h1.4 `#222222`; text column: name "Lina Fares" Bold 20 / h1.25 / ls -0.1 `#222222`; below "Tahlia St, Al Nahda · 6 min · 1.4 km" Regular 12 / h1.45 `#737373`.
3. **Auto-advance** (y109, h31, gap 8): a track 6 high, fill `#D0D0D0`, radius 3, full width 310; inside a countdown bar 6 high, `#8FE600`, radius 3, width 230 of 310 (74%) in this frame; below it "Starting directions in 3 s" Medium 12 / h1.45 `#737373`.
   - The bar shrinks or grows with the countdown (3 s). In the frame it is at 230/310 with "3 s". **Direction (filling vs emptying) and the exact timing are not in the static frame; ask the designer.**
4. **Go to next stop** button (y154, h56): fill `#8FE600`, radius 8, `icon/navigate` 22 x 22 + gap 8 + label Bold 16 / h1.4 `#222222`.

### Prototype for R13
- After 3 s (demo timer, matches the "Starting directions in 3 s" text) and on "Go to next stop" -> R14 (driving to stop 3... the frame names say stop 3, the content is stop 2: same naming issue).
- R13 is reached from P02 "Use photo" (stop 2 flow in the prototype), after the photo.

## 4. Existing code to reuse / compare
- Reuse: chip style (RouteSummaryChip), sheet container (TripSheet), badge (StopRow), primary and secondary buttons, Toast needs a new widget.
- New widgets: ArrivedChip (or generalize the chip), ArrivalSheet (4 quick-action tiles, company note, outcome buttons), DeliveredToast, NextStopSheet with the countdown bar.
- New state(s): arrived (stop index, arrival time, company note), delivered (toast with undo, next stop, auto-advance countdown). Data-driven: names, addresses, order ids, times, the company note, "STOP n OF N" and the next-stop meta (time and distance) all come from data.

## 5. NOT READ / open items
1. Motion: toast enter/exit, countdown animation, chip appearance. Not in static frames.
2. Map camera for R12/R13: the puck is at y = 420 center (not 500), because the sheet is taller. Our "follow the driver at y≈500" deviation needs a rule for sheet height; list as an open question.
3. Heading in R12/R13 is the same as R11 (rotated 90 degrees).
4. The frame naming (stop 2 vs stop 1) and the sheet bottom offset (893 vs 891).
5. What the Call and Note tiles open (call the customer, note editor): no prototype link.

## 6. Corrections after visual check against Figma (screenshots of R12 and R13)

1. **Stop 1 is not under the puck.** In the Figma renders, the stop 1 marker sits about 80 px left of the puck and about 160 px below it (screen center near (125, 580) of 412 x 917), just above the sheet in R13 and partly behind the sheet top in R12. The puck (206, 420) has already moved on. So the test data for R12/R13 must place stop 1 near that position, not on the puck, so the delivered marker in R13 is visible. The earlier statement "puck on top of the stop 1 marker" only means the puck layer is above the markers.
2. **Delivered marker look in R13:** a white-ringed circle with a pale-green fill (#EEF9DA) and a small check mark (#2F9E44 vector, 10.67 x 7.33). It is small; verify at device scale.
3. **Countdown (inferred from the static frame, confirm with the designer):** in R13 the bar is filled 230/310 (74%) while the label says "3 s". That is consistent with a bar that **empties** over 3 s with the label = ceil(remaining seconds) (remaining about 2.2 s shows 3 s). Use ceil for the label, not round.
4. **Route in R12/R13:** the upcoming (lime) path goes from the puck left, then up, then right to stop 2, then up to stop 3 (an L-shaped street path). The traveled grey segment goes from the puck to the right and then down. With real data this comes from the route geometry; with test data keep the 3 + 2 stroke layers and make both paths visible.

## 7. Correction to section 6 point 1 (found in the R40 to R42 images)
The marker seen about 80 px left of and 160 px below the puck in R12/R13 (screen center near (125,580)) is **not stop 1**. It is the **depot marker**: a white ring (about 41 px outside) with a pale-green dot (about 20 px) inside, shown on all the driving frames at the same map position. So in R12/R13 **stop 1 (current in R12, delivered in R13) is under the puck**, as it was before the "move stop 1" correction. What to do: put stop 1 back at the puck position in the R12/R13 test data and add the depot marker at that map position (see route_spec_R40_R40b_R41_R42.md, section 1). The delivered check of stop 1 in R13 is then hidden by the puck, which matches the Figma render.
