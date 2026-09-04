# UI Wireflows v1 — Card Shop Simulator

**Status:** Adopted + picker acceptance addendum (post playtest ff88fad)  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Depends on:** `systems-design-v1.md` §4.5, `fictional-set-bible-v1.md`  
**Scope:** MVP screens for buy confirm, price confirm, and serve/negotiate. Desktop/gamepad; 3D shop remains visible behind modal dim.

---

## 0. Global UI rules

1. **Never** show `true_market`, exact `p_buy`, `cert_valid`, or true condition until Inspect resolves (§4.5).
2. Money in **integer cents** in data; UI formats `$12.34`.
3. Confirm CTAs stay enabled on bad “feel” chips — warn, don’t soft-lock.
4. Escape / B = cancel without mutation; Enter / A = primary confirm when focused.
5. Every confirm emits QA instrumentation payloads (buy-confirm / demand_signal_shown) behind flag.

**Shared chrome:** title, close (X), primary (confirm), secondary (cancel). Dim 3D shop 40%.

---

## 1. Buy opportunity → demand-signal → confirm

### 1.1 Entry

| From | Trigger |
|------|---------|
| Prep phase “Opportunities” list | Select row |
| Floor — seller walk-in | Talk → “Review lot” |
| Rare shady/auction beat | Event modal → “Inspect deal” |


### 1.1a `BuyOpportunityList` picker (MVP acceptance — post ff88fad)

**Bug fixed against:** hardcoded single SKU (`AA-SKIE-ETB`) blocked §10 Dustway / distributor beats.

| Rule | Pass |
|------|------|
| Data-driven | UI binds a list of `BuyOpportunity` rows — **never** a single hardcoded SKU/channel |
| Prep list | Shows **all** open opportunities for the day (distributor weekly + marketplace lots + any scripted §10 beats) |
| Row fields | Channel · SKU/name · ask total · demand band chip · confidence |
| Select row | Opens `BuyOpportunityDetail` for **that** opportunity only |
| §10 #1/#2 | Day 1–2 must be able to open **Dustway ETB** (`AA-DUST-ETB`) pricing/buy path **and** a **Distributor** MOQ opportunity without debug cheats |
| Empty state | “No deals today” — not a fake SKIE row |

Scripted beats inject opportunities into the same list (tagged `beat_id` optional for QA).

### 1.2 Screen: `BuyOpportunityDetail`

```
┌─────────────────────────────────────────────┐
│  BUY · Marketplace lot              [X]     │
│  Dustway Explorer Box ×2                    │
├──────────────────┬──────────────────────────┤
│  [product proxy] │  Ask (exact)   $48.00    │
│                  │  Comp range    $52–$68   │
│                  │  Demand        WARM      │
│                  │  Confidence    LOW       │
│                  │  Condition     Photo only│
│                  │                Inspect★  │
├──────────────────┴──────────────────────────┤
│  After buy: Cash $7,952 → $7,904            │
│  Space: need 4 shelf · free 6  ✓            │
│  Last similar in-shop: $31 · 4d ago         │
├─────────────────────────────────────────────┤
│  [ Haggle ]     [ Cancel ]     [ Buy ]      │
└─────────────────────────────────────────────┘
```

**Field → §4.5:** ask exact; comp range; demand band; confidence; condition cue; cash/space; optional last sale.  
**Haggle:** opens one-shot counter field; on reject, opportunity dismissed.  
**Inspect★:** spends Attention; updates condition cue only (not comps).

### 1.3 Screen: `BuyConfirm` (second step if Buy pressed)

```
┌──────────────────────────────────────┐
│  Confirm purchase?                   │
│  Dustway ETB ×2 @ $24.00             │
│  Total                               │
│  Signals snapshot (read-only strip): │
│    Comp $52–$68 · WARM · LOW         │
│  [ Back ]              [ Confirm ]   │
└──────────────────────────────────────┘
```

On Confirm → inventory + cash mutation → close → toast “Lot added to backstock/shelf”.

### 1.4 Flow

```mermaid
flowchart LR
  List[Opportunity list] --> Detail[BuyOpportunityDetail]
  Detail -->|Haggle| Hag[One counter]
  Hag -->|Accept| Detail
  Hag -->|Reject| Gone[Opportunity gone]
  Detail -->|Inspect| Detail
  Detail -->|Buy| Confirm[BuyConfirm]
  Confirm -->|Back| Detail
  Confirm -->|Confirm| Commit[Mutate inventory/cash]
```

---

## 2. Price tag → §4.5 chips → confirm

### 2.1 Entry

| From | Trigger |
|------|---------|
| Case/binder/shelf interact | “Set price” |
| Inventory panel row | Price pencil |
| Decision beats #1/#7/#8 | Scripted focus |

### 2.2 Screen: `PriceEditor`

```
┌─────────────────────────────────────────────┐
│  PRICE · Skiefall Titan (NM)         [X]    │
│  Location: Showcase case · Case boost       │
├─────────────────────────────────────────────┤
│  Suggested (noisy)        $21.40            │
│  Your price     [  $24.00  ]   (−/+ $1)     │
│  vs suggest     +$2.60  (+12%)              │
│  Position       PREMIUM                     │
│  Demand         HOT                         │
│  Move feel      Walk risk                   │
├─────────────────────────────────────────────┤
│  [ Cancel ]                    [ Apply ]    │
└─────────────────────────────────────────────┘
```

**Chips:** Position = Undercut / Competitive / Premium; Move feel = Likely sits / Should move / Walk risk.  
Live-update chips as price field changes (debounced 100ms) using **noisy** market only.

### 2.3 Screen: `PriceConfirm` (optional if delta from prior list >15% or first list)

```
┌──────────────────────────────────────┐
│  Apply price $24.00?                 │
│  PREMIUM · HOT · Walk risk           │
│  [ Back ]              [ Confirm ]   │
└──────────────────────────────────────┘
```

Skip confirm when reopening editor and change <15% (Apply commits directly) — keeps UX snappy; big swings still gate.

### 2.4 Flow

```mermaid
flowchart LR
  Inv[Inventory / prop] --> Edit[PriceEditor]
  Edit -->|chips live| Edit
  Edit -->|Apply small Δ| Commit[Set listed_price]
  Edit -->|Apply large Δ| PC[PriceConfirm]
  PC --> Commit
```

---

## 3. Serve customer → negotiate

### 3.1 Entry

Customer at counter / interacted in queue → `CustomerServe`.

### 3.2 Screen: `CustomerServe`

```
┌─────────────────────────────────────────────┐
│  CUSTOMER · Spike · Patience ████░░         │
│  Wants: Bastion Captain (NM)                │
├──────────────────┬──────────────────────────┤
│  [portrait]      │  Your list     $5.00     │
│                  │  Demand        STEADY    │
│                  │  Position      Compet.   │
│                  │  Move feel     Should…   │
│                  │  (same §4.5 chips; no %) │
├──────────────────┴──────────────────────────┤
│  [ Pull backstock ]  [ Refuse ]             │
│  [ Negotiate −10% ]  [ Sell at list ]       │
└─────────────────────────────────────────────┘
```

**Negotiate:** one step ±10% (owner Attention cost); Spike may refuse → walk.  
**Refuse / walkout:** soft Rep tick per systems.  
**Buylist sellers:** reuse BuyOpportunityDetail layout with “You offer” instead of Ask.


### 3.2a Label rules (sell vs buylist) — fixes “Your list” misuse

| Context | Correct label | Must not say |
|---------|---------------|--------------|
| Customer **buying from shop** (Spike/etc.) | **Your list** = shop `listed_price` | Ask / You offer |
| Customer **selling to shop** (buylist) | **You offer** = our buylist bid | Your list / Ask |
| Shop **buying a BuyOpportunity** | **Ask** = seller’s exact ask (§4.5 A) | Your list |

### 3.3 Flow

```mermaid
flowchart TD
  Q[Queue] --> Serve[CustomerServe]
  Serve -->|Sell| Done[Cash + stock out]
  Serve -->|Negotiate| Serve
  Serve -->|Pull| Serve
  Serve -->|Refuse / timeout| Leave[Leave + Rep]
```

---

## 4. Art / Eng notes

| Element | Art | Eng |
|---------|-----|-----|
| Product proxy | Pack/ETB/card plane from bible | Bind SKU mesh + label |
| Band chips | Color: Cold blue → Hot amber; never rely on color alone (icon+text) | Enum → chip theme |
| Confidence | High shield / Med / Low eye icons | Channel → confidence |
| Modal dim | Keep P0a counter/case readable | UI layer above shop |

---

## 5. §10 beat ↔ bible card alignment

| Beat | Wireflow | Canon SKU / card (set bible) |
|------|----------|------------------------------|
| #1 Price seed ETBs | PriceEditor | `AA-DUST-ETB` (Dustway Explorer Box) |
| #2 Distributor MOQ | BuyOpportunityDetail | `AA-SKIE-BLST` / `AA-SKIE-ETB` mix |
| #4 Spike wants last staple | CustomerServe | **Bastion Captain** (`AA-BASE-088`) or **Arcbolt Adept** (`AA-BASE-078`) |
| #6 First rent + soft shelf | PriceEditor + BuyConfirm fire-sale | Dustway sealed (`AA-DUST-*`) |
| #7 Hype spike | PriceEditor | **Skiefall Titan** (`AA-SKIE-047`) |
| #8 Case slab vs singles | PriceEditor / inventory | **Empress of Updrafts** slab vs two chase singles (e.g. Titan + Paragon Glider) |

Scripted focus must use these names — no placeholders.

---

## 6. QA hooks

- Beats #1/#2/#4/#6/#7/#8 must open these flows with §4.5 fields visible **before** commit.
- Probe: player ranks deal quality above chance using only on-screen signals.
- Forbidden if UI shows exact true_market or sell-through %.

---

## 7. Out of MVP

- Multi-line price charts, live “N customers want this”, batch price tools, full buylist spreadsheet.
