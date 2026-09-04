# Fictional Set Bible v1 — Card Shop Simulator

**Status:** Draft for PM / Eng / Art / QA  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Depends on:** `systems-design-v1.md`  
**IP rule:** All names, mechanics labels, and art briefs are **original fiction**. No real TCG names, logos, or card text.

---

## 0. Purpose

Give Eng/Art concrete SKUs, rarities, and demand tags so inventory, pricing, and events can ship without real-world licensing. Balance hooks map to systems design demand bands and market events.

---

## 1. Game world brand

| Field | Value |
|-------|-------|
| TCG name | **Aether Arc** |
| Publisher (in-world) | Northspire Games |
| Format | Constructed + casual collect; shop cares about **sealed, singles, graded slabs, accessories** |
| Player-facing short | "Arc" |

**Tone:** Bright speculative adventure (explorers, sky-cities, relics) — readable icons, not grimdark. Aligns with Art’s cozy-serious retail: product pops on warm wood/glass.

---

## 2. Card anatomy (data)

```
CardDef {
  id,                # e.g. AA-BASE-087
  set_id,
  collector_number,  # int
  name,
  rarity: C|U|R|SR|CR,   # Common..Chase Rare
  finish_default: NORMAL|FOIL,
  tags[],            # staple, chase, bulk, archetype:aggro|control|mid, legendary
  base_market_cents, # Normal NM seed
  foil_mult,         # default 1.8
  art_brief          # one-line for proxy texture
}
```

**Finishes in MVP:** `NORMAL`, `FOIL` only. (Alt-art / textured = post-MVP.)

**Condition** is instance-level (systems §2), not on CardDef.

---

## 3. Rarity & pull fantasy (shop-facing)

| Rarity | Code | Sealed density (flavor) | Shop role |
|--------|------|-------------------------|-----------|
| Common | C | High | Bulk binder filler; low $ |
| Uncommon | U | Medium | Binder depth |
| Rare | R | Low | Playables / light chase |
| Super Rare | SR | Very low | Staples & mid chase |
| Chase Rare | CR | Tiny | Whale bait; case / grade targets |

**Grading targets (MVP):** SR foil + any CR. Commons almost never worth grading.

---

## 4. Set roster (MVP ship 3 sets)

### 4.1 Calendar (in-game)

| Set ID | Name | Code | Status at day 0 | Weekly rent-era role |
|--------|------|------|-----------------|----------------------|
| `AA-BASE` | **Aether Arc: Foundations** | ARC | Evergreen core | Staples live here |
| `AA-SKIE` | **Skiefall Ascension** | SKI | **Current** (hype) | Sealed movers |
| `AA-DUST` | **Dustway Chronicles** | DUS | **Previous** (cooling) | Stale sealed risk |

**Rotation hook:** Every ~90 in-game days, oldest non-BASE constructed set enters **Extended** (demand ↓ on tournament staples; casual/collect tags milder). Telegraph via Research / Specialist (systems §4.5).

### 4.2 Sealed SKUs (per set)

| SKU suffix | Product | Contents (flavor) | Shelf units | Typical margin trap |
|------------|---------|-------------------|-------------|---------------------|
| `-PKT` | Booster pack | 10 cards | 0.25 | Impulse, thin margin |
| `-BLST` | Blaster | 6 packs | 1 | Volume |
| `-ETB` | Explorer Box | 8 packs + accessories promo | 2 | Hype → dump |
| `-BOX` | Booster box | 24 packs | 4 | Cash lock |
| `-TIN` | Collector tin | 3 packs + 1 foil promo | 1 | Seasonal |

Full SKU id = `{set_id}{suffix}` e.g. `AA-SKIE-ETB`.

### 4.3 Accessories (set-agnostic SKUs)

| SKU | Name | Role |
|-----|------|------|
| `ACC-SLV-60` | Soft sleeves 60ct | Impulse |
| `ACC-TOP-25` | Toploaders 25ct | Singles protect |
| `ACC-BND-3x3` | 3×3 binder | Storage upsell |
| `ACC-DICE-SET` | Arc dice set | Low $ flavor |

---

## 5. Foundations (`AA-BASE`) — staple spine

Ship **40 sellable named cards** for MVP (rest can be generic bulk rows). Named list:

| # | Name | R | Tags | Seed market NM | Art brief |
|---|------|---|------|----------------|-----------|
| 012 | Skyward Recruit | C | bulk | $0.15 | Young explorer |
| 027 | Relay Drone | C | bulk | $0.20 | Small bot |
| 041 | Cobble Barrier | U | staple, archetype:control | $1.50 | Stone shield |
| 055 | Windstep Courier | U | staple, archetype:aggro | $2.00 | Messenger mid-leap |
| 063 | Market Mediator | U | staple | $1.25 | Trader NPC wink |
| 078 | Arcbolt Adept | R | staple, archetype:aggro | $4.50 | Mage casting |
| 088 | Bastion Captain | R | staple, archetype:mid | $5.00 | Officer portrait |
| 094 | Ledger Sphinx | R | staple, archetype:control | $6.50 | Sphinx + books |
| 101 | Northspire Charter | SR | staple | $12.00 | Glowing contract |
| 108 | Aetherheart Engine | SR | staple, chase | $18.00 | Core reactor |
| 112 | Crown of Thermals | CR | chase, legendary | $45.00 | Floating crown |
| 115 | The First Cartographer | CR | chase, legendary | $60.00 | Mapmaker legend |

*Foil seed = NM × `foil_mult` 1.8 (CR foil 2.2).*  
Remaining numbers 001–120: generate as `Bulk Common/Uncommon {n}` with $0.10–$0.80; Eng may data-drive.

**Shop teaching use:** Day-4 Spike wants last **Bastion Captain** or **Arcbolt Adept** (decision #4).

---

## 6. Skiefall Ascension (`AA-SKIE`) — current hype

| # | Name | R | Tags | Seed market NM | Notes |
|---|------|---|------|----------------|-------|
| 003 | Zephyr Cadet | C | bulk | $0.25 | |
| 019 | Cloudpiercer | U | mid | $1.75 | |
| 034 | Storm Auctioneer | R | chase-lite | $7.00 | Flipper magnet if mispriced |
| 047 | Skiefall Titan | SR | chase, staple | $22.00 | Hype spike event target |
| 052 | Empress of Updrafts | CR | chase, legendary | $75.00 | Whale / grade bait |
| 058 | Paragon Glider | SR | chase | $16.00 | |
| 061 | Ticket to Skie | R | staple | $5.50 | |

Sealed: `AA-SKIE-*` carries **Warm/Hot** demand at day 0. Influencer/pro-tour events bias tags `chase` on 047/052.

---

## 7. Dustway Chronicles (`AA-DUST`) — cooling set

| # | Name | R | Tags | Seed market NM | Notes |
|---|------|---|------|----------------|-------|
| 011 | Sandwaker | C | bulk | $0.10 | |
| 022 | Ruin Broker | U | — | $0.80 | |
| 039 | Dustway Colossus | SR | chase-faded | $9.00 | Was $28 at release |
| 044 | Glass Mirage | R | — | $2.50 | |
| 050 | Relic of the Dry Sea | CR | chase-faded | $20.00 | Still grade-able |

Sealed ETBs/blasters start **Steady→Cold**; decision #1–2 teach dump vs hold. Rotation event can push staples further down.

---

## 8. Demand tags → systems

| Tag | Demand bias | Events that amplify |
|-----|-------------|---------------------|
| `staple` | Steady baseline | Rotation **hurts**; convention mild ↑ |
| `chase` | Volatile | Influencer spike, set release |
| `chase-faded` | Cold drift | Glut, recession |
| `bulk` | Cold always | — |
| `legendary` | Whale weight | Rep ≥75 spawn bias |

`true_demand` seed = f(tags, set_status, events). UI only shows bands (§4.5).

---

## 9. Graded slabs (MVP)

- Eligible: SR/CR with `finish FOIL` or any CR.
- Graders (fiction): **Prism Grade**, **Vaultmark**.
- Label string: `{grader} {grade}` e.g. `Prism 10`, `Vaultmark 9.5`.
- Case weight 2× singles; seed markets = raw foil × grade_mult (9.5→1.6, 10→2.4) — Eng owns table in BalanceConfig.

---

## 10. Art / Eng handoff

**Art:** Proxy textures per named card (table art_brief); shared meshes for pack/ETB/box/tin/slab per VISUAL_DIRECTION. Set symbols: ARC circle, SKI wing, DUS mesa icon (simple decals).

**Eng:** `CardDef` + `SetDef` resources; generate bulk rows; SKU table for sealed/accessories; wire tags into customers + events.

**QA:** Use named staples/chases in §10 beats (#1 Dust ETB, #4 Bastion/Arcbolt, #7 Skiefall Titan hype, #8 Empress slab vs two chase singles).

---

## 11. Out of scope (v1)

- Full 300-card spoiler per set
- Real rules text / deck legality engine
- Cross-set mashup products
- Autographs / serials

---

## 12. Next

UI wireflows: buy opportunity → demand-signal panel → confirm; price tag → §4.5 chips → confirm; serve customer negotiate.
