# Card Shop Simulator — Systems Design v1

Status: Adopted (PM lock 2026-09-04)

## 1. Product intent

Card Shop Simulator is a cozy-but-serious 3D management game about keeping a neighborhood trading-card shop alive. The fantasy is not infinite growth; it is making informed decisions with incomplete information while building a place customers value. Every major system must reinforce at least one tension:

- liquidity versus an attractive buying opportunity;
- margin versus sales volume and trust;
- speculative upside versus hype and reprint risk;
- customer service versus finite staff Attention;
- broad assortment versus finite case and backstock space.

The MVP proves a readable day loop and a small set of consequential decisions. It does not simulate every real-world card-market detail.

## 2. Day loop and phases

Each day has three explicit phases. A phase transition is a save/checkpoint boundary and emits an event through `EventBus`.

### 2.1 Prep

The player reviews cash, bills, market signals, deliveries, and overnight events. They may buy inventory, accept or reject offers, move stock, set prices, schedule staff, and prepare fixtures. Time is paused while required decisions are unresolved.

### 2.2 Floor

The shop opens. Customers spawn, browse, request help, compare prices, queue, buy, sell, or leave. Time and staff Attention advance. The player can reprice or restock, but doing so consumes time/Attention and may leave other work uncovered.

### 2.3 Settle

Doors close. Sales, cost of goods, shrink, payroll accruals, and event effects settle into the ledger. Every seventh day is a weekly settle and charges rent. The player reviews results, addresses insolvency warnings, and chooses whether to continue.

Canonical loop: **buy → stock → sell → pay bills → upgrade → next day**.

## 3. Inventory domain

### 3.1 Inventory classes

- **Sealed:** boxes, packs, launch chests, and preconstructed products. Condition is normally sealed/damaged; provenance and allocation matter.
- **Singles:** fungible catalog cards until a copy needs instance-level condition or provenance.
- **Graded:** individually serialized slabs with grader, grade, certification, and authenticity state.
- **Accessories:** sleeves, binders, deck boxes, storage, and play supplies. Lower volatility and dependable basket-building utility.

### 3.2 Canonical data model

- `ProductSKU`: immutable catalog identity, class, set, name, dimensions, and baseline handling rules.
- `CardInstance`: one physical single when condition, acquisition cost, or provenance must be tracked separately.
- `SlabInstance`: one graded card with grader, grade, certification identifier, and verification state.
- `StockLot`: quantity acquired together with landed cost basis, condition, source, and acquisition day.
- `Location`: a case slot, shelf facing, counter tray, backstock bin, intake area, or transit state.

SKU identity is not location. A SKU may occupy multiple lots and locations. Cost basis is retained by lot; selling policy chooses which lot is relieved. Currency uses integer cents.

### 3.3 Capacity and movement

Normal starts with 24 case slots and 40 backstock bins. A case slot is a merchandising unit, not an arbitrary item count. Backstock capacity uses bins. Intake inventory is unavailable for sale until checked and located. Moving, checking, and pricing stock consumes Attention during Floor.

### 3.4 Acquisition channels

- **Distributor:** predictable cost and authenticity, constrained allocations, payment terms, release timing.
- **Buylist:** customer offers with condition uncertainty; strong margin potential and Attention cost.
- **Marketplace:** broad availability with shipping delay, fees, seller risk, and noisy comps.
- **Auction:** time-boxed opportunities, winner's-curse risk, and uncertain landed cost.
- **Trades:** conserve cash but exchange valuable stock and consume appraisal Attention.
- **Shady source:** unusually favorable offers with elevated counterfeit, reputation, and event risk. This is a fictional gameplay category, never instruction for evading law or platform policy.

Purchasing is atomic across cash reservation, expected fees, incoming lot, and source record. Failed transactions must not partially mutate state.

## 4. Economy and pricing

### 4.1 Ledger and cash

The ledger is append-only for the active save. Entries have day, phase, category, amount, source reference, and memo. Income and expenses update available cash only through ledger commands. Inventory purchases capitalize into lot cost basis; cost of goods is recognized on sale.

### 4.2 Bills and solvency

Normal difficulty starts at **$8,000** and charges **$1,200 weekly rent** at day 7, 14, and so on during Settle. Payroll, utilities, fees, debt, and event costs are later ledger categories. Forecasts may reserve cash but do not silently remove it.

### 4.3 Prices and spreads

A buy offer and shelf price are separate decisions. Suggested buy price considers visible comps, expected fees, condition risk, target margin, and time-to-sell. Suggested sell price considers cost basis, visible comps, demand, reputation, and desired velocity. The UI explains inputs without exposing hidden truth.

### 4.4 Market state

Each SKU may have hidden `true_market_cents`, demand velocity, volatility, supply pressure, and trend. These drive simulated transactions and event effects. Hidden state is deterministic under a seeded run for QA.

### 4.5 MVP demand-signal contract

The player never sees `true_market_cents` in UI, tooltips, exports intended for players, or customer dialogue. They receive noisy evidence:

- recent comparable sales with age, source quality, and condition;
- ranges rather than a magic exact price;
- partial trend arrows and demand language;
- customer requests and sell offers;
- release, reprint, tournament, and social-hype events.

`comp_noise_scalar` controls observation error by difficulty. Comps may be stale or sparse but may not lie in ways the simulation cannot explain. Debug tooling can expose true market only behind a QA/developer flag and must visually label it.

## 5. Customers

Six MVP archetypes define goals and behavior weights rather than rigid scripts:

1. **Collector:** seeks condition, scarcity, and specific singles/slabs; sensitive to trust.
2. **Competitive player:** seeks format-relevant cards and supplies; values availability and speed.
3. **Casual player:** browses sealed and accessories within a firm budget.
4. **Parent/Gift buyer:** needs guidance and readable choices; high service need, low catalog knowledge.
5. **Speculator:** follows trends, buys volume when momentum appears, and reacts sharply to price.
6. **Seller/Trader:** brings collections or trade offers; requires appraisal Attention and sufficient cash.

Each visit has a budget, patience, interests, price tolerance, service need, and trust response. Desire matching scores catalog fit, availability, asking price versus perceived value, condition, and substitutions. A failed match can become a request signal, not automatically a lost customer.

Customers must not know hidden market truth. Their willingness to pay is another noisy signal. Queues, ignored requests, rejected low offers, and counterfeit incidents can affect reputation.

## 6. Staff and Attention

**Attention** is the MVP labor currency. Normal begins each day with a pool of 100. Staff add or specialize Attention; tasks reserve or consume it.

Tasks include intake, condition checks, appraisals, restocking, checkout, customer guidance, cleaning, fraud review, and event response. Uncovered tasks become delay, lower confidence, abandonment, or shrink risk. Attention does not replace clock time; both can constrain a task.

Staff have role, wage, shift, skill tags, morale, and active assignment. MVP may begin with the owner only, but interfaces must accept multiple workers. Automation upgrades reduce Attention costs rather than creating free revenue.

## 7. Shop and layout

The authoritative grid uses `tile_size_m = 0.9`. The small shop is **10 × 8 tiles**, physically **9 × 7.2 m**, approximately **698 sq ft**. Simulation placement snaps to this grid while decorative art may overhang without occupying another tile.

Layout affects walkability, visibility, service distance, queue capacity, theft exposure, and merchandise capacity. Navigation must retain an entrance-to-counter path and accessible browsing paths.

### 7.1 MVP readable props

P0a readability gate requires these props to be identifiable without labels at gameplay camera distance:

- service counter;
- locked glass display cases;
- point-of-sale register;
- buylist/appraisal intake tray;
- wall or gondola shelving;
- backstock bins;
- entrance/exit and an obvious customer path.

The counter anchors service. Cases expose Singles/Graded stock. Shelves carry Sealed/Accessories. The intake tray separates unprocessed offers from sellable inventory.

## 8. Events

Events modify constraints and signals rather than grant arbitrary rewards. Categories include:

- releases, allocations, reprints, rotations, and tournament results;
- local conventions, school holidays, weather, and foot-traffic shifts;
- landlord, utility, equipment, staffing, and security incidents;
- hype spikes, corrections, rumors, and counterfeit waves;
- relationship opportunities with distributors and community groups.

Each event has eligibility, telegraph, choice window, options, immediate effects, delayed effects, and audit text. Normal per-check event chance is 0.18. Event RNG is seeded and logged for QA. Choices must state what the player could reasonably know while preserving uncertain outcomes.

## 9. Win, loss, and recovery

MVP success is surviving the scenario horizon with positive operating momentum and an open shop; later scenarios may add reputation or collection goals. There is no single exponential wealth target.

Bankruptcy is a process, not one surprise screen:

1. cash forecast warns of an upcoming obligation;
2. missed payment creates a default state and recovery window;
3. the player may liquidate stock, cut orders, negotiate eligible financing, or reduce costs;
4. failure to cure required obligations closes the shop and ends the run.

Loan-shark recovery is available on Easy and Normal only. It is disabled on Hard. It must carry explicit cost and risk and cannot be the optimal routine strategy. A run also loses if mandatory scenario obligations remain uncured after their grace periods.

## 10. Ten tough decisions and early playtest beats

These beats define the first systems playtest. Each must present legible alternatives and a measurable consequence:

1. Buy a limited distributor allocation or preserve cash for the first rent.
2. Put a hot sealed product in scarce case space or use that space for several reliable singles.
3. Price near the top comp for margin or undercut for faster turnover.
4. Accept a large buylist collection that consumes cash and appraisal Attention or decline it.
5. Trust a noisy hype signal and reorder or wait and risk missing demand.
6. Staff checkout during a rush or divert Attention to a high-value appraisal.
7. Stock broad low-margin accessories or deeper speculative sealed inventory.
8. Take an auction lot with uncertain condition and fees or buy predictable distributor stock.
9. Sell a rising card now to cover weekly rent or hold for possible upside.
10. Cure a cash crisis by liquidation/financing or risk bankruptcy while protecting premium stock.

Instrument offer viewed, decision selected, cash before/after, inventory exposure, customer outcomes, task coverage, phase duration, rent forecast visibility, and reason for run end. Early sessions should reach one weekly rent settle and at least four of these beats.

## 11. BalanceConfig

All tunable difficulty values live in typed `BalanceConfig` resources. Runtime systems read the selected resource; they do not define competing literals.

| Field | Easy | Normal | Hard |
| --- | ---: | ---: | ---: |
| Starting cash | $10,000 | $8,000 | $6,500 |
| Weekly rent | $900 | $1,200 | $1,500 |
| Tile size | 0.9 m | 0.9 m | 0.9 m |
| Case slots | 28 | 24 | 20 |
| Backstock bins | 48 | 40 | 32 |
| Attention pool | 120 | 100 | 85 |
| Event chance | 0.12 | 0.18 | 0.24 |
| Loan shark | enabled | enabled | disabled |
| Customer spawn-rate scalar | 1.15 | 1.00 | 0.85 |
| Shrink-rate scalar | 0.60 | 1.00 | 1.50 |
| Comp-noise scalar | 0.08 | 0.15 | 0.24 |

The curve values are initial locks, not claims of final balance. Changes require playtest evidence and an update to `difficulty-curves-v1.md`.

## 12. Module map and ownership

| Module | Owns | Emits/consumes |
| --- | --- | --- |
| `core` | phase clock, run state, BalanceConfig selection | phase/day transitions |
| `economy` | cash, ledger, bills, pricing observations | transaction, solvency, rent |
| `inventory` | catalog identities, instances, lots, locations | stock and movement |
| `customers` | archetypes, desires, visits, queues | arrival, request, sale intent |
| `shop` | grid, fixtures, capacity, navigation constraints | placement/capacity |
| `staff` | workers, shifts, tasks, Attention | assignment/task outcomes |
| `events` | eligibility, choices, seeded effects | event offered/resolved |
| `ui` | player presentation and commands | never owns simulation truth |
| `autoload` | narrow service entry points and EventBus | cross-domain coordination |

No module reads another module's private collections. Commands go to the owning service; outcomes cross boundaries as typed values/signals. Save schemas version domain records independently.

## 13. Engineering spike order

Implement vertical contracts in this order:

1. **Inventory:** SKU/instance/lot/location integrity and atomic movement.
2. **Economy:** ledger, acquisition, sale, weekly obligations, and solvency.
3. **Customers:** six archetypes, desire matching, queues, and transaction intent.
4. **Shop:** 10 × 8 grid, P0a props, capacity, and navigation.
5. **Staff:** tasks, shifts, and Attention allocation.
6. **Events:** seeded eligibility, choices, delayed effects, and audit trail.

Each spike must include deterministic tests and QA-observable events before the next system depends on it.
