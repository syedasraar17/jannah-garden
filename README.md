# Jannah Garden: prototype

A peaceful, non-violent third-person exploration game *inspired by* the Quranic and hadith descriptions of Jannah. It is presented as "inspired by", not as a literal depiction. No enemies, scores, timers or currency.

## How to run
1. Install **Godot 4.3 or newer** (free, godotengine.org).
2. Open Godot, press **Import**, choose this folder's `project.godot`.
3. Press **F5**. Choose Man or Woman on the first screen.

> This build was written without being able to run Godot where it was made, so it has **not been test-played**. If Godot shows an error, copy the message back and it can be fixed quickly.

## Controls
| Key | Action |
|---|---|
| W A S D | Move |
| Shift | Run |
| Space | Jump (up when riding the horse) |
| Ctrl | Down (when riding the horse) |
| Mouse | Look |
| **C** or Tab | Open **Ishtiha** (desire) menu |
| F | Ride / dismount the winged horse (stand near it) |
| Esc | Free / capture the mouse |

## What is in the world (one flat map, no gates, no levels)
- **Flower pavilion**: a marble platform with **5 pillars (4 corners + a taller middle one)** holding a canopy roof of many kinds of flowers, with petals drifting down and couches beneath. It stands at one place, not over the map.
- **Three rivers** (water, milk, honey) that flow from three waterfalls at the far north, with marble-and-gold **bridges** over each.
- **Soil**: pale, softly shimmering, scattered with pearl, ruby and gold pebbles, with drifting golden motes for the musk fragrance.
- **Fruit trees** and flower beds across the garden, giving shade everywhere.
- **Waterfall sitting nook**: a small waterfall in rock on three sides, with a carpet and couch to sit on (south-west of the start).
- **Three mansions** (gold and silver courses, pearl domes, enterable) and a **hollow pearl tent**.
- **Fun park** (south): Ferris wheel, merry-go-round, swings, two slides, seesaws, sandbox, climbing frame, spring riders, monkey bars, benches.
- **Winged horse**: your creative addition (not from the sources), beside the start.
- **Characters**: the man and the woman (cream and gold) from your sheets, with radiant faceless heads.

## Ishtiha (the craving menu)
Press **C**, pick a category (Fruits, Drinks, Food, Seating, Garden), pick an item, and it appears in front of you with a soft light. Hovering an item shows where it comes from (a verse reference, or "creator's design"). Free, no cooldown, no random rewards. "Remove last" and "Clear all" tidy up.

## Hoor: switched off on purpose
`SHOW_HOOR` at the top of `main.gd` is `false`. The green-and-gold hoor design is already built in `character_builder.gd` (`"hoor"`). Please have a qualified scholar review whether and how she may be shown before setting it to `true`. She is not spawnable from the Ishtiha menu.

## Notes on sources
- Items in the Ishtiha menu cite the verse they come from. Everything else (bridges, park, flower pavilion, winged horse, exact layouts) is **artistic design**, not claimed as described.
- Your female sheet titles are swapped (cream sheet says "Hoor", green sheet says "Righteous Woman"), and the "perpetual youth" citation of 76:21 should be checked (see 56:35-37). Fix before sharing the sheets.

## Files
`main.gd` (start, animation) · `world_core.gd` (sky, soil, rivers, waterfalls, bridges) · `world_pavilion.gd` (5-pillar flower roof) · `world_nature.gd` (trees, flowers, nook, horse) · `world_places.gd` (mansions, tent) · `world_park.gd` (fun park) · `character_builder.gd` · `player.gd` · `ishtiha.gd` + `desire_items.gd` · `prims.gd` (shape helpers)

Everything is built from simple shapes so it runs with no imported assets. The next step toward the look in your sheets is replacing these with real 3D models (Blender) and keeping the same scripts.
