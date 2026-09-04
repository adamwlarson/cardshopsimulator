# Card Shop Simulator — Difficulty Curves v1

Status: Adopted (PM lock 2026-09-04)

## 1. Contract

Difficulty changes pressure and information quality, not basic rules. All runtime values originate in typed `BalanceConfig` resources under `data/balance/`. Systems may derive values from these scalars but must not shadow them with difficulty literals.

## 2. Locked starting values

| Field | Easy | Normal | Hard |
| --- | ---: | ---: | ---: |
| `starting_cash_cents` | 1,000,000 ($10,000) | 800,000 ($8,000) | 650,000 ($6,500) |
| `weekly_rent_cents` | 90,000 ($900) | 120,000 ($1,200) | 150,000 ($1,500) |
| `tile_size_m` | 0.9 | 0.9 | 0.9 |
| `case_slots` | 28 | 24 | 20 |
| `backstock_bins` | 48 | 40 | 32 |
| `attention_pool` | 120 | 100 | 85 |
| `event_chance` | 0.12 | 0.18 | 0.24 |
| `loan_shark_enabled` | true | true | false |
| `customer_spawn_rate_scalar` | 1.15 | 1.00 | 0.85 |
| `shrink_rate_scalar` | 0.60 | 1.00 | 1.50 |
| `comp_noise_scalar` | 0.08 | 0.15 | 0.24 |

Normal is the authored experience and balance reference. Easy gives more liquidity, labor tolerance, reliable information, and recovery capacity. Hard reduces slack and information quality; it must remain learnable and deterministic under a fixed seed.

## 3. Scalar interpretation

### Customer spawn rate

Multiply the owning customer system's baseline arrival rate by `customer_spawn_rate_scalar`. It changes opportunity volume, not customers' available money. Queue capacity and service demand can still make more traffic costly.

### Shrink rate

Multiply eligible fixture/location shrink risk by `shrink_rate_scalar` after security, visibility, crowd, and event modifiers. Never remove inventory without a logged settle event and source context. Initial implementation may be a deterministic stub.

### Comp noise

`comp_noise_scalar` is the target relative observation-error scale applied while generating visible comparable sales. It is not a direct price multiplier and never changes hidden true market. Source quality, sample age, sample size, and condition should shape the final distribution.

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

`event_chance` is evaluated only at documented event checks, not every frame. Eligibility and cooldown run before chance. A failed roll has no hidden penalty. Event selection and rolls are seeded and included in QA logs.

Higher difficulty may increase event frequency but cannot select events whose counterplay systems are unavailable. Critical obligations must be telegraphed independently of event chance.

## 7. Attention

The pool refreshes at the defined day boundary. Scheduled staff and upgrades can modify available Attention after the base config is read. Tasks expose final cost and modifiers before commitment. Difficulty should not secretly alter a task cost if the UI cannot explain it.

## 8. Balance change process

Every adjustment records:

1. hypothesis and affected tough decision;
2. before/after values;
3. deterministic test seed or playtest cohort;
4. measured effect on cash, stock exposure, service, and run ends;
5. decision to keep, revert, or test further.

Automated tests enforce starting-cash ordering, Normal locked values, Hard financing lockout, and config-driven capacity. Telemetry must segment by config difficulty and version.
