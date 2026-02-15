# Spud Survivor

Spud Survivor is a top-down arena roguelite shooter inspired by wave survival games.

## Engine
Godot 4.x (GDScript)

## Features
- 6 playable potato classes with unique base stats and abilities.
- Wave-based enemy scaling and run win/loss conditions.
- 40 generated weapon definitions (melee, ranged, special).
- 50 generated item/perk definitions and between-wave shop.
- Drag & drop inventory slots in the shop UI.
- Meta progression: currency, stat perks, character unlocks.
- Save/load system using JSON (`user://savegame.json`).
- Main menu, pause menu, settings, progression menu, end-of-run menu.
- English/Spanish setting toggle.
- Placeholder pickup, combat, and UI systems fully wired.

## Controls
- Move: WASD
- Aim: Mouse
- Fire: Left Mouse Button (manual aim mode)
- Pause: Escape

## Run in Editor
1. Open project in Godot 4.2+.
2. Press **Play** on `MainMenu.tscn`.

## Build (Windows)
```bash
./build_windows.sh
```
Requires a configured Godot export preset named `Windows Desktop`.

## Project Structure
- `scenes/` Core game and UI scenes.
- `scripts/` Gameplay, UI, save/progression logic.
- `build_windows.sh` One-command Windows export helper.

## Extending
- Add handcrafted content by replacing generated definitions in `scripts/ContentDB.gd`.
- Add more enemy types by extending `Enemy.tscn` + AI scripts.
- Replace placeholder visuals/audio with imported assets; gameplay hooks already exist.
