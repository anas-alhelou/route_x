# Implementation Plan: RouteX R26, R26b, R29, R31 (Route Update, What Changed, More Options, Help)

This plan outlines the implementation for features **R26** (Route updated card), **R26b** (What changed sheet), **R29** (More options sheet), and **R31** (Need help sheet), based on `route_spec_R26_R26b_R29_R31.md`.

## User Review Required

> [!IMPORTANT]
> **Scrim Background Blur**: The spec notes that Figma frames indicate a background blur on the scrim in addition to the 55% white fill. Currently, the app uses a solid semi-transparent scrim (`AppColors.scrimWhite`). We will list this as an open question and await confirmation before adding `BackdropFilter`.

> [!WARNING]
> **Missing Icon Assets**: The following icons are not present in the exported icon set and will use clearly marked **TEMP placeholders** (`Icon(Icons....)` with clear comments):
> - Bell (R26 update card)
> - Clock with dotted ring (R26b "Route now 4 stops", R31 "Take a break")
> - Van (R31 "Vehicle problem")
> - Red package-with-X (R31 "I feel unsafe")
> - Red no-entry circle with slash (R26b removed stop)

## Open Questions

1. **Scrim Blur**: Should we add `BackdropFilter(ImageFilter.blur)` to scrims across R20–R31?
2. **"View when stopped" Behavior**: Should clicking "View when stopped" while driving be restricted or directly open R26b?
3. **Emergency Number**: For "I feel unsafe" in R31, the emergency number (999) must come from company settings/data, not hardcoded.
4. **Deliver a different stop next**: Needs a stop-picker sheet (TODO placeholder in navigation).

## Proposed Changes

### Domain & Entities
#### [NEW] [route_change.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/domain/entities/route_change.dart)
- Define `RouteUpdateChange` domain entity representing added, removed, or total route modifications (type, customerName, address, subtitle, timestamp, updatedCount).

### Presentation & Widgets
#### [NEW] [route_list_row.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/presentation/widgets/route_list_row.dart)
- Reusable list-row widget matching spec: 36x36 icon tile (radius 8, configurable fill/icon/color filter), Bold 16 title `#222222`, optional Regular 14 subtitle `#737373`, optional 1px `#D0D0D0` divider.

#### [NEW] [route_update_card.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/presentation/widgets/route_update_card.dart)
- R26 card widget (no scrim, sits between banner and trip sheet): amber surface `#FFF3D6`, bell icon, title & subtitle, "OK" button (secondary) and "View when stopped" button (primary lime).

#### [NEW] [route_changes_sheet.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/presentation/widgets/route_changes_sheet.dart)
- R26b sheet (scrim): Title "What changed", subtitle timestamp, three standardized list rows (Added, Removed, Totals), and full-width primary "Got it" button.

#### [NEW] [more_options_sheet.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/presentation/widgets/more_options_sheet.dart)
- R29 sheet (scrim, opens over arrival screen): Title "More options", four rows (Try again later with `ic_history`, Deliver a different stop next with `ic_stops`, Report wrong location with `ic_pin`, Get help with lime tile and `ic_call`), and secondary "Close" button.

#### [NEW] [help_sheet.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/presentation/widgets/help_sheet.dart)
- R31 sheet (scrim, opens over driving screen): Title "Need help?", subtitle dispatch answer time, five rows (Call dispatch, Message dispatch, Take a break, Vehicle problem, I feel unsafe with red text `#D93400` and danger surface `#FFECE5`), and secondary "Close" button.

### State & Controller Extensions
#### [MODIFY] [route_fleet_state.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/presentation/controllers/route_fleet_state.dart)
- Extend `DrivingModalSheet` enum with `routeUpdated`, `whatChanged`, `moreOptions`, `help`.

#### [MODIFY] [route_fleet_cubit.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/presentation/controllers/route_fleet_cubit.dart)
- Add methods to open/close R26, R26b, R29, R31 sheets/cards.
- Add TEMP test modes to trigger R26, R26b, R29, R31 directly for review and testing.

#### [MODIFY] [route_page.dart](file:///C:/Users/PC/AndroidStudioProjects/routeX_mobile/lib/features/route_fleet/presentation/pages/route_page.dart)
- Wire up the new sheets and update card rendering based on `activeSheet`.

## Verification Plan

### Automated Tests
- Run existing test suite (`flutter test`) to ensure no regression.

### Manual Verification & TEMP Test Modes
- Use the TEMP test modes in `RouteFleetCubit` to trigger R26 (card on driving screen), R26b (sheet on driving screen), R29 (sheet on arrival screen), and R31 (sheet on driving screen).
- Verify navigation flows:
  - OK -> closes card (R10)
  - View when stopped -> opens R26b
  - Got it -> closes R26b (R10)
  - Try again later -> triggers R30 stop-moved flow
  - Get help -> opens R31
  - Close -> returns to previous screen (R12 / R10)
