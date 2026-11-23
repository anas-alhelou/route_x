# route_spec_R40_R40b_R41_R42: Returning to depot, Hand back, Arriving (auto-detect), Left without marking

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, 412 x 917 each: R40 `6410:55252` (card `6410:55293`), R40b `6410:55308` (sheet `6410:55332`), R41 `6410:55344` (card `6410:55381`), R42 `6410:55393` (card `6410:55435`).

**Source: exported PNG images of the frames (the Figma tool limit is exhausted).** Sizes are measured from the images (1 design unit = about 2.18 px) and rounded; every estimate is marked **(img)**. Text styles are matched to the earlier specs (the design is consistent). Navigation comes from `route_flow_prototype.md` (read from the prototype). Font: the project keeps **Satoshi**. Tokens, the sheet container, buttons and text styles come from the earlier specs. Verify the exact values in Figma when the tool limit renews.

## 0. Common to the four screens
- **Not driving screens with a banner:** in the images there is **no maneuver banner** at the top (the file metadata says a "Maneuver banner" layer exists in R40, R41 and R42, but it is not visible in the export: probably hidden; confirm in Figma). The top shows only the status bar; R40b shows the chip "You've arrived" at (125,64).
- **Map controls:** three circles (overview, stops, help "?") at x 348, 48 x 48, gap 10 (img). Top: **y = 250** in R40 and R42, **y = 190** in R41, none in R40b.
- **No trip sheet.** A card/sheet (standard container: fill `#FDFDFD`, 1px `#D0D0D0`, radius 24, padding 24, sheet shadow) sits at the bottom, x 26, width 360, bottom edge at y about 891 (24 from the bottom, keep your bottom-offset decision), height depends on content. No scrim.
- **Depot marker (new map element):** a white ring (about 41 px outside, 3px white stroke, shadow like the stop markers) with a **pale-green dot** (about 20 px, fill pale lime `#D6EBC0`-like (img); use `#EEF9DA` if the exact value is not confirmed) inside. It marks the depot destination. It appears at screen about (46,596) in R40, at (126,580) in R40b/R41-like frames and top-right in R42 (partly off screen): the position is the map position of the depot. (The same marker is present in the R12 to R18 frames at about (126,580); it is **not** a stop: see the correction at the end of `route_spec_R12_R13.md`.)
- Overline texts use Bold 10 (img), letter spacing +1.2, uppercase, `#737373` unless noted.

## 1. R40: Returning to depot
- Map: the route is drawn to the **depot**: lime path from the puck (206,500), heading 0, through the shown stops (stops 1 current lime at about (126,437), 2 and 3 white) as in R10; the depot marker at about (46,596). (The route line toward the depot is **not read** from the image beyond the R10-like lime path; confirm.)
- Map controls at (348,250), three circles.
- **Return trip card** (about 360 x 270 (img), y about 621):
  - Overline **"RETURNING TO DEPOT"**.
  - Title **"Red Sea Express hub"** Bold 26 / h1.12 / ls -0.52 `#222222` (the depot name from data).
  - Meta **"Al Rawdah · 3.1 km · arrive 11:02"** Regular 14 `#737373` (zone, distance, ETA from data).
  - Package row (gap 12, centered): tile 36 x 36, radius 8, fill **amber surface `#FFF3D6`** with a **box icon in amber** (`ic_package.svg` with an amber color filter; the stroke looks `#C27C00`); title **"1 package to hand back"** Bold 16 `#222222`; subtitle **"Lina Fares · #RX-1036"** Regular 14 `#737373`. One row per package to return (the card grows) or a count; the data decides.
  - Button **"I'm at the depot"**: lime `#8FE600`, radius 8, height 52, Bold 16 `#222222`, full width.
- Navigation (prototype): **I'm at the depot -> R40b**; Overview -> R03, Stops -> R21, Help -> R31. Reached from R19 "Directions to depot".

## 2. R40b: Hand back at the depot
- Chip **"You've arrived"** at (125,64) (as R12). Map: puck (206,420) heading left (-90), traveled grey path to the right of the puck, upcoming lime path to stops 2 and 3, depot marker at about (126,580) (the chip/puck layout is the same as R12). **No map controls.**
- **Sheet** (about 360 x 297 (img), y about 595, bottom at 892):
  - Overline **"AT THE DEPOT"**.
  - Title **"Hand back 1 package"** Bold 26 (the count from data).
  - Body **"Give it to the depot team. They'll confirm it on their side too."** Regular 14 `#737373` (2 lines).
  - **Package checklist item** (one per package): a box (fill `#F5F6F2`, 1px `#D0D0D0`, radius 16, padding 16 (img), height about 68 (img)) with a **lime checkbox** 24 x 24 (radius 6, fill `#8FE600`, black check; the image shows it checked: the unchecked state is **not drawn**) and a text column: **"Lina Fares · #RX-1036"** Bold 16 `#222222`; **"Customer not answering"** Regular 14 `#737373` (the failure reason of that stop).
  - Button **"Returned · end my day"**: lime, radius 8, height 52, Bold 16.
- Behavior (assumed, not drawn): the driver checks each package; the button is **enabled only when all packages are checked** (the disabled style is not drawn).
- Navigation (prototype): **Returned · end my day -> R01** (no route right now). Reached from R40 "I'm at the depot" and from R41/other arrival.

## 3. R41: Arriving (auto-detect)
- Map: puck (206,500) heading left (-90) with **stop 1 (lime, "1") right next to it at about (170,500)**; lime route to stops 2 and 3; grey traveled path to the right; depot marker at the bottom-left (about (126,640), partly behind the card). Map controls at (348,**190**), three circles.
- **Card** (about 360 x 246 (img), y about 647):
  - Overline **"YOU'VE ARRIVED"** in **lime `#8FE600`**.
  - Title **"Omar Haddad"** Bold 26; address **"12 Al Nuzha St · Building 4, 2nd floor"** Regular 14 `#737373` (from data).
  - **Auto-advance bar**: 6 high, radius 3, full width; fill lime `#8FE600` at about 64% (img); track very light grey (looks `#F0F0EC` (img), lighter than the R13 track `#D0D0D0`: confirm). Text **"Opening the stop in 3 s"** Regular 14 `#737373`. (The bar fills or empties: same open question as R13; at "3 s" it is 64%.)
  - Buttons (row, gap 10, equal width (about 150), height 52, radius 8, Bold 16): **Not here yet** (white, 1px `#D0D0D0`) and **Open stop** (lime).
- Meaning: the app detects arrival automatically and, after 3 s, opens the stop (R12) unless the driver says "Not here yet".
- Navigation (prototype): after 3 s (demo timer) or **Open stop -> R12**; **Not here yet -> R11** (back to driving, almost there).

## 4. R42: Left without marking
- Map: puck (206,500) heading 0; stop 2 lime (current) at about (306,408), stop 3 white at (206,268), a **pale marker with a green check** at about (286,564) (stop 1, "delivered?" state: it shows a check on a pale-green fill; the exact state of an **unconfirmed** stop marker is **not read**), grey traveled path, depot marker at the top-right edge. A yellow road at the left edge (map). Map controls at (348,250), three circles.
- **Card** (about 360 x 317 (img), y about 574):
  - Overline **"STOP 1 NOT MARKED"** in **amber `#C27C00`**.
  - Title **"Did you deliver to Omar Haddad?"** Bold 26 (2 lines).
  - Body **"You left his address 2 minutes ago. Marking it now keeps the customer updated."** Regular 14 `#737373` (the time from data).
  - Buttons: **Yes, delivered** (lime, full width, radius 8, height 52, Bold 16); then a row (gap 10, equal) **Couldn't deliver** and **Go back** (both white, 1px `#D0D0D0`, radius 8, height 52).
- Behavior: shown when the driver leaves a stop without marking it as delivered or failed (the app detects the departure).
- Navigation (prototype): **Yes, delivered -> P01** (photo); **Couldn't deliver -> R16**; **Go back -> R12** (the arrival screen of that stop).

## 5. New tokens / styles / assets
- Colors: amber surface `#FFF3D6` (exists), amber `#C27C00` (exists), lime `#8FE600`, `#F5F6F2`, `#D0D0D0`. A **pale-green depot dot** (use `#EEF9DA` unless confirmed).
- Text styles (dedicated, do not change existing ones): Bold 10 / ls +1.2 (exists), Bold 26 / h1.12 / ls -0.52 (exists), Regular 14, Bold 16.
- Assets: `ic_package.svg` (exists, amber filter), checkbox (draw in code), the depot marker (draw in code).

## 6. Domain / data notes
- **Return task:** the packages to hand back are the stops that ended as failed (with their reason and order id). The return card (R40) and the checklist (R40b) come from the route summary built from the stops (see R19): list of failed stops with customer name, order id and reason.
- **Depot:** name, zone, distance, ETA and the map position of the depot come from the route data.
- **Auto-detect (R41) and left-without-marking (R42)** need a location source: no live tracking yet. Use the same simulated approach as the stops engine (an interface with a TEMP simulated implementation), and keep both screens reachable through test modes.

## 7. NOT READ / open items (all estimates come from the images)
1. The hidden maneuver banner layer in R40 to R42; the route line toward the depot in R40; the exact depot marker colors and position.
2. R40b: the unchecked checkbox state, whether "Returned · end my day" is disabled until all are checked, and what happens with several packages.
3. R41: the auto-advance bar direction and track color; the exact delay.
4. R42: the marker state of the unmarked stop; the trigger distance/time for "left without marking".
5. Sheet/card heights and y positions (all (img)).
6. Motion for all four.
