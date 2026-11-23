# route_spec_R23_R25_R30_R33_R34: System states over the driving screen

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, 412 x 917 each.
| Frame | Node | Content |
|---|---|---|
| R23 | `6410:54173` | Rerouting ("Finding a new way") |
| R24 | `6410:54227` | Weak GPS |
| R25 | `6410:54281` | Offline |
| R30 | `6410:55006` | Stop moved to later (toast) |
| R33 | `6410:54709` | Location sharing stopped (sheet on top) |
| R34 | `6410:54777` | Back from Google Maps (sheet on top) |

Read via Figma MCP (design context + Plugin API read-only + file metadata). The Figma tool-call limit was hit while reading, so some details are marked **NOT READ** (listed in section 7). Font: Figma uses Satoshi for R23, Plus Jakarta Sans for R33/R34/R30; the project keeps **Satoshi**. Tokens, banner/sheet/toast styles and text styles come from `route_spec_R10.md`, `R11`, `R12_R13` and `R20_R21_R22`; this file lists only what is new. All six screens are the **driving screen** (R10 look: map, puck at (174,468), same route line, stop 1 current) with one extra layer. They are states over the driving state, not new pages. Frame names are one stop off in places; build from the content.

## 1. R23: Rerouting ("Finding a new way")

- **State banner replaces the maneuver banner** at (26,56), 360 x 89 (same position as the maneuver banner; height 89 instead of 127; no "Then" strip). It is the same widget family as the weak GPS banner (already read in the R24 frame).
  - Container: fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 14, gap 12, items centered, sheet shadow `0 16 40 -8 rgba(34,34,34,0.12)`.
  - Left tile 52 x 52, radius 16, fill **amber surface `#FFF3D6`** (new token, "status/amber-surface"), `icon/u-turn` 32 x 32 centered.
  - Text column (gap 2): title "Finding a new way" Bold 18 / h1.3 `#222222`; body "You left the route. We're updating directions to Omar Haddad." Regular 12 / h1.45 `#737373`, width 270 (the name comes from the current stop).
- **Map controls** at (348,230), 164 high (three circles), i.e. y = 230 (not 250).
- Trip sheet: as the driving trip sheet (R10), values "10:07 arrival", "4 min", "1.1 km", stop 1 "Omar Haddad", "Sari St, Al Zahra · #RX-1039".
- Map: World offset (-434,-500) (the route is being recalculated; the camera is different from R10). Puck (174,468). Route line style for the new route is **NOT READ**.
- Navigation (prototype): after 2.5 s -> R10 (demo auto-advance; in the real app it ends when the new route arrives). Stops control -> R21, Help -> R31, Open-in-maps -> R20. There is no Overview reaction in this frame.

## 2. R24: Weak GPS signal

Same layout as R23 (state banner at (26,56) 360 x 89, map controls at y=230, trip sheet "10:06 arrival", "4 min", "1.1 km"). Differences:
- Tile `#E9E9E9` with `icon/recenter` 28 x 28; title "Weak GPS signal" Bold 18 / h1.3; body "Your position may be off for a moment. Keep driving safely." Regular 12 / h1.45 `#737373`, width 270 (text already read in the R20-R22 read of the banner).
- World offset (-394,-504) (as R10).
- Navigation: Stops -> R21, Help -> R31, Open-in-maps -> R20. No auto-advance. The state ends when the signal returns (real behavior).

## 3. R25: Offline

Same layout as R23/R24 (state banner at (26,56) 360 x 89, map controls y=230, trip sheet "10:06 arrival", "4 min", "1.1 km"). Differences:
- Title "You're offline" (Bold 18); body starts with "Keep going. 1 update is saved ..." (the full text is **NOT READ**; the count of saved updates comes from data).
- Icon `icon/offline` 28 x 28 inside the 52 x 52 tile; the **tile color is NOT READ** (it looks like the pale red/danger surface `#FFECE5`; verify in Figma).
- Navigation: Stops -> R21, Help -> R31, Open-in-maps -> R20. The state ends when connectivity returns (real behavior).

## 4. R30: Stop moved to later (toast under the banner)

- **Maneuver banner** as R10 but for the new next stop: "90 m", "Turn right onto Tahlia St", Then "Stop 2 is on the right" (turn-right icon). 360 x 127 at (26,56).
- **Toast** at (26,195), 360 x 62 (just under the banner, 12 px gap): fill `#FDFDFD`, 1px `#D0D0D0`, **radius 16** (a rounded rectangle, not the pill used by the R13/R17 toasts), padding 14 x 12, gap 10, items centered, shadow `0 16 20 rgba(34,34,34,0.12)`.
  - `icon/history` 18 x 18.
  - Text (flex 1, wraps to 2 lines): "Omar Haddad moved to the end of your route" SemiBold 13 / h1.35 `#222222`.
  - "Undo" Bold 14 / h1.35 `#222222` (not green like the R13 toast).
- **Map controls** at (348,250), 106 high: **two circles** (overview and stops; no Help "?") under the toast.
- Trip sheet: now stop 2: "10:24 arrival", "6 min", "1.4 km", badge "2", "Lina Fares", "Tahlia St, Al Nahda · #RX-1036".
- Map: World offset (-234,-372); puck (174,468).
- Navigation: after 3 s -> R14 (demo). Overview -> R03, Stops -> R21, Open-in-maps -> R20. Undo: no link (TODO: move the stop back). Reached from R29 "Try again later".
- The stop order change (the stop goes to the end of the route, the next stop changes and the ETA values change) is a data/route update: define it in the data layer (reorder stops), not in the widget.

## 5. R33: Location sharing stopped (sheet at the top)

- **Sheet at (26,56), 360 x 191**, standard sheet container (fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 24, column gap 12, sheet shadow). It **covers the maneuver banner** (the banner exists underneath, 127 high, but the sheet is taller and hides it).
  - Message row (gap 12, py 10, items centered): icon tile 42 x 42, radius 8, fill `#FFECE5` (danger surface), icon `carbon:location` (pin) 24 x 24 in red (the Figma icon is red; apply a ColorFilter with the danger icon color; the exported SVG is black); text column (gap 1, flex 1): "Location sharing stopped" SemiBold 15 / h1.35 `#222222`; "Red Sea Express can't see your route. Turn it back on to keep delivering." Regular 13 / h1.35 `#737373`. The company name comes from data.
  - Button **Turn on**: lime `#8FE600`, radius 8, height 52, Bold 16 / h1.35 `#222222`.
- **Map controls** at (348,250), 106 high (**two** circles), trip sheet as R10 ("10:05 arrival", "4 min", "1.1 km", stop 1). The scrim: **none** in the frame.
- Navigation: **Turn on -> R10** (resumes sharing and closes the sheet). Overview -> R03, Stops -> R21, Open-in-maps -> R20.
- This state is triggered by the system (location sharing turned off); on the real device it needs the location service/permission check (do not edit android/ios here; use the existing permission code).

## 6. R34: Back from Google Maps (sheet at the top)

- **Sheet "Resume" at (26,60), 360 x 191** (4 px lower than R33; use 56 for both unless the designer says otherwise), same container as R33. It also covers the maneuver banner.
  - Message row: icon tile 42 x 42, radius 8, fill **lime `#8FE600`**, `icon/navigate` 24 x 24; text column: "Welcome back" SemiBold 15 / h1.35 `#222222`; "You were navigating to Omar Haddad in Google Maps." Regular 13 / h1.35 `#737373` (the external app name and the customer name come from data).
  - **Actions** (row, gap 10, equal width, height 52, radius 8, Bold 16): **I've arrived** (white fill, 1px `#D0D0D0`) and **Resume** (lime fill).
- Map controls (348,250) two circles, trip sheet as R10.
- Navigation: **I've arrived -> R12** (arrival screen); **Resume -> R10**. Shown when the app returns to the foreground after the driver used an external maps app (R20 with Google Maps / Waze). Needs an app lifecycle hook in the cubit (resume event); keep it a data/state trigger.

## 7. NOT READ / open items
1. R25: the full body text, the tile color and the icon color; R23/R24/R25 map state: the route line style, the stops' markers, the puck heading (assume the R10 look: stop 1 current lime, stops 2 and 3 white, heading 0).
2. R23 camera (World -434,-500) and what the map shows while rerouting (old route greyed?).
3. R24/R25: the "?" control stays, but R30/R33/R34 and R20-R22 show only two circles (106 high); which control is hidden is **not read** (assumed Help "?").
4. R33: whether the map controls and the trip sheet are interactive while the sheet is open, and whether the sheet can be dismissed. R34: same.
5. R30: toast auto-dismiss time (3 s in the prototype demo), the Undo behavior, and the stack order with the banner.
6. Motion for all banners, toasts and sheets.
7. Sheet y: 56 (R33) vs 60 (R34).
8. The new tokens/styles: amber surface `#FFF3D6`; the toast shadow `0 16 20 rgba(34,34,34,0.12)` (same as the P04 sheet shadow); Bold 18 / h1.3 (exists); SemiBold 15 / h1.35; Regular 13 / h1.35.

## 8. Prototype summary
| From | Trigger | To |
|---|---|---|
| R23 | after 2.5 s (demo) | R10 |
| R23/R24/R25 | Stops / Help / Open-in-maps | R21 / R31 / R20 |
| R30 | after 3 s (demo) | R14 |
| R30 | Overview / Stops / Open-in-maps | R03 / R21 / R20 |
| R33 | Turn on | R10 |
| R34 | I've arrived | R12 |
| R34 | Resume | R10 |
| R33 / R34 | Overview / Stops / Open-in-maps | R03 / R21 / R20 |
