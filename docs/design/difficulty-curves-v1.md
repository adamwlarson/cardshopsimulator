# Difficulty Curves v1 — Easy / Normal / Hard

**Status:** Ready for PM adoption — Normal = systems-design bible defaults  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Depends on:** `systems-design-v1.md` (Normal = baseline), `fictional-set-bible-v1.md`, `ui-wireflows-v1.md`  
**Rule:** Same systems, formulas, and §4.5 UI on all difficulties. Only `BalanceConfig` scalars + starting kit + fail recovery change. No “god mode” perfect comps on Easy.

---

## 0. Design intent

| Diff | Player fantasy | Fail feel |
|------|----------------|-----------|
| **Easy** | Learn the shop; mistakes teach | Soft landings; loan shark OK |
| **Normal** | Fair-but-hard retail | Careless bankrupt ~30–45 days |
| **Hard** | Brutal liquidity & fog | Instant game over on bankrupt; thinner signals |

**Invariant across all:** §4.5 field list, forbidden UI fields, module boundaries, §10 beat *sequence* (timing/numbers may scale).

---

## 1. Starting kit

| Knob | Easy | Normal | Hard |
|------|------|--------|------|
| Cash | $12,000 | $8,000 | $5,500 |
| Reputation | 50 | 40 | 30 |
| Case slots | 28 | 24 | 20 |
| Backstock bins | 48 | 40 | 32 |
| Seed sealed | 4 blasters + 2 Dust ETBs + **1 Skie blaster** | 4 blasters + 2 Dust ETBs | 3 blasters + 2 Dust ETBs |
| Seed staples (named) | 10 playable rares | 8 | 5 |
| Bulk binder cards (`seed_bulk_cards`) | 100 | **80** | 50 |
| Accessories | sleeves 300 / top 75 | 200 / 50 | 120 / 30 |
| Staff | Owner + **trainee cashier** (Reliability 0.85, 3 days free then $80) | Owner only | Owner only |
| First rent due | Day **10** | Day **7** | Day **7** (no grace) |

---

## 2. Economy & demand scalars (`BalanceConfig`)

Multipliers apply to Normal baseline unless noted as absolute.

| Knob | Easy | Normal | Hard |
|------|------|--------|------|
| Customer spawn / hour | ×1.25 | ×1.0 | ×0.85 |
| Whale weight (at same Rep) | ×1.4 | ×1.0 | ×0.7 |
| Flipper weight | ×0.7 | ×1.0 | ×1.35 |
| Gross margin target blend | 30–40% | 25–35% | 20–30% |
| Distributor discount vs MSRP | 35–42% | 30–40% | 28–35% |
| Online fee | 6% | 8% | 10% |
| Daily shrink base | 0.1% | 0.2% | 0.35% |
| Unstaffed shrink add | +0.25% | +0.5% | +0.75% |
| Rent (Small weekly) | $1,000 | $1,200 | $1,350 |
| Wage mult | ×0.9 | ×1.0 | ×1.1 |
| Event chance / settle | 12% | 18% | 26% |
| Negative event weight | ×0.7 | ×1.0 | ×1.4 |
| Market daily drift σ | narrower | baseline U(0.98,1.02) | wider (±3% class vol) |
| Comp noise width `w` | ×0.7 | ×1.0 | ×1.25 |
| Demand band σ | 0.09 | 0.12 | 0.16 |
| Research cost | $30 + Att 10 | $50 + Att 15 | $70 + Att 18 |
| Inspect accuracy | 92% | 85% | 75% |
| Shady fake-slab rate | 4% | 8% | 14% |

**Attention pool:** Easy 120 / Normal 100 / Hard 85. Action costs unchanged (scarcity via pool).

---

## 3. §4.5 fairness bars by difficulty

| Gate | Easy | Normal | Hard |
|------|------|--------|------|
| Comp MAE vs true | ≤10% | ≤12% | ≤15% |
| Band within ±1 | ≥85% | ≥80% | ≥70% |
| Hot↔Cold inversion ban | Yes (no fog) | Yes | Yes — but fog events more common |
| Specialist narrow factor | Same | Same | Same (skill still rewarded) |

Hard is **foggiest**, not unfair: signals stay correlated; MAE bar loosens slightly.

---

## 4. Fail / recovery

| | Easy | Normal | Hard |
|--|------|--------|------|
| Bankrupt | Loan shark once | Loan shark once | **Instant game over** |
| Loan shark | +$6k, −$150/day ×40, Rep −5 | +$5k, −$200/day ×40, Rep −10 | — |
| Missed rent → lose | 3 weeks | 2 weeks | 2 weeks |
| Ironman destitution optional | Off by default | Off | **On** by default |

---

## 5. Win-mode tweaks

Same modes (Survive Year 1 / Flagship / Liquidity / Sandbox). Threshold deltas:

| Mode check | Easy | Normal | Hard |
|------------|------|--------|------|
| Survive Y1 Rep floor | 30 | 40 | 50 |
| Flagship cash | $40k | $50k | $65k |
| Liquidity king cash | $75k | $100k | $125k |

---

## 6. §10 beat timing (MVP-required set)

Beats **keep the same decisions**; days shift slightly on Easy only.

| Beat | Easy day | Normal day | Hard day | Number tweaks |
|------|----------|------------|----------|---------------|
| #1 Price Dust ETBs | 1 | 1 | 1 | Hard: softer shelf already |
| #2 Distributor MOQ | 2 | 2 | 2 | Hard: worse MOQ / less discount |
| #4 Spike last staple | 5 | 4 | 3–4 | Same cards (Bastion / Arcbolt) |
| #6 First rent crunch | 10 | 7 | 7 | Easy delayed rent |
| #7 Titan hype | 10–12 | 8–10 | 6–8 | Hard: spike sharper, cash tighter |
| #8 Empress slab vs singles | 14 | 12 | 10 | Same SKUs |

Non-MVP beats (#3/#5/#9/#10) follow same relative spacing.

---

## 7. Falsifiable playtest targets

| Diff | Target |
|------|--------|
| Easy | ≥80% of new players survive to day 21; median “tough-but-fair” ≥3.5/5 |
| Normal | Careless/scripted-passive bankrupt **30–45** days; skilled ≥60% reach day 60 |
| Hard | Skilled survival to day 30 ≈ **40–60%**; loan shark never offered |

QA: run passive-bot + skilled-bot harness per diff before human playtests.

---

## 8. Eng handoff — `BalanceConfig` resource shape

Godot 4 typed resource (GDScript sketch). **Normal column = systems-design bible defaults** (ship as `res://balance/balance_normal.tres`; Easy/Hard are sibling `.tres` or one resource with enum).

```gdscript
class_name BalanceConfig
extends Resource

enum Difficulty { EASY, NORMAL, HARD }

@export var difficulty: Difficulty = Difficulty.NORMAL

# --- Shop metric (locked with Art; not a difficulty scalar, but lives on BalanceConfig for one load path) ---
@export var tile_size_m: float = 0.9
# Grid size is NOT on BalanceConfig — shop constants: GRID_WIDTH=10, GRID_HEIGHT=8 (Small). Medium/Large grids = future expand doc.

# --- Starting kit (cents where money) ---
@export var start_cash_cents: int = 800_000          # $8,000
@export var start_reputation: int = 40               # 0–100
@export var case_slots: int = 24
@export var backstock_bins: int = 40
@export var seed_blasters: int = 4
@export var seed_dust_etbs: int = 2
@export var seed_skie_blasters: int = 0              # Easy: 1
@export var seed_named_staples: int = 8
@export var seed_bulk_cards: int = 80             # systems §2.5 binder C/U; Easy 100 / Hard 50
@export var seed_sleeves: int = 200
@export var seed_toploaders: int = 50
@export var start_with_trainee_cashier: bool = false # Easy: true
@export var trainee_free_days: int = 3               # Easy only; after that wage from staff table ($80/day Cashier)
@export var first_rent_due_day: int = 7              # Easy: 10

# --- Economy / demand ---
@export var customer_spawn_mult: float = 1.0
@export var whale_weight_mult: float = 1.0
@export var flipper_weight_mult: float = 1.0
@export var distributor_discount_min: float = 0.30   # vs MSRP
@export var distributor_discount_max: float = 0.40
@export var online_fee: float = 0.08
@export var shrink_daily_base: float = 0.002
@export var shrink_unstaffed_add: float = 0.005
@export var rent_small_weekly_cents: int = 120_000   # $1,200
@export var wage_mult: float = 1.0
@export var event_chance_settle: float = 0.18
@export var negative_event_weight_mult: float = 1.0
@export var market_drift_low: float = 0.98
@export var market_drift_high: float = 1.02

# --- Attention / fog (§4.5) ---
@export var attention_pool: int = 100
@export var comp_noise_width_mult: float = 1.0       # scales channel w
@export var demand_band_sigma: float = 0.12
@export var research_cost_cents: int = 5_000         # $50
@export var research_attention: int = 15
@export var inspect_accuracy: float = 0.85
@export var shady_fake_slab_rate: float = 0.08

# --- §4.5 fairness bars (QA harness) ---
@export var fair_comp_mae_max: float = 0.12          # ≤12%
@export var fair_band_within1_min: float = 0.80      # ≥80%
@export var fair_forbid_hot_cold_invert: bool = true

# --- Fail / recovery ---
@export var loan_shark_enabled: bool = true          # Hard: false
@export var loan_shark_cash_cents: int = 500_000
@export var loan_shark_daily_cents: int = 20_000
@export var loan_shark_days: int = 40
@export var loan_shark_rep_hit: int = 10
@export var missed_rent_weeks_to_lose: int = 2       # Easy: 3
@export var ironman_destitution_default: bool = false # Hard: true

# --- Win thresholds ---
@export var survive_y1_rep_floor: int = 40
@export var flagship_cash_cents: int = 5_000_000
@export var liquidity_king_cash_cents: int = 10_000_000
```

**Easy/Hard:** override fields per `difficulty-curves-v1.md` §1–§5 tables (do not fork formulas).

**Rules:**
- Default load **Normal**.
- Mid-save difficulty change: **disallowed** in MVP.
- Unit tests: each diff loads; Easy `start_cash_cents` > Normal > Hard; Hard `loan_shark_enabled == false`; Normal values match this sketch exactly.

---


### §8 clarifications (2026-09-04 Eng ratification)

1. **`tile_size_m = 0.9`** — on BalanceConfig (single load path); value locked with Art; **do not** vary by Easy/Normal/Hard.
2. **Grid size** — `GRID_WIDTH=10`, `GRID_HEIGHT=8` are **shop constants** (not difficulty scalars). Expansion tiers later may add alternate constants; not exported on BalanceConfig for MVP.
3. **Expansion rents** — MVP ships **`rent_small_weekly_cents` only**. Medium/Large weekly rents stay in systems-design §7.3 until expand ships; then add `rent_medium_weekly_cents` / `rent_large_weekly_cents`.
4. **Easy trainee cashier** — `start_with_trainee_cashier` + `trainee_free_days` (default 3) are BalanceConfig. Post-free wage = staff table Cashier **$80/day** (not duplicated on BalanceConfig).
5. **Gross margin target blend** (§2) — **QA / design playtest target only**; omit from Resource.
6. **Attention action costs** — correctly **absent** from BalanceConfig (pool-only scarcity); costs stay in systems-design §6.2 constants.

7. **`seed_bulk_cards`** — binder commons/uncommons count (systems §2.5). Normal default **80**; Easy 100 / Hard 50. Eng shipped this field; doc folded 2026-09-04.

## 9. Out of scope

- Per-archetype AI difficulty  
- Custom slider sandbox  
- New UI fields beyond §4.5  

---

## 10. Status of related nits

- Small shop usable **~700 sq ft** (10×8 @ 0.9 m ≈ 698; “cozy 700”) — already in systems-design §1/§7.
