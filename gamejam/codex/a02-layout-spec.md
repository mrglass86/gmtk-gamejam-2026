# A0.2 relayout spec — Noah's floor plan (directorial pass 1 outcome)

Source: the director's mockup (archive at `gamejam/brief/layout-mockup-v2.png`
once dropped in). This spec is the coordinate translation; where it and the
mockup disagree, ask, don't guess. Three flagged assumptions at the bottom
await the director's answers — build with the defaults, they are cheap to flip.

## Conventions

- Meters. +x = east (right on the mockup), +z = south (down on the mockup).
- World origin at house center. Exterior interior-face bounds: x −15..15,
  z −6.4..6.4 (30 × 12.8 m).
- Wall height 1.2, thickness 0.25, floor thickness as current. All existing
  LevelBuilder machinery (groups, `nav_source`, materials, bake) unchanged —
  this is a data swap plus the noted scene-node moves.
- Camera: ortho `size` ≈ 17.5 (fit is width-driven now), same angle as current.
- Zone names stay `bedroom` / `hall` / `living` / `kitchen` (locked interface).
  `hall` = the middle band + southeast alcove lamps.

## Rooms and floors (center x,z — size w,d — surface)

| Floor | Center | Size | Surface |
|---|---|---|---|
| KidCarpet (kid bedroom) | −11.1, −3.95 | 7.75 × 4.9 | carpet |
| BathFloor | −5.8, −3.95 | 2.9 × 4.9 | hardwood |
| LivingFloor (TV/couch/dog) | 1.25, −4.0 | 11.1 × 4.8 | hardwood |
| KitchenFloor | 10.9, −2.1 | 8.2 × 8.6 | hardwood |
| MiddleFloor (dining band) | −4.1, 0.0 | 21.8 × 3.0 | hardwood |
| ApproachFloor (past adult door) | −5.75, 3.95 | 3.05 × 4.9 | hardwood |
| CarpetFloor (south corridor) | 0.25, 5.05 | 9.5 × 2.7 | carpet |
| AlcoveFloor (pre-pantry) | 8.1, 4.9 | 6.2 × 2.95 | hardwood |
| PantryFloor | 13.2, 4.4 | 3.6 × 4.0 | hardwood |
| HallRug (director: rug in the hallway band; extended west to the kid door so it doubles as the teaching carpet) | −8.5, 0.05 | 9.0 × 2.2 | carpet |

## Walls (center x,z — length x,d; height/thickness standard)

Exterior: North (0, −6.4) 30.5×0.25 · South (0, 6.4) 30.5×0.25 ·
West (−15, 0) 0.25×13.05 · East (15, 0) 0.25×13.05.

| Wall | Center | Size |
|---|---|---|
| KidSouthA (west of kid door) | −14.45, −1.5 | 1.1 × 0.25 |
| KidSouthB (east of kid door) | −9.55, −1.5 | 4.1 × 0.25 |
| KidBathDivider | −7.25, −3.95 | 0.25 × 4.9 |
| BathLivingDivider | −4.3, −3.95 | 0.25 × 4.9 |
| LivingSouth | −1.95, −1.7 | 4.7 × 0.25 |
| DogKitchenDivider | 6.8, −3.9 | 0.25 × 5.0 |
| AdultNorthA (west of adult door) | −14.45, 1.5 | 1.1 × 0.25 |
| AdultNorthB (east of adult door) | −9.55, 1.5 | 4.1 × 0.25 |
| AdultEast | −7.3, 3.95 | 0.25 × 4.9 |
| LVertical | −4.25, 2.55 | 0.25 × 2.3 |
| LHorizontal | 0.25, 3.45 | 9.5 × 0.25 |
| PantryWest | 11.2, 4.3 | 0.25 × 4.2 |

Openings (no wall, no Door.gd): bathroom's full south side (x −6.9..−4.5 at
z −1.5); living↔dining from x 0.4..6.8; kitchen↔middle south of x 6.8..15;
carpet corridor's east end into the alcove (see note 2).

Doorways with function:
- Kid bedroom door gap: x −13.9..−11.6 in the kid south wall — **BedroomDoor**
  (Door.gd BEDROOM, the teaching door) node at (−12.75, −1.5).
- Adult bedroom door gap: x −13.9..−11.6 in the adult north wall — visual
  closed door panel only, no Door.gd; the light strip lives here.

## Props (center x,z — size w,h,d)

| Prop | Center | Size |
|---|---|---|
| Crib | −8.7, −4.7 | 2.3 × 0.9 × 3.0 |
| Nightstand (+NightstandClock on top) | −10.2, −5.6 | 0.8 × 0.7 × 0.8 |
| TVConsole (TV glow east face) | −3.2, −4.1 | 0.8 × 1.5 × 4.0 |
| Couch | 1.55, −4.4 | 2.3 × 0.8 × 3.0 |
| DogBed | 5.5, −4.75 | 1.8 × 0.3 × 2.7 |
| KitchenCounter | 9.8, −5.35 | 5.4 × 0.9 × 2.1 |
| Fridge (goal body) | 13.75, −5.3 | 2.4 × 2.2 × 2.2 |
| KitchenTable | 10.55, −1.2 | 2.5 × 0.8 × 2.6 |
| DiningTable | 0.95, 0.9 | 5.1 × 0.8 × 2.2 |
| AdultBed | −9.8, 4.75 | 4.6 × 0.8 × 3.1 |
| HallShelf (alcove S-bend cover) | 10.1, 4.35 | 1.4 × 1.1 × 3.5 |
| FrontDoor (locked home-entry door — visual only, no Door.gd, no wall opening; set into the south exterior wall's inner face) | 8.0, 6.3 | 2.4 × 1.15 × 0.15 |
| DoorMat (optional flourish: small carpet-coloured patch at the front door, visual only) | 8.0, 5.85 | 1.6 × 0.02 × 0.9 |

## Goal nodes (move the existing scene nodes)

- `BedroomDoor` → (−12.75, 0, −1.5), Door.gd BEDROOM, panel visual ~2.3 wide.
- `Fridge` interaction node → (13.75, 0, −4.1) (south face of the fridge body),
  Door.gd FRIDGE, `provides_snack = true`.
- `Pantry` interaction node → (13.2, 0, 2.5) (the closet's north face is one
  wide door panel, ~3.4 m), Door.gd PANTRY, `provides_snack = true`.
- `Snack` node → (13.5, 0, 0.0) (position only matters after a drop).
- `NightstandClock` → on the kid-room nightstand, readable from camera.
- `Crib` node → match the crib prop.

## Hazards (NoiseSurface, center — size — multiplier)

| Hazard | Center | Size | Mult |
|---|---|---|---|
| CreakTeacher (outside kid door, embedded in the HallRug — overlay wins the surface read, proven pattern) | −11.8, −0.05 | 1.8 × 0.9 | 3.0 |
| CreakKitchen | 6.2, 0.0 | 1.8 × 0.8 | 3.0 |
| CreakAdult (approach passage) | −5.7, 3.5 | 1.8 × 0.8 | 3.0 |
| ToyHallRug (on the HallRug's east half) | −5.6, 0.0 | 1.8 × 0.9 | 4.0 |
| ToyDining | −2.6, 2.4 | 1.8 × 0.9 | 4.0 |
| ToyCarpet (on the carpet corridor) | −2.2, 4.8 | 1.8 × 1.0 | 4.0 |

## Lights

| Light | Zone | Position (x, z) |
|---|---|---|
| KidLamp | bedroom | −11.1, −3.9 |
| LivingLamp | living | 0.0, −4.2 |
| KitchenLamp | kitchen | 10.5, −3.0 |
| MidLamp | hall | −0.5, 0.5 |
| AlcoveLamp | hall | 8.0, 4.8 |

Shadowless glows (AreaLight3D): TVGlow on the console's east face; WindowGlow
on the kid room west wall (assumption — moonlight for the start area);
DoorStripGlow at the adult door's north side (−12.75, ~1.2) pooling into the
middle band — this replaces the old fix-5 placement question, the adult door
IS the parent's door now. Fridge dynamic light already follows the FridgeDoor
node.

Ambient/masking sources (A4): TV at the console; kitchen speaker on the
counter (~8.5, −5.3).

## Actor reference points

- Player start: (−12.4, −4.0), kid room.
- Parent start/anchor: couch seat (−0.2, −4.6), facing west toward the TV.
- Pet start/anchor: dog bed (5.5, −4.2).
- Routine destinations for lane B data: kitchen drink spot (9.5, −3.8),
  bathroom (−5.8, −3.5), kid-door check point (−12.75, −0.8), lamp positions
  above for the lights-off walk.

## Verification (same gates, no new ones)

Startup bake handles the navmesh automatically — confirm polygon count and
that agents cannot cross the L-wall or the pantry wall. Re-capture the labeled
layout PNG for the director. The teaching chain to eyeball: kid door → rug
silence → CreakTeacher ring → rug silence again → routes split (adult-door
light strip south, hallway rug east with the toy trap on it).

## Assumptions — director rulings

1. RESOLVED (director, 2026-07-23): the purple block is a hallway RUG with the
   squeaky toy sitting on it. ToyChest deleted; HallRug floor added; the rug
   extends west to the kid door so it also delivers the locked creak→silence
   teaching contrast (replaces the planner's invented TeachRunner strip).
2. RESOLVED (director, 2026-07-23): the DOOR marker near the pantry is the
   home's locked front door — realism set-dressing only. FrontDoor prop added
   (south exterior wall, alcove side of the pantry wall), never interactable,
   no wall opening. The corridor→alcove threshold itself stays open.
3. OPEN (defaults standing) — kid room carpet, bathroom tile-as-hardwood,
   everything unmarked hardwood.
