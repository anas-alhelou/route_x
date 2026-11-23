# route_spec_R10: Driving · heading out

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, frame `6410:53453` ("R10 · Driving · heading out"), 412 x 917.
Source: values read from Figma via MCP (`get_design_context` + metadata). Items marked **NOT READ** were not read from Figma. Do not guess them, list them as open questions in Phase 1.
Font note: Figma uses Plus Jakarta Sans. The project deliberately keeps **Satoshi**. Map weights 1:1 (Regular / Medium / SemiBold / Bold / ExtraBold).

## 1. Frame structure (z-order bottom to top)

| # | Layer | Node | x | y | w | h |
|---|---|---|---|---|---|---|
| 1 | World (map, route line, 3 stop markers) | 53454 | -394 | -504 | 900 | 1500 |
| 2 | Driver puck | 53468 | 174 | 468 | 64 | 64 |
| 3 | Status bar (component Building Blocks/status-bar) | 53473 | 0 | 0 | 412 | 52 |
| 4 | Maneuver banner | 53474 | 26 | 56 | 360 | 127 |
| 5 | Map controls | 53487 | 348 | 250 | 48 | 164 |
| 6 | Trip sheet | 53494 | 26 | 722 | 360 | 169 |

- There is **no bottom nav** in R10. The Trip sheet bottom edge is at y = 891 (917 - 26 = 26 from the screen bottom, same 26 side margin).
- Map: stop markers at (501,921) "1", (521,761) "2", (421,621) "3" inside World, each 38 x 38. **Stop 1 (current) is lime `#8FE600` with a 3px white stroke; stops 2 and 3 are white with a 2px `#CFCFCF` stroke** (see route_spec_R11.md section 5 for the route line and puck values, which are the same in R10). The camera is centered so the driver puck (center 206, 500) sits just above the middle of the screen. Route line is drawn from the puck toward stop 1 and on to 2 and 3. Camera/zoom/heading behaviour in R10 is **NOT READ** (design is static); do not build live tracking now.
- R11 (almost there) differs only in: banner has **no "Then" strip** (h = 90 instead of 127), Map controls y = 190 instead of 250, puck Heading glyph y = 43 instead of 21 (different heading). Use it to confirm the banner collapses when there is no next step.

## 2. Maneuver banner (node 53474, 360 x 127)

- Container: fill `#FDFDFD` (brand/background), border 1px `#D0D0D0`, radius 24, shadow `0 16 40 -8 rgba(34,34,34,0.12)`, clip content.
- Top group (x1,y1, 358 x 88), padding 14, gap 14, items centered vertically:
  - Maneuver tile 60 x 60, fill `#8FE600`, radius 16, holds icon `icon/turn-left` 36 x 36 centered.
  - Text column (x88,y16.5, w250, h55):
    - Row (gap 4, bottom-aligned): distance "80" Bold 28, line height 1.15, letter spacing -0.28, `#222222`; unit "m" Medium 14, line height 1.45, `#737373`.
    - Instruction "Turn left onto Sari St": Medium 16, line height 1.45, `#222222`, fixed width 250.
- "Then" strip (x1,y89, 358 x 37): fill `#F5F6F2` (surface/canvas), bottom corners radius 24 (top corners 0), padding horizontal 16 / vertical 10, gap 8.
  - "Then": Medium 12, line height 1.45, `#737373`.
  - `icon/pin` 16 x 16.
  - "Stop 1 is on the right": Medium 12, line height 1.45, `#222222`.
- Texts come from data (distance, unit, instruction, next-step text). The strip is shown only when there is a next step.

## 3. Map controls (node 53487, 48 x 164)

Column, 3 circles 48 x 48, gap 10 (pitch 58), each: fill `#FFFFFF`, radius 24, shadow `0 4 12 rgba(31,36,26,0.12)`.
1. Overview: `icon/overview` 22 x 22 centered (13,13).
2. Stops: `icon/stops` 22 x 22 centered.
3. Help: glyph "?" ExtraBold 20, line height 1.35, `#222222`, centered.
Right edge: x = 348 + 48 = 396, i.e. 16 from the screen edge (412).
Actions (from the flow, **not specified on the frame itself**): overview recenters/fits the route, stops opens R21, "?" opens R31. Wire as callbacks only; the destination sheets are later tasks.

## 4. Trip sheet (node 53494, 360 x 169)

- Container: fill `#FDFDFD`, border 1px `#D0D0D0`, radius 24, padding 24, gap 14, shadow `0 16 40 -8 rgba(34,34,34,0.12)`.
- Trip stats row (x25,y25, 310 x 46): three equal columns of 103.33 (flex 1 each), no gaps.
  - Col 1: "10:05" Bold 24, line height 1.2, letter spacing -0.24, color `#8FE600` (Color/text/brand); under it "arrival" Regular 12, line height 1.45, `#737373`.
  - Col 2 (vertically centered, y 11.5): "4 min" Bold 18, line height 1.3, `#222222`.
  - Col 3 (vertically centered): "1.1 km" Bold 18, line height 1.3, `#222222`.
- Divider (y85): 1px, `#D0D0D0`, full inner width 310.
- Current stop row (y100, 310 x 44), gap 12, items centered:
  - Badge 36 x 36 circle (radius 18), fill `#8FE600`, number "1" Bold 16, line height 1.4, `#222222`.
  - Text column (flex 1, x48): name "Omar Haddad" Bold 14, line height 1.4, `#222222`; below "Sari St, Al Zahra · #RX-1039" Regular 12, line height 1.45, `#737373`. Single line each, no wrap.
  - Call button 44 x 44 circle (radius 22), fill `#E9E9E9`, `icon/call` 24 x 24. Position x210.
  - Open-in-maps button 44 x 44 circle (radius 22), fill `#8FE600`, `icon/navigate` 24 x 24. Position x266, 12 gap after Call.
- Row is tappable as a whole (cursor pointer in Figma, node "Current stop") to open stop details (R27 in the flow). Call = dial the customer. Maps button = opens the "Navigate with" sheet (R20) in the flow. **These targets are inferred from the flow, not from the frame; confirm before wiring.**

## 5. Reuse hints (map to existing code before adding anything)

- TripSheet container / radius / shadow / border already exist for R03 (TripSheet, StopRow). Check whether the driving sheet can reuse the container and the badge from StopRow (lime variant).
- White circle controls and a 44-px circle button do not exist as shared widgets in the report you described; add only if missing.
- Text styles needed (create dedicated styles, do not touch existing ones): Bold 28 / h1.15 / ls -0.28; Medium 16 / h1.45; Bold 24 / h1.2 / ls -0.24; Bold 18 / h1.3; Bold 14 / h1.4; Regular 12 / h1.45; Medium 12 / h1.45; Medium 14 / h1.45; Bold 16 / h1.4; ExtraBold 20 / h1.35.
- New colors: none (all values above are existing tokens in the Figma variable set: `#8FE600`, `#222222`, `#737373`, `#FDFDFD`, `#F5F6F2`, `#E9E9E9`, `#D0D0D0`, `#FFFFFF`).
- Icons needed as SVG (you export them from Figma): `icon/turn-left` (6280:8520), `icon/pin` (6280:8523), `icon/overview` (6280:8526), `icon/stops` (6280:8529), `icon/call` (6280:8535), `icon/navigate` (6238:10645). The Figma icon spec: 24 px grid, 1.75 stroke `#222`.

## 6. NOT READ (open items to list in Phase 1, do not guess)

1. Driver puck internals: node 53468 has an Accuracy ellipse 64 (x0,y0), a Base ellipse 34 (x15,y15), and a Heading frame 22 (x21,y21). Fills, opacities, stroke and the heading shape are not read. Use the existing DriverPuck from R01 and compare to this structure.
2. Status bar contents (Building Blocks/status-bar, 412 x 52): use the system status bar. Only the 52 height reservation is known.
3. Route line style in R10 (color, width, outline, solid vs dotted) and the stop marker states in R10 (current stop vs upcoming). R03 values already implemented may or may not apply.
4. Behaviour/motion: banner update animation, sheet appearance transition, whether the sheet and banner are fixed or scrollable. Not in the static frame; ask the designer.
5. Arrival-time contrast: "10:05" is `#8FE600` on `#FDFDFD`, which is low contrast (already in your open designer questions). Implement as designed.
