# Card Shop Simulator

Card Shop Simulator is a desktop-first Godot 4 game about running a trading-card store under financial pressure. Players balance cash against inventory opportunities, margin against sales volume, hype against market risk, and limited display space against a growing catalog.

This repository currently provides a runnable foundation, not a finished simulation. Launching the project opens a main menu and then a lit 3D shop floor with fixture placeholders and a cash/day HUD.

## Requirements and running

- Godot 4.3 or newer
- A desktop GPU supported by Godot's Forward Plus renderer

1. Open Godot's Project Manager.
2. Import `project.godot` from this repository.
3. Open the project and press **F6** to run the current scene or **F5** to run from the boot scene.
4. Select **Open Shop** on the menu.

From a terminal with Godot on `PATH`:

```bash
godot --path .
```

Run the lightweight foundation tests without opening a window:

```bash
godot --headless --path . --script res://tests/test_runner.gd
```

## Architecture

- `scenes/boot/` owns application startup.
- `scenes/shop/` contains the 3D shop composition.
- `scenes/ui/` contains reusable interface scenes.
- `scripts/autoload/` provides small application services:
  - `EventBus` carries cross-module signals.
  - `GameState` owns session/day state.
  - `Economy` owns cash and the ledger.
  - `InventoryService` owns stock lots.
- `scripts/core/` contains runtime orchestration such as the day clock.
- `scripts/economy/`, `inventory/`, `customers/`, and `shop/` contain focused domain types and services.
- `data/` holds versioned, reviewable content definitions.
- `assets/` is split by asset type and intentionally contains no binary content yet.
- `tests/` contains headless foundation checks.

Autoloads expose stable service APIs. Domain code communicates across module boundaries through `EventBus` rather than scene-tree lookups. Prices and balances use integer cents to avoid floating-point currency errors.

## Project documentation

- [Foundation design](DESIGN.md)
- [Systems design v1](docs/design/systems-design-v1.md)
- [Aether Arc fictional set bible](docs/design/fictional-set-bible-v1.md)
- [UI wireflows v1](docs/design/ui-wireflows-v1.md)
- [Difficulty curves v1](docs/design/difficulty-curves-v1.md)
- [MVP visual direction](docs/art/VISUAL_DIRECTION_MVP.md)
- [MVP 1.0 QA release criteria](docs/qa/mvp-1.0-release-criteria.md)

## Contribution conventions

- Target Godot 4.3+ and use typed GDScript.
- Keep scripts focused; add behavior to the owning module rather than expanding an autoload into a god-object.
- Prefer signals for cross-module notifications and direct calls for explicit service commands.
- Store currency as integer cents and content data in versioned JSON or Godot resources.
- Add tests for deterministic domain logic. Keep scenes free of generated import metadata.
- Use `snake_case` for files/functions/variables, `PascalCase` for named classes, and descriptive scene node names.

Create a feature branch for each coherent change. Keep commits reviewable, open a pull request against `main`, explain design tradeoffs, and include verification steps. Do not commit `.godot/`, imported caches, secrets, generated exports, or large source assets without prior agreement.
