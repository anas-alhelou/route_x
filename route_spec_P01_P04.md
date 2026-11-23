# route_spec_P01_P04: Proof of delivery (photo and signature)

Figma: file `coKPQfPx4w6hLh1o4B6Yl3`, 412 x 917 each.
| Frame | Node | Content |
|---|---|---|
| P01 | `6410:55615` | camera, stop 1 (Omar Haddad) |
| P02 | `6410:55646` | check photo, stop 1 |
| P01b / P02b | `6410:55669` / `6410:55700` | camera / check, stop 2 (Lina Fares) |
| P01c / P02c | `6410:55723` / `6410:55754` | camera / check, last stop 3 (Ahmed Ali) |
| P03 | `6410:55777` | signature, draw mode |
| P03b | `6410:55805` | signature, type mode |
| P04 | `6410:55833` | "Why can't they sign?" sheet |

Read via Figma MCP (design context + Plugin API read-only). Font: Figma mixes Satoshi (P01, P02, P04) and Plus Jakarta Sans (P03, P03b). The project keeps **Satoshi** (map weights 1:1).
Frame names are one stop behind the content (e.g. "P01 · stop 2" shows "Stop 1 · Omar Haddad"). Build from the content, data-driven. The three variants (P01/P01b/P01c and P02/P02b/P02c) are **one screen with data**, not three screens.

## 1. Flow rules (from the prototype and the texts)
- Every delivery needs a **photo** ("Required for every delivery"). The **last stop** also needs a **signature** ("Photo, then a signature for this order").
- Stop 1 and stop 2: photo -> check -> Use photo -> back to the route (R13 for stop 1 and R17 for stop 2 in the prototype; the toast "Delivered · name" belongs to R13).
- Last stop: photo -> check ("Next: signature") -> P03 signature (Draw / Type) -> Done · mark delivered -> R19 (route complete).
- "They can't sign" opens P04 over P03; "Mark delivered with photo only" -> R19. "Back to signature" closes the sheet.
- Whether the last stop is signature-required comes from data (per stop/order), not hardcoded by index.

## 2. Camera screen (P01 / P01b / P01c)

Full-screen camera, white background `#FDFDFD` behind. Layers:
1. **Camera feed**: live preview filling the screen (412 x 917, starting at the top). The frame's illustration (door, package, floor) is only a placeholder; do not draw it. Use the preview, or a neutral placeholder while there is no camera.
2. **Close button** (44 x 44 at (20,60)): white circle with an X icon (the vector is in the frame). Tapping goes back to the arrival screen.
3. **Stop tag** (top, centered, y64): white pill (radius 999), padding 16 x 10, text "Stop 1 · Omar Haddad" Bold 13 / h1.4 `#222222`. Text from data ("Stop {n} · {name}").
4. **Hint** (centered, y118): white pill (radius 999), padding 14 x 8, gap 6: package icon 16 x 16 + "Show the package and the door number" Bold 12 / h1.4 in **amber `#C27C00`** (token status/amber, new).
5. **Framing guide** (300 x 531 at (56,175)): four white corner brackets over the feed (a vector in the frame; export as SVG or draw with a CustomPainter).
6. **Camera panel** (bottom, y718, height 199, full width): white, top radius 28, padding 24 x 20, column centered:
   - Title "Photo of the delivery" Bold 16 / h1.4 `#222222`.
   - Subtitle Regular 12 / h1.4 `#737373`: "Required for every delivery" (stops 1 and 2) or "Photo, then a signature for this order" (last stop). Text from data/rules.
   - Gap 10, then the **shutter** 76 x 76: a ring with a lime `#8FE600` circle of 60 in the center (the ring color/width is in the exported SVG; read it from the SVG, do not guess), then gap 18.
- Status bar: system, light content over the feed (verify legibility).
- Prototype: Close -> arrival screen (R12 / R15 / R18), Shutter -> check photo.

## 3. Check photo (P02 / P02b / P02c)
White background `#FDFDFD`, no camera.
- **Back** (20,64): back arrow icon 24 + label "Retake" Bold 15 `#222222`, gap 4. It goes back to the camera.
- Title "Looks good?" Bold 28 / h1.15 / ls -0.28 at (26,104). Subtitle "Make sure the package and door number are clear." Regular 14 / h1.4 `#737373` at y142, width 360.
- **Photo** 360 x 440 at (26,192), radius 20, clipped, shows the captured image (cover).
- **Primary** at y652: lime `#8FE600`, radius 8, height 56, width 360: label "Use photo" Bold 16 (P02, P02b) or **"Next: signature"** (P02c, last stop).
- **Secondary** "Retake" at y720: white, 1px `#D0D0D0`, radius 8, height 56. Goes back to the camera.

## 4. Signature screen (P03 draw, P03b type)
White background. Header like P02: back "Photo" (SemiBold 15) at (20,64), title "Ask {customer first name} to sign" Bold 28 / h1.15 / ls -0.28 at y104 (from data), subtitle 14 Regular gray: "Hand them the phone. They sign with a finger." (draw) / "Hand them the phone. They type their full name." (type).
- **Mode switch** (360 x 40, x26, y188 in P03 and y184 in P03b: 4 px design inconsistency, use 188): container fill `#E9E9E9`, radius 12, padding 3. Two equal segments **Draw** and **Type**. Selected: fill lime `#8FE600`, radius 8, shadow `0 1 3 rgba(34,34,34,0.08)`, label SemiBold 14 `#222222`. Unselected: no fill, radius 10, label Medium 14 `#737373`.
- **Signature pad** (360 x 240 at x26, y240): white, 1px `#D0D0D0`, radius 16 (P04 shows 20: use 16), clipped.
  - Dashed **baseline** at y179, x23, width 312 (dashed, light grey; the dash pattern is in the asset SVG: export or draw and compare).
  - "×" at (23,149): Medium 20 `#737373`.
  - Caption at (23,195): Medium 12 `#737373`: "Sign here" (draw) or "Preview" (type).
  - **Draw mode:** the user draws with a finger inside the pad. A **Clear** pill at (281,15): fill `#E9E9E9`, radius 999, padding 14 x 6, label SemiBold 13 `#222222`. The ink color in the frame is `#222222`, about 2.5 px, round caps (verify from the SVG).
  - **Type mode:** the typed name shown as a preview at (55,109): Medium **Italic** 40 `#222222` (the preview is the typed text). No Clear pill in this mode.
- **Signed by / Full name field** (360 wide at y496): white fill, radius 12, padding 16 x 12, column gap 2.
  - Draw mode: label "Signed by" Medium 12 `#737373`, value SemiBold 16 `#222222` (default = the customer name, editable; the helper says another person can sign by changing the name). Border 1px `#D0D0D0`.
  - Type mode: label "Full name", the field is **focused**: border **1.5px `#222222`**, a caret 2 x 20 in lime `#8FE600`; the value is also drawn in the preview above. Helper text changes to "The preview updates as they type. Someone else can sign for them with their own name."
- Helper (y568, 360 wide): Regular 12 `#737373`: "Someone else can sign for them. Just change the name." (draw).
- **Done · mark delivered** (y652): lime, radius 8, height 56, Bold 16. **They can't sign** (y716): text button, 44 high, SemiBold 15 `#222222`.
- Done enabled/disabled rules are **not in the frames** (no disabled state drawn). Assume it needs a signature (a stroke, or a non-empty name in type mode) and the name; confirm with the designer.

## 5. "Why can't they sign?" sheet (P04)
Over P03 (the screen behind is P03 with a different look in the frame; build the real P03 under it).
- **Scrim**: full screen, `rgba(34,34,34,0.32)` (dark, 32%). This is a **different scrim** from R20-R22 (white 55%).
- **Sheet**: white, full width, top radius 28, from y435 to the bottom, padding 12 / 24 / 34 (top / sides / bottom), column gap 14, centered; shadow `0 16 20 rgba(34,34,34,0.12)`.
  - Grabber 36 x 5, `#D0D0D0`, radius 3.
  - Title "Why can't they sign?" Bold 22 / h1.15 `#222222` (full width, left aligned). Subtitle "The photo will be the proof for this delivery." Regular 14 / h1.4 `#737373`.
  - **Reasons** (column gap 8): 4 radio rows, each: padding 14, gap 12, radius 8, items centered, label Bold 15 / h1.4 `#222222`, radio 22 x 22 at the start.
    - Unselected: fill `#F5F6F2`, 1px `#D0D0D0`, empty radio (white circle with grey ring; from the SVG asset).
    - Selected: fill `#F0FAEC`, 1px `#8FE600`, radio with lime ring and a dot (asset).
    - Options: "They refused to sign", "Hands are full or they can't use the phone" (selected in the frame), "Left with the building guard", "Something else". The list comes from data (the reason codes).
  - **Mark delivered with photo only**: lime, radius 8, height 56, width 364, Bold 16.
  - **Back to signature**: text button 44 high, width 364, Bold 15 `#222222`.
- "Something else" probably needs a note field, but none is drawn: open question.

## 6. Navigation (from the prototype)
| From | Trigger | To |
|---|---|---|
| P01 / P01b / P01c | Close | R12 / R15 / R18 |
| P01 / P01b / P01c | Shutter | P02 / P02b / P02c |
| P02 / P02b / P02c | Back or Retake | P01 / P01b / P01c |
| P02 | Use photo | R13 (toast "Delivered") |
| P02b | Use photo | R17 |
| P02c | Next: signature | P03 |
| P03 / P03b | Back | P02c |
| P03 <-> P03b | Mode Type / Draw | switch mode |
| P03 / P03b | Done · mark delivered | R19 |
| P03 / P03b | They can't sign | P04 |
| P04 | Mark delivered with photo only | R19 |
| P04 | Back to signature | close the sheet |
Entry points to P01: R12 Delivered (also R29 and R42).

## 7. New tokens / styles / assets
- Colors: amber `#C27C00` (hint text); scrim dark `rgba(34,34,34,0.32)`; check the existing `#F0FAEC`, `#F5F6F2`, `#E9E9E9`, `#D0D0D0`.
- Shadows: sheet shadow `0 16 20 rgba(34,34,34,0.12)` (different from the standard sheet shadow `0 16 40 -8`), segment shadow `0 1 3 rgba(34,34,34,0.08)`.
- Text styles (dedicated, do not change existing ones): Bold 13 / h1.4; Bold 12 / h1.4 (amber via copyWith); Bold 15 / h1.4; Bold 22 / h1.15; Medium Italic 40 (typed signature: check that Satoshi Italic Medium exists in the project; if not, ask before adding a font file); Medium 12; Medium 20; SemiBold 13/14/15/16; Bold 28 / h1.15 / ls -0.28.
- SVG assets to export: close button, framing guide, package icon (hint), shutter ring, back arrow, the radio rings (unselected and selected), dashed baseline.

## 8. Technical decisions (need your approval before the agent starts)
1. **Camera.** The design is an in-app camera with a custom overlay (close button, stop tag, hint, framing guide, shutter). `image_picker` (already in pubspec) opens the system camera UI, so it cannot show these overlays. A live preview needs the `camera` package (new dependency) plus the camera permission in `AndroidManifest.xml` and `NSCameraUsageDescription` in `Info.plist` (edits in `android/` and `ios/`, which are off limits by default). Recommended: add `camera` with your explicit approval and do the manifest/plist edits in a separate, approved step. Until then, build P01 against a small camera abstraction with a placeholder preview and the shutter returning a test photo, marked TEMP.
2. **Signature.** Draw with a `CustomPainter` and `GestureDetector` (no new package); export to a PNG via `PictureRecorder`. The data layer stores the photo path, the signature image (or strokes), the signer name and the "can't sign" reason code. Keep the repository swappable (binary/protobuf source later).
3. **Typed signature.** Rendered text in an italic style, exported as an image the same way.

## 9. NOT READ / open items
1. Done button disabled state, the empty pad state, validation of the name.
2. "Something else" reason: note field?
3. Camera flash, flip, permission denied state, capture animation, and the photo compression/size.
4. The frame behind the P04 scrim looks different from P03 (segment colors); build from P03.
5. Mode switch y (188 vs 184), pad radius (16 vs 20): minor design inconsistencies.
6. Whether stop 2's flow really skips the signature (the prototype goes P02b -> R17): confirm with the product owner.
7. Motion: sheet enter/exit, shutter press, screen transitions.
