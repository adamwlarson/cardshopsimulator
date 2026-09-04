# Card Shop Simulator — UI Wireflows v1

Status: Adopted (PM lock 2026-09-04)

## 1. Interaction principles

- The 3D shop remains the primary context; management surfaces open as focused overlays.
- Every consequential action shows cash, capacity, Attention, and timing effects before confirmation.
- Currency is formatted from integer cents. Destructive actions require explicit confirmation.
- Market UI displays noisy comps and confidence, never `true_market_cents`.
- Keyboard/mouse is the MVP input baseline. Focus order and readable text are required from the first implementation.

Persistent HUD: current phase/day, clock, cash, next major bill and days remaining, Attention, selected tool, and alerts. The cash/day foundation HUD is an interim subset.

## 2. Boot and new game

`Boot → Main Menu → New Game → Difficulty → Scenario briefing → Prep`

Difficulty cards summarize starting cash, weekly rent, capacity, Attention, event pressure, and recovery options from `BalanceConfig`. The confirmation screen names the first rent due date. Continue is disabled when no compatible save exists.

## 3. Daily shell

### Prep

HUD emphasizes cash forecast, incoming shipments, unresolved events, and opening checklist.

`Prep dashboard → [Buy | Inventory | Pricing | Layout | Staff | Events] → Open Shop confirmation → Floor`

Open Shop confirmation lists unpriced intake, blocked paths, unstaffed critical tasks, and low cash. Warnings inform; only invalid navigation or corrupted required state blocks opening.

### Floor

HUD emphasizes time, queue, customer requests, and remaining Attention.

`Customer/fixture selection → contextual action → preview cost/time → execute → world feedback`

Critical alerts stack by urgency without covering the register or selected customer. Repricing and stock movement show their Attention cost.

### Settle

`Close doors → transaction reconciliation → operating summary → bills/rent → event outcomes → insolvency check → Next Day`

The summary separates revenue, cost of goods, fees, payroll accrual, shrink, rent, and net cash movement. On every seventh day, weekly rent is a distinct ledger line.

## 4. Inventory flows

### Receive and locate

`Delivery/offer accepted → Intake list → verify quantity/condition → create StockLot → choose Location → available`

Mismatch sends the item to a review state. Canceling before confirmation leaves cash and inventory unchanged.

### Move stock

`Select lot/instance → Move → valid locations highlighted → capacity preview → confirm`

Case slots, shelf facings, backstock bins, and intake are visually distinct. Instance-tracked Singles/Graded show condition and provenance before movement.

### Sell or liquidate

Normal checkout relieves the configured lot and records revenue/cost basis. Liquidation previews discount, cash raised, and stock lost. Bulk liquidation requires a second confirmation.

## 5. Buying flows

Unified opportunity cards identify Distributor, buylist, marketplace, auction, trade, or shady source. They show known price, estimated landed cost, timing, required Attention, visible comps, confidence, capacity impact, and risk tags.

`Opportunity → inspect evidence → quantity/offer → forecast → confirm → cash reserve/ledger → incoming or intake`

Auction bids expose maximum commitment. Trades preview both sides and resulting cash/capacity. Shady offers state authenticity/reputation uncertainty without revealing a hidden outcome.

## 6. Pricing and demand signals

`SKU/instance → Pricing drawer → cost basis + comp range + age/confidence + current ask → new ask → projected margin/velocity language → apply`

Comp rows show source class, observed sale price, condition, and age. A range and confidence indicator summarize them. No UI field, tooltip, accessibility label, analytics payload intended for players, or customer speech may expose true market.

Bulk pricing is a later feature; MVP prices one SKU/instance at a time to keep consequences legible.

## 7. Customer and staff flows

Customer cards show request, patience, budget language, and service state—not exact hidden willingness to pay. Selecting a request presents satisfy, substitute, assist, or defer actions.

`Task appears → assign owner/staff → Attention/time preview → task active → outcome`

The staff panel shows shift, role, current task, queue, skill modifiers, morale, and wage. Overcommitting Attention is disallowed; reprioritizing warns about abandoned work.

## 8. Layout flow

`Prep → Layout mode → 10×8 grid → choose P0a prop → rotate/place → validate path/capacity → save`

Grid tiles represent 0.9 m. Overlay states: valid, collision, blocked customer path, blocked staff path, and inaccessible interaction face. P0a props are counter, glass cases, register, intake tray, shelves, backstock bins, and entrance.

Exiting with invalid mandatory paths offers return to edit or discard changes. Decorative props never silently add simulation capacity.

## 9. Events and tough decisions

Event modal structure: telegraph/evidence, decision deadline, 2–3 options, known immediate effects, uncertain-risk language, and confirm. Delayed consequences reference the originating choice in the settle log.

The ten playtest decisions in systems design §10 use the same comparison pattern: alternatives side-by-side, constrained resources visible, no false precision, and a post-decision audit event.

## 10. Insolvency and run end

Forecast warning appears before an obligation is due.

`Warning → cash plan → [liquidate | cancel orders | eligible financing | continue]`

On missed payment:

`Default notice → grace period + cure amount → recovery action → cured OR closure`

Easy/Normal may offer fictional high-risk financing; Hard does not. Closure explains the uncured obligation and preserves a run summary. Restart and return-to-menu are separate actions.

## 11. Error, save, and QA states

- Commands display a stable error code and plain-language recovery.
- Autosave occurs at phase boundaries and after confirmed major transactions.
- Loading validates save schema before entering the shop.
- Debug builds can overlay IDs, seeds, task queues, and true market only under a clearly marked QA mode.
- QA events include screen/flow, command, result, day/phase, selected difficulty, and relevant resource deltas.
