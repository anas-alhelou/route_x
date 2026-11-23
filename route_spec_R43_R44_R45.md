# route_spec_R43_R44_R45: Check your packages, On break, Report wrong location

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, 412 x 917 each: R43 `6410:55447` (sheet `6410:55500`), R44 `6410:55529` (sheet `6410:55558`), R45 `6410:55569` (sheet `6410:55597`, pin `6410:55590`, hint `6410:55595`).

**Source: exported PNG images of the frames (the Figma tool limit is exhausted).** Sizes are measured from the images (1 design unit = about 2.18 px), rounded, and every estimate is marked **(img)**. Text styles are matched to the earlier specs. Navigation comes from `route_flow_prototype.md`. Font: the project keeps **Satoshi**. Tokens, sheet container, buttons and text styles come from the earlier specs. Verify the exact values in Figma when the tool limit renews.

## 0. Common
- Sheets: standard container (fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 24, sheet shadow), x = 26, width 360, bottom edge at y about 891 (24 from the bottom; keep your bottom-offset decision), height depends on content.
- **R43 and R44 have a scrim with the screen behind it blurred** (as R26b, R29, R31): check the blur of the scrim layer in Figma (`6410:55499` for R43, `6410:55557` for R44) and apply the same value on all scrims (see `route_spec_R26_R26b_R29_R31.md`, section 0). **R45 has no scrim and no blur.**
- Overlines: Bold 10 (img), letter spacing +1.2, uppercase, `#737373` unless noted.

## 1. R43: Check your packages (before the route starts)
- **Underneath:** the "ready to start" screen (R03): the route summary chip ("3 stops · 6.8 km · 32 min", icon route) at (16,64), the route with stops, the bottom nav (hidden by the sheet), behind the scrim/blur. In the prototype this screen comes **after** "Slide to start route" (R03) and before R10.
- **Sheet** (about 360 x 535 (img), y about 361, bottom about 893):
  - Overline **"BEFORE YOU GO"**.
  - Title **"Are all 3 packages in the van?"** Bold 26 / h1.12 / ls -0.52 `#222222` (the count from data; one line at this width).
  - Subtitle **"Tap each one or scan its label."** Regular 14 `#737373`.
  - **Package rows** (column gap 10), one per package: box fill `#F5F6F2`, 1px `#D0D0D0`, radius 16, height about 68 (img), padding about 16 (img), gap 12, items centered:
    - **Checkbox** 24 x 24, radius 6: **checked** = fill lime `#8FE600` with a black check mark; **unchecked** = white fill with a 1.5px `#D0D0D0` border. Draw it in code (the same widget as the R40b checklist).
    - Text: name Bold 16 `#222222` ("Omar Haddad"); detail Regular 14 `#737373` ("#RX-1034 · Medium box": order id and package type from data).
  - **Scan labels instead**: a centered row (no box), `ic_package.svg` 24 x 24 + label Bold 16 `#222222`. It starts the scan flow (no screen in the prototype: TODO).
  - **Primary button**: full width, height 52, radius 8, Bold 16. State **not all checked** (as drawn): white fill, 1px `#D0D0D0`, label **"2 of 3 checked"** in `#737373` (disabled look). State **all checked** (not drawn; from the prototype it is the "Start route" button): lime fill, label **"Start route"** `#222222`. (The "all checked" look and label are assumed: confirm.)
  - **"A package is missing"**: centered text link, Bold 14, **`#FF3D00`** (danger icon color), shown below the button (it may only show when not all packages are checked: assumed).
- Behavior (assumed): tapping a row toggles its checkbox; the button counts them ("N of M checked") and becomes "Start route" when all are checked.
- Navigation (prototype): **Start route -> R10**; tapping the unchecked package (Ahmed Ali) checks it and then goes to R10 in the demo; **A package is missing -> R31** (help). Reached from R03 "Slide to start route".

## 2. R44: On break
- **Underneath:** the driving screen (R10 look, **no maneuver banner** visible) with the **three map controls** at (348,250) (blurred) and the puck at (206,500), behind the scrim/blur. The route line is the R10 lime path with stops 1 (current), 2, 3.
- **Sheet** (about 360 x 301 (img), y about 581):
  - Overline **"ON BREAK"** in **amber `#C27C00`**.
  - **Timer** row (baseline aligned, gap 8): **"12:48"** in a very large bold style (about 52 (img), Bold, `#222222`, tight letter spacing; no existing style: add a dedicated one and confirm the size in Figma) and **"of 15 min"** Bold about 18 (img) `#737373`. The timer is the remaining (or elapsed) break time: **not specified** (12:48 of 15 min with "Started 11:40": it looks like a count-down).
  - Body **"Started 11:40. Dispatch can see you're on break and customer ETAs moved by 15 min."** Regular 14 `#737373` (2 lines; start time, the 15 min and the effect come from data).
  - Buttons (column, gap 10): **Resume route** (lime, radius 8, height 52, Bold 16) and **Add 5 minutes** (white, 1px `#D0D0D0`, radius 8, height 52, Bold 16).
- Behavior: while on break the route is paused (ETAs move by the break length); the break has a limit (15 min here) and "Add 5 minutes" extends it. What happens when the time ends is **not drawn**.
- Navigation (prototype): **Resume route -> R10**. Opened from R31 "Take a break". "Add 5 minutes": no link (extends the timer: TODO in the data layer).

## 3. R45: Report wrong location
- **No scrim.** The arrival-style map: puck at about (206,420) heading left, traveled grey path to the right, lime route to stops 2 and 3, as R12 (no map controls, no chip, no banner).
- **Hint pill** at the top: white pill (radius 999), padding about 16 x 8 (img), text **"Drag the map to put the pin on the door"** Medium/Bold 14 `#222222`, at (about 70, 70), width about 272 (img), shadow like the chips.
- **Draggable pin** at about (300,316) (img): a **lime `#8FE600` circle 48 x 48** with a **location pin icon** inside (`ic_pin`/`ic_location` outline `#222222`), a thin vertical stem (about 2 x 14 (img), `#222222`) below it and a small grey shadow ellipse under the stem. The pin stays at the screen center of the map and the **map moves under it** (drag the map, as the hint says); the new location is the map center when the driver sends the report. (The pin position here is not the screen center in the frame: it is a static illustration; confirm.)
- **Sheet** (about 360 x 360 (img), y about 538):
  - Overline **"WRONG LOCATION · OMAR HADDAD"** (customer name from data).
  - Title **"What's wrong with the pin?"** Bold 26 / h1.12 / ls -0.52.
  - **Three radio rows** (column gap 10), each height about 53 (img), radius 12 (img), padding 14 (img), gap 12, label SemiBold 16 `#222222`:
    1. **"Entrance is somewhere else"** (selected: fill `#F0FAEC`, **2px `#8FE600`** border, radio on = `radio_on.svg` 22 x 22).
    2. **"Pin is on the wrong street"** (unselected: fill `#F5F6F2`, 1px `#D0D0D0`, `radio_off.svg`).
    3. **"Address doesn't exist"** (unselected).
  - **Send to dispatch**: lime, radius 8, height 52, Bold 16, full width.
- Behavior (assumed): the first reason is selected by default as drawn; the pin drag is meaningful only for "Entrance is somewhere else" (it is not specified whether the pin is shown for the other reasons); sending sends the reason and the pin position to dispatch.
- Navigation (prototype): **Send to dispatch -> R12** (back to the arrival screen). Reached from R29 "Report wrong location".

## 4. New tokens / styles / assets
- Colors: lime `#8FE600`, amber `#C27C00`, `#F0FAEC`, `#F5F6F2`, `#D0D0D0`, danger icon `#FF3D00` (all exist).
- Text styles (dedicated, do not change existing ones): Bold 10 / ls +1.2 (exists), Bold 26 / h1.12 / ls -0.52 (exists), Regular 14, Bold 16, SemiBold 16, Bold 14; **new: the large timer style (Bold about 52, check in Figma) and the "of 15 min" style (Bold about 18)**.
- Assets: `ic_package.svg`, `ic_pin.svg` / `ic_location.svg`, `radio_on.svg`, `radio_off.svg` (exist). Draw in code: the checkbox (also used in R40b) and the pin with its stem.

## 5. Domain / data notes
- **R43:** the list of packages of the route (customer, order id, package type) and their checked state; the "missing" action reports to dispatch (R31 in the prototype). A scan flow (barcode) is a separate feature: keep TODO and ask before adding any package.
- **R44:** break state (start time, allowed minutes, extensions) is part of the route/engine state; the break pauses the ETAs. Add it to the stops/route engine as an event (start break, extend, resume).
- **R45:** a "location report" entity (stop id, reason, corrected position).

## 6. NOT READ / open items (all estimates come from the images)
1. The scrim blur (R43, R44); the exact heights/y of the sheets; the big timer font size.
2. R43: the "all checked" button look/label, whether "A package is missing" is always visible, and the scan flow.
3. R44: count-down or count-up, what happens when the break time ends, and the rule for the 15 min limit.
4. R45: how the pin behaves while the map is dragged (the frame shows a static pin), the other two reasons' effect on the pin, the default selected reason.
5. The package ids are inconsistent with other screens (Omar Haddad is `#RX-1034` here and `#RX-1039` elsewhere): use data, not these values.
6. Motion for all three.
