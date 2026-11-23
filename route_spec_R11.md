# route_spec_R11: Driving · almost there

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, frame `6410:53514` ("R11 · Driving · almost there"), 412 x 917.
Read via Figma MCP (design context + Plugin API read-only). Font: Figma uses Plus Jakarta Sans, the project keeps **Satoshi** (map weights 1:1).
Everything not listed here is identical to `route_spec_R10.md` (same containers, radii, shadows, text styles, tokens). Reuse the R10 widgets; do not create new ones unless noted.

## 1. Frame structure

| # | Layer | Node | x | y | w | h | vs R10 |
|---|---|---|---|---|---|---|---|
| 1 | World (map) | 53515 | -350 | -440 | 900 | 1500 | camera is shifted (R10: -394, -504) |
| 2 | Driver puck | 53529 | 174 | 468 | 64 | 64 | same position, heading rotated (see 4) |
| 3 | Status bar | 53534 | 0 | 0 | 412 | 52 | same |
| 4 | Maneuver banner | 53535 | 26 | 56 | 360 | **90** | **no "Then" strip** (R10: 127) |
| 5 | Map controls | 53544 | 348 | **190** | 48 | 164 | y = 190 (R10: 250) |
| 6 | Trip sheet | 53551 | 26 | 722 | 360 | 169 | same size, different values |

No bottom nav. Trip sheet bottom is at y = 891 (your decision to use safe area + 32 instead of 26 still applies; keep it listed as an intentional deviation).

## 2. Maneuver banner (node 53535, 360 x 90)

Same container as R10 (fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, sheet shadow). Only the top group exists (x1,y1, 358 x 88, padding 14, gap 14). **There is no "Then" strip.** The container is just 90 high (88 + 2 border), with all four corners radius 24.
- Maneuver tile 60 x 60, `#8FE600`, radius 16, icon **`icon/arrive`** (flag, node 6280:8539) 36 x 36 instead of `icon/turn-left`.
- Distance "40" (Bold 28 / h1.15 / ls -0.28, `#222222`) + unit "m" (Medium 14 / h1.45, `#737373`), same row layout as R10.
- Instruction "Omar Haddad is on your right": Medium 16 / h1.45, `#222222`, fixed width 250.
- Rule: the strip appears only when the data has a next-step line. In R11 the data has the name of the stop and the side ("on your right") inside the main instruction and no next step.
- The maneuver icon depends on the maneuver type (turn-left in R10, arrive in R11). Keep it data-driven (ManeuverType). Only `icon/turn-left` and `icon/arrive` are known from R10/R11.

## 3. Map controls (node 53544)

Identical to R10 (3 circles 48 x 48, gap 10, same icons and shadow). Only the top position changes: **y = 190** (R10: 250). It is not derived from the banner height (banner heights are 90 here and 127 in R10, the offsets are 190 and 250). Keep `right: 16`, `top` from the spec per state.

## 4. Driver puck (node 53529, 64 x 64) and the heading rotation

Read from Figma (the same structure applies to R10 and R01-style puck; compare with your DriverPuck):
- Accuracy ellipse: 64 x 64 at (0,0), fill `#3B6EE0` at **14% opacity**.
- Base ellipse: 34 x 34 at (15,15), fill `#FFFFFF`, drop shadow `0 2 blur 8` color `rgba(31,36,26,0.25)`.
- Heading: a frame 22 x 22 centered on the puck (R10: x21,y21) holding one vector arrow 13.75 x 16.04, fill and stroke `#3B6FE0`, stroke 1.375 (an arrow-shaped navigation glyph pointing up at 0 degrees).
- R10: rotation 0 (arrow points up). **R11: the heading frame is rotated 90 degrees** (Figma positive angle is counter-clockwise), so the arrow points left. In Flutter, rotate by -90 degrees (`Transform.rotate(angle: -pi/2)`) when the heading is west.
- The arrow is a vector: export it as SVG (do not keep the Material icon). Keep the puck center at the screen position (206, 500) as in R10.

## 5. Route line and stop markers (apply to R10 as well; R10 values in section 6)

Route line, drawn in this order (all strokes, round cap, round join, no dash):
| Layer | Stroke | Width |
|---|---|---|
| Upcoming path, outline | `#FFFFFF` | 14 |
| Upcoming path, casing | `#6FC000` | 9 |
| Upcoming path, main | `#8FE600` | 6 |
| Traveled path (behind the puck), outline | `#FFFFFF` | 12 |
| Traveled path (behind the puck), main | `#B8BDB2` | 6 |
The upcoming path starts at the puck and goes through the stops. The traveled segment is the short grey part behind the puck. R10: traveled 16 long, upcoming 364 tall. **R11: traveled 80 tall x 44 wide, upcoming 300 tall x 160 wide**, i.e. the grey segment grows and the lime one shrinks as the driver advances.

Stop markers (38 x 38 circles):
| State | Fill | Stroke | Number |
|---|---|---|---|
| Current stop (stop 1 in R10/R11) | `#8FE600` | `#FFFFFF` 3px | `#222222` |
| Upcoming stops (2 and 3) | `#FFFFFF` | `#CFCFCF` 2px | `#222222` |
Current stop shadow: `0 3 blur 10 rgba(31,36,26,0.18)`.
**Correction to route_spec_R10.md section 1:** it said all three markers are white. That was wrong for R10 and R11: the current stop is lime with a white border (the earlier all-white version came from R03).

## 6. Trip sheet (node 53551, 360 x 169)

Same structure as R10:
- Stats: "10:05" / "arrival" (unchanged), **"1 min"**, **"0.1 km"**.
- Divider, current stop row: badge "1", "Omar Haddad", "Sari St, Al Zahra · #RX-1039", Call 44 circle `#E9E9E9`, Open-in-maps 44 circle `#8FE600`.
- Difference: in R11 the "Current stop" row is **not tappable** (no navigation to R27). Only the maps button and the call button act.

## 7. Prototype (from Figma reactions)

- R11 after 2.5 s goes to R12 (demo auto-advance; in the real app, arrival is detected by distance).
- Overview control -> R03; Stops control -> R21; Help control -> R31; Open-in-maps -> R20. There is no reaction on "Current stop" in R11.
- R41 "Not here yet" goes back to R11.

## 8. Notes / open items

1. The ETA text "10:05" is `#8FE600` on `#FDFDFD` (low contrast, already an open designer question).
2. The distance/ETA values and the banner text come from data; do not hardcode "40 m" or "Omar Haddad is on your right".
3. Not read: R11 map camera zoom/heading (static frame), motion between R10 and R11.
