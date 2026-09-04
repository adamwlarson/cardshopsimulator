# Card Shop Simulator — Difficulty Curves v1

Status: Adopted (PM lock 2026-09-04)

## 1. Contract

Difficulty changes pressure and information quality, not basic rules. All runtime values originate in typed `BalanceConfig` resources under `data/balance/`. Systems may derive values from these scalars but must not shadow them with difficulty literals.

## 2. Locked starting values

| Field | Easy | Normal | Hard |
| --- | ---: | ---: | ---: |
| `start_cash_cents` | 1,000,000 ($10,000) | 800,000 ($8,000) | 650,000 ($6,500) |
| `start_reputation` | 50 | 40 | 30 |
| `case_slots` | 28 | 24 | 20 |
| `backstock_bins` | 48 | 40 | 32 |
| `rent_small_weekly_cents` | 90,000 ($900) | 120,000 ($1,200) | 150,000 ($1,500) |
| `first_rent_due_day` | 7 | 7 | 7 |
| `attention_pool` | 120 | 100 | 85 |
| `event_chance_settle` | 0.12 | 0.18 | 0.24 |
| `loan_shark_enabled` | true | true | false |
| `tile_size_m` | 0.9 | 0.9 | 0.9 |
| `customer_spawn_mult` | 1.15 | 1.00 | 0.85 |
| `whale_spawn_mult` | 0.85 | 1.00 | 1.20 |
| `flipper_spawn_mult` | 0.75 | 1.00 | 1.35 |
| `shrink_mult` | 0.60 | 1.00 | 1.50 |
| `comp_noise_width_mult` | 0.70 | 1.00 | 1.50 |
| `demand_band_sigma` | 0.75 | 1.00 | 1.25 |
| `comp_mae_cap_sealed` | 0.08 | 0.12 | 0.18 |
| `comp_mae_cap_singles` | 0.10 | 0.16 | 0.24 |
| `comp_mae_cap_graded` | 0.14 | 0.20 | 0.30 |

Normal is the authored experience and balance reference. Easy gives more liquidity, labor tolerance, reliable information, and recovery capacity. Hard reduces slack and information quality; it must remain learnable and deterministic under a fixed seed.

## 3. Scalar interpretation

### Customer spawn rate

Multiply the owning customer system's baseline arrival rate by `customer_spawn_mult`. `whale_spawn_mult` and `flipper_spawn_mult` adjust those archetypes' eligible weights after the base arrival roll. These values change opportunity mix, not customers' available money. Queue capacity and service demand can still make more traffic costly.

### Shrink rate

Multiply eligible fixture/location shrink risk by `shrink_mult` after security, visibility, crowd, and event modifiers. Never remove inventory without a logged settle event and source context. Initial implementation may be a deterministic stub.

### Comp noise

`comp_noise_width_mult` scales the width of observation noise while generating visible comparable sales. `demand_band_sigma` controls overlap between customer demand bands. The class-specific MAE caps bound mean absolute error for Sealed, Singles, and Graded comp summaries. None of these fields changes hidden true market. Source quality, sample age, sample size, and condition shape the final distribution.

At zero noise, UI still shows observed comps rather than labeling truth. At higher noise, widen ranges and reduce confidence before adding extreme outliers.

## 4. Rent and bankruptcy pacing

Rent is weekly and posts during Settle on days divisible by seven. It is not amortized as a daily cash deduction. Forecast UI may show a daily planning equivalent but must label it as a forecast.

The first-week playtest target is:

- Easy: enough slack to recover from one poor medium purchase.
- Normal: rent competes credibly with one attractive allocation or buylist.
- Hard: a poor early concentration creates danger but still offers a skill-based recovery path.

Hard disables the loan-shark event. All difficulties retain liquidation and order cancellation where transaction state permits.

## 5. Capacity and layout

Physical grid dimensions remain 10×8 at 0.9 m across difficulty. Difficulty changes usable merchandising/storage capacity, not the building scale. Case-slot/backstock differences can be represented through fixture availability, locked capacity, or scenario loadout; they may not create invisible space.

## 6. Event pressure

`event_chance_settle` is evaluated once at eligible Settle checks, not every frame. Eligibility and cooldown run before chance. A failed roll has no hidden penalty. Event selection and rolls are seeded and included in QA logs.

Higher difficulty may increase event frequency but cannot select events whose counterplay systems are unavailable. Critical obligations must be telegraphed independently of event chance.

## 7. Attention

The pool refreshes at the defined day boundary. Scheduled staff and upgrades can modify available Attention after the base config is read. Tasks expose final cost and modifiers before commitment. Difficulty should not secretly alter a task cost if the UI cannot explain it.

## 8. BalanceConfig resource shape

Engineering treats these exported names as the ratified serialization/API contract:

```gdscript
class_name BalanceConfig
extends Resource

enum Difficulty { EASY, NORMAL, HARD }

@export var difficulty: Difficulty = Difficulty.NORMAL
@export var start_cash_cents: int = 800_000
@export var start_reputation: int = 40
@export var case_slots: int = 24
@export var backstock_bins: int = 40
@export var rent_small_weekly_cents: int = 120_000
@export var first_rent_due_day: int = 7
@export var attention_pool: int = 100
@export var event_chance_settle: float = 0.18
@export var loan_shark_enabled: bool = true
@export var tile_size_m: float = 0.9
@export var customer_spawn_mult: float = 1.0
@export var whale_spawn_mult: float = 1.0
@export var flipper_spawn_mult: float = 1.0
@export var shrink_mult: float = 1.0
@export var comp_noise_width_mult: float = 1.0
@export var demand_band_sigma: float = 1.0
@export var comp_mae_cap_sealed: float = 0.12
@export var comp_mae_cap_singles: float = 0.16
@export var comp_mae_cap_graded: float = 0.20
```

Canonical assets are `balance_easy.tres`, `balance_normal.tres`, and `balance_hard.tres`. Renaming a serialized field or asset requires an explicit migration.

## 9. Balance change process

Every adjustment records:

1. hypothesis and affected tough decision;
2. before/after values;
3. deterministic test seed or playtest cohort;
4. measured effect on cash, stock exposure, service, and run ends;
5. decision to keep, revert, or test further.

Automated tests enforce starting-cash ordering, Normal locked values, Hard financing lockout, and config-driven capacity. Telemetry must segment by config difficulty and version.
