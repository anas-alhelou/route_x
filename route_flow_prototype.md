# Route prototype flow (read from Figma prototype reactions)

Source: Figma file `coKPQfPx4w6hLh1o4B6Yl3`, section `6410:53324`, read via the Plugin API (`node.reactions`).
All reactions are NAVIGATE (one BACK). `AFTER_TIMEOUT` entries are demo auto-advances for the prototype player. Do not treat them as real app behavior unless the product says so.
Nav-bar buttons on pre-route screens: HM1 = Home, O01 = Orders, S01 = Settings, R03 = Route tab. HM3 = Home (after Done).

## Pre-route
| From | Trigger | To |
|---|---|---|
| R00 loading | after 1.4 s (demo) | R02 |
| R02 planning | after 2 s (demo) | R03 |
| R03 ready | Slide to start route (slide or knob) | **R43** load check (not R10) |
| R04 location needed | Allow location | R10 |
| R04 location needed | Not now | R03 |
| R43 load check | Start route / tap package "Ahmed Ali" | R10 |
| R43 load check | Package missing | R31 (help) |

## Driving loop (R10, R11, R14, R17 share the same controls)
| From | Trigger | To |
|---|---|---|
| R10 | after 2.5 s (demo) | R11 |
| R11 | after 2.5 s (demo) | R12 |
| R14 | after 2.5 s (demo) | R15 |
| R17 | after 2.5 s (demo) | R18 |
| R10/R11/R14/R17 (also R23-R26, R30, R33, R34) | Overview control | **R03** |
| same | Stops control | R21 |
| same | Help "?" control | R31 |
| same | Open-in-maps button | R20 |
| R10 only | Current stop row | R27 |
| R20 | Start directions | R10 |
| R21 | Back to directions | R10 |
| R21 | End route early | R22 |
| R22 | Keep delivering | R10 |
| R22 | End route | R19 |
| R27 | Back to map | R10 |
| R31 | Close | R10 |
| R31 | Take a break | R44 |
| R44 | Resume route | R10 |

## Arrival and outcome (R12 = stop 2, R15 = stop 3, R18 = last stop)
| From | Trigger | To |
|---|---|---|
| R12 / R15 / R18 | Maps action | R20 |
| R12 / R15 / R18 | More action | R29 |
| R12 / R15 / R18 | Couldn't deliver | R16 |
| R12 | Delivered | P01 (photo, stop 2) |
| R15 | Delivered | P01b (photo, stop 3) |
| R18 | Delivered | P01c (photo, last stop) |
| R16 | Reason "Customer not answering" | R28 |
| R16 | Send to Red Sea Express | R17 |
| R28 | Mark as couldn't deliver | R17 |
| R13 | after 3 s (demo) or "Go to next stop" | R14 |

## Proof of delivery
| From | Trigger | To |
|---|---|---|
| P01 / P01b / P01c | Close | R12 / R15 / R18 |
| P01 / P01b / P01c | Shutter | P02 / P02b / P02c |
| P02 / P02b / P02c | Back or Retake | P01 / P01b / P01c |
| P02 (stop 2) | Use photo | R13 |
| P02b (stop 3) | Use photo | **R17** (no toast, no signature) |
| P02c (last stop) | Use photo | P03 signature |
| P03 / P03b | Back | P02c |
| P03 | Mode "Type" | P03b |
| P03b | Mode "Draw" | P03 |
| P03 / P03b | Done, mark delivered | R19 |
| P03 / P03b | They can't sign | P04 |
| P04 | Mark delivered with photo only | R19 |
| P04 | Back to signature | BACK |

## More options, help, system states
| From | Trigger | To |
|---|---|---|
| R29 | Maps | R20 |
| R29 | Couldn't deliver | R16 |
| R29 | Delivered | P01 |
| R29 | Option "Try again later" | R30 |
| R29 | Option "Report wrong location" | R45 |
| R29 | Option "Get help" | R31 |
| R29 | Close | R12 |
| R30 | after 3 s (demo) | R14 |
| R45 | Send to dispatch | R12 |
| R23 rerouting | after 2.5 s (demo) | R10 |
| R26 route changed | OK | R10 |
| R26 route changed | View what changed | R26b |
| R26b | Got it | R10 |
| R33 location stopped | Turn on | R10 |
| R34 back from maps | I've arrived | R12 |
| R34 back from maps | Resume | R10 |
| R35 lock screen | tap notification | R10 |
| R41 arriving (auto-detect) | after 3 s (demo) or "Open stop" | R12 |
| R41 | Not here yet | R11 |
| R42 left without marking | Yes, delivered | P01 |
| R42 | Couldn't deliver | R16 |
| R42 | Go back | R12 |

## End of route and depot
| From | Trigger | To |
|---|---|---|
| R19 route complete | Directions to depot | R40 |
| R19 | Done | Home tab |
| R40 | I'm at the depot | R40b |
| R40 | Overview / Stops / Help controls | R03 / R21 / R31 |
| R40b | Returned · end route | R01 |

## Not linked in the prototype (no incoming reaction found; confirm with the designer)
R24 weak GPS, R25 offline, R26 as entry point, R33, R34, R35 entry and R42 have no incoming link from the driving screens. They are system-triggered states, not user navigation.

## Differences from the assumptions in routex_route_agent_prompt.md section 6
- R03 slide goes to **R43 (load check)** first, then R10. It does not go straight to R10.
- R10's Overview control goes to R03 in the prototype (it is not a "recenter").
- Stop 3 (P02b) skips the signature and goes straight to R17. Only the last stop (P02c) goes through signature (P03/P03b/P04).
- R40b ends the route at R01 (no route right now).
- R19 "Done" goes to Home.
