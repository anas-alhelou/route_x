# route_spec_R27: Next stop details

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, frame `6410:54646` ("R27 · Next stop details"), 412 x 917. Sheet node `6410:54685`.
Read via Figma MCP (design context + file metadata). Font: Figma uses **Satoshi** in this sheet (and Plus Jakarta Sans for the last button label); the project keeps **Satoshi**. Tokens, sheet container, buttons and text styles come from `route_spec_R10.md` and `route_spec_R20_R21_R22.md`. This is a modal sheet over the driving screen, like R20 to R22, **without a scrim** in the frame (see open items).

## 1. Frame structure
All layers (z-order bottom to top), same driving screen as R10 underneath:
| Layer | x | y | w | h |
|---|---|---|---|---|
| World (map), Driver puck (heading 0) | -394,-504 | 174,468 | 900 x 1500 | 64 x 64 |
| Maneuver banner (as R10: "80 m", "Turn left onto Sari St", Then "Stop 1 is on the right") | 26 | 56 | 360 | 127 |
| Map controls | 348 | 250 | 48 | **106** (two circles) |
| **Stop details sheet** | 26 | 460 | 360 | 433 |

- No trip sheet (the stop details sheet takes its place at the bottom; its bottom edge is at y = 893, 24 from the bottom, like the R20 to R22 sheets). Keep your bottom-offset decision (safe area + 32) and list it as the known deviation.
- Map controls: two circles (overview and stops). Hidden control (assumed Help "?") as in R20 to R22.
- The sheet appears from the Current-stop row of the driving trip sheet (R10 only).

## 2. Stop details sheet (node 54685, 360 x 433)
Standard sheet container (fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 24, sheet shadow `0 16 40 -8 rgba(34,34,34,0.12)`), column gap **12**:
1. **Overline** "NEXT STOP · 1 OF 3": Bold 10 / h1.35 / letter spacing +1.2, `#737373`, uppercase. The text comes from data ("NEXT STOP · {n} OF {total}").
2. **Name** "Omar Haddad": Bold 26 / h1.12 / ls -0.52, `#222222`.
3. **Meta** "Sari St, Al Zahra · #RX-1039 · 1.1 km": Regular 13 / h1.35, `#737373`, one line.
4. **Details list**: fill `#F5F6F2`, 1px `#D0D0D0`, radius 16, padding 16 horizontal / 4 vertical, column. Each row: padding 10 vertical, label on the left (Regular 14 / h1.35, `#737373`) and value on the right (Bold 14 / h1.35, `#222222`), space-between:
   - **Gate code** — `4417#`
   - **Time window** — `10:00 – 10:30`
   - **Packages** — `2 · drop-off`
   The rows come from data. Show only the rows the order has (gate code, time window and package count/type are fields of the order).
5. **Note row** (gap 10, items start): `icon/note` 18 x 18 + text Medium 14 / h1.35 `#222222` ("Call when you arrive. Building 12, 3rd floor."), width 280. Shown only if the order has a company note.
6. **Actions** (row, gap 10, equal width, height 52, white, 1px `#D0D0D0`, radius 8, Bold 16 `#222222`): **Call** and **Message**.
7. **Back to map**: lime `#8FE600`, radius 8, height 52, Bold 16 `#222222` (full width).

## 3. Navigation (prototype)
| From | Trigger | To |
|---|---|---|
| R10 trip sheet | tap on the Current-stop row | R27 |
| R27 | Back to map | R10 (close the sheet) |
| R27 | Overview control | R03 (as in the other driving screens; confirm with the designer) |
| R27 | Stops control | R21 |
| Call, Message | no link | TODO: dial the customer, open messaging |
The Current-stop row is tappable only in R10 (the prototype has no link on the row in R11; see the R11 spec).

## 4. Implementation notes
- It is one more value of the existing modal-sheet state of the driving screen (the `DrivingModalSheet` enum), not a new screen: the maneuver banner, map and controls stay under it.
- Reuse the sheet container and the secondary/primary buttons; the details list and the overline are new small widgets. Text styles needed (dedicated, do not change existing ones): Bold 10 / h1.35 / ls +1.2 (already added for R19), Bold 26 / h1.12 / ls -0.52 (exists), Regular 13 / h1.35 (exists), Regular 14 / h1.35, Bold 14 / h1.35, Medium 14 / h1.35.
- Icon: `icon/note` (`ic_note.svg`) at 18 x 18.
- Data: the order fields (gate code, time window, packages count and type, company note, order id, distance) must come from the stop/order entity; if the entity does not have them yet, add them as optional fields (no hardcoded texts).
- Dial/message: the call intent can use `url_launcher` only if it is already in pubspec; if not, keep TODO and ask before adding a package.

## 5. NOT READ / open items
1. Whether there is a scrim behind this sheet (none in the frame; R20 to R22 have a white 55% scrim), and whether the sheet can be dismissed by tapping outside.
2. Whether the Overview control opens R03 here (copied from the driving screens).
3. The Plus Jakarta Sans label on "Back to map" vs Satoshi on the rest (design inconsistency; use Satoshi).
4. The sheet height changes with the content (433 here): rows that are missing in the data shrink the sheet.
5. Motion: sheet enter/exit.
