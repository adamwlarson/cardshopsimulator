# Aether Arc TCG — Fictional Set Bible v1

Status: Adopted (PM lock 2026-09-04)

## Purpose and IP boundary

**Aether Arc TCG** is the wholly fictional card game used by Card Shop Simulator. Game data, packaging, dialogue, props, and screenshots must use this universe or generic retail language. Do not use real TCG names, set codes, logos, card frames, rarity symbols, product silhouettes, grading brands, or recognizable character analogues.

This bible establishes enough internal consistency for Engineering, Art, Writing, and QA. It is not a complete playable card-game rules document.

## World premise

Aether is a navigable current connecting floating bastions, storm belts, and buried roads. Arcwrights bind routes into temporary sigils to move people, memories, and machines. The fiction emphasizes explorers, civic crews, weather, trade, and recovered history rather than grim warfare.

Visual motifs include route lines, brass instruments, glass prisms, canvas travel gear, layered maps, and luminous cyan/amber aether. Names should be readable at a glance and avoid direct genre-franchise echoes.

## Canonical sets

### AA-BASE — Foundations

The evergreen introductory set. It presents the five major routes, city bastions, and core Arcwright tools. Palette: warm limestone, deep teal, parchment, and brass. Product packaging should feel dependable and established.

Representative cards:

| ID | Name | Rarity | Role |
| --- | --- | --- | --- |
| `AA-BASE-001` | First Route Survey | Common | iconic introductory action |
| `AA-BASE-034` | Lanternline Mechanic | Uncommon | utility character |
| `AA-BASE-087` | Bastion Captain | Rare | recognizable collector single |
| `AA-BASE-144` | Atlas of Returning | Mythic | premium chase card |

Canonical sealed IDs include `AA-BASE-BST` (booster), `AA-BASE-DSP` (booster display), and `AA-BASE-STR` (starter).

### AA-SKIE — Skiefall Ascension

A high-altitude expedition set about broken sky routes, storm couriers, and falling islands. Palette: cobalt, cloud white, electric cyan, and silver. Demand begins high because it is the newest competitive release in the MVP timeline.

Representative cards:

| ID | Name | Rarity | Role |
| --- | --- | --- | --- |
| `AA-SKIE-011` | Updraft Apprentice | Common | accessible character |
| `AA-SKIE-063` | Prismwing Surveyor | Uncommon | collector-friendly creature |
| `AA-SKIE-142` | Stormglass Courier | Uncommon | tournament utility signal |
| `AA-SKIE-201` | Crown Above Thunder | Mythic | volatile chase card |

Canonical sealed IDs include `AA-SKIE-BST`, `AA-SKIE-DSP`, and `AA-SKIE-ETB`. In-world customer-facing copy calls `AA-SKIE-ETB` the **Skiefall Ascension Launch Chest**; `ETB` remains an internal SKU suffix only.

### AA-DUST — Dustway Chronicles

A frontier-history set following caravans that rediscover buried ground routes beneath the floating world. Palette: rust, ochre, midnight violet, canvas, and weathered steel. It supports slower collector demand and event-driven rediscovery.

Representative cards:

| ID | Name | Rarity | Role |
| --- | --- | --- | --- |
| `AA-DUST-019` | Dustway Cartographer | Rare | story and collector card |
| `AA-DUST-072` | Milemarker Automaton | Uncommon | utility artifact |
| `AA-DUST-118` | Caravan at Last Light | Rare | display-friendly landscape |
| `AA-DUST-199` | The Road Beneath | Mythic | long-tail chase card |

Canonical sealed IDs include `AA-DUST-BST`, `AA-DUST-DSP`, and `AA-DUST-ETB`. Customer-facing copy calls `AA-DUST-ETB` the **Dustway Chronicles Launch Chest**.

## ID and SKU rules

- Set code: `AA-BASE`, `AA-SKIE`, or `AA-DUST`.
- Card catalog ID: `<SET>-<three-digit collector number>`, for example `AA-BASE-087`.
- Conditioned single SKU: `<card-id>-<condition>`, such as `AA-BASE-087-NM`.
- Sealed product: `<SET>-<product suffix>`.
- Accessories use `ACC-*`; the MVP sleeve SKU is `ACC-SLV-60`, **Arcguard Sleeves (60)**.
- Slab instances and individual cards append save-local instance IDs; those IDs are not catalog SKUs.

Allowed condition suffixes are `M`, `NM`, `PL`, and `DMG`. Localized display names do not change IDs.

## Product and packaging rules

Packaging must carry the Aether Arc wordmark placeholder, set title, fictional age/rating marks, product count, and a unique set motif. It must not mimic a real product's exact proportions, trade dress, color blocking, or icon placement.

The P0 art pass may use abstract box art and generated typographic labels. AI-generated imagery is filler only and cannot define canon, ship as key art, or bypass legal/art review.

## Rarity and treatment language

Rarity tiers are Common, Uncommon, Rare, and Mythic. Optional treatments are Foil, Route-Etched, and Panorama. Avoid proprietary rarity or treatment names associated with real games. Price/demand data treats a treatment as a distinct catalog identity even when the base card number is shared.

## Gameplay-facing market profile

- `AA-BASE`: stable supply, moderate evergreen demand, lower volatility.
- `AA-SKIE`: strong launch demand, constrained allocation, high event sensitivity.
- `AA-DUST`: softer initial velocity, collector spikes, moderate scarcity.
- `ACC-*`: low volatility, dependable replenishment, modest margin.

These are simulation priors, not values shown directly to players. UI follows the noisy-comps contract in systems design §4.5.

## Writing guardrails

Use sincere retail and community language. Avoid parodying real players, stores, grading services, publishers, or scandals. Shady-source and counterfeit stories concern invented Aether Arc goods and should frame due diligence as responsible shopkeeping.
