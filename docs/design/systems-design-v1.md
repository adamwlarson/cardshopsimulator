# Card Shop Simulator — Systems Design v1

**Status:** Draft for PM / Eng / QA — v1.1 demand-signal addendum  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Stack target:** Godot 4.x, modules `economy` / `inventory` / `customers` / `shop` / `ui` / `core`  
**Expands:** Design spine v1 (source → stock/price/display → serve → settle day)

---

## 0. Design goals (falsifiable)

1. Every in-game day forces at least one **irreversible cash or space** tradeoff.
2. Perfect information is never free — market price, condition, and demand are **noisy**.
3. Early game pain is **liquidity + bandwidth**, mid game is **space + reputation**, late game is **rent + event risk**.
4. A skilled player can survive a bad week; a careless player goes bankrupt within **30–45 in-game days** on Normal.

---

## 1. Core loop (day timeline)

| Phase | Clock | Player actions | Systems |
|-------|-------|----------------|---------|
| **Open prep** | 08:00–10:00 | Buy from channels, price tags, rearrange layout, assign staff | inventory, economy, shop, staff |
| **Open floor** | 10:00–18:00 | Serve / negotiate / refuse customers; optional mid-day buys | customers, inventory, economy |
| **Close settle** | 18:00–19:00 | Auto: rent share, wages, utilities, shrink, reputation tick, event roll | economy, shop |

**Time model (v1):** Discrete day with phases; floor phase uses a **customer queue timer** (not full real-time sim). Owner actions during floor cost **Attention** (see Staff).

**Starting state (Normal):**
- Cash: `$8,000`
- Rent due weekly: `$1,200` (small unit, **~700 sq ft usable** — 10×8 tiles @ 0.9 m ≈ 698 sq ft; lease copy: “cozy 700”)
- Case capacity: `24` display slots + `40` backstock bins
- Staff: owner only
- Reputation: `40/100` (unknown shop)
- Seed inventory: mixed low-value sealed + commons (see §2.6)

---

## 2. Inventory

### 2.1 Product classes

| Class | Unit | Space | Risk profile | Sell channels (v1) |
|-------|------|-------|--------------|--------------------|
| **Sealed** | SKU × qty (box, ETB, blaster, tin) | Floor pallet or shelf units | Hype spikes + set rotation dump | Counter, online list |
| **Singles** | CardInstance (set, #, finish, condition) | Binder pages / case slots | Condition fraud, liquidity | Case, binder pull, online |
| **Graded** | SlabInstance (card + grade + cert#) | Case slots (2× singles weight) | Capital lock, cert authenticity | Showcase case, online |
| **Accessories** | SKU × qty (sleeves, toploaders, binders, dice) | Shelf units | Low risk, low margin, high velocity | Impulse shelf |

**Data model (implementable):**

```
ProductSKU { id, class, name, set_id?, msrp, base_market, tags[] }
CardInstance { sku_id, finish, condition: NM|LP|MP|HP|DMG, acquired_cost, listed_price?, location }
SlabInstance { card_ref, grader, grade, cert_id, acquired_cost, listed_price?, location }
StockLot { sku_id, qty, acquired_cost_avg, location }  # sealed + accessories
Location { type: CASE|BINDER|SHELF|BACKSTOCK|ONLINE_HOLD, slot_id? }
```

### 2.2 Condition & authenticity

- Singles default to **NM** on distributor buys; marketplace buys roll condition with bias toward LP/MP.
- **Inspection action** (costs Attention): reveals true condition with 85% accuracy; uninspecteds sell at listed grade — mismatch → reputation hit + refund risk.
- Graded: `cert_valid` bool; shady channel has 8% fake-slab chance; fail on sale → big reputation + cash loss.

### 2.3 Space accounting

| Location | Capacity unit | Holds |
|----------|---------------|-------|
| Showcase case | slots | Singles (1), Graded (2) |
| Binder rack | pages × 9–18 pockets | Singles only |
| Floor shelf | shelf_units | Sealed + accessories |
| Backstock | bins | Any, **not visible** to walk-ins (online/pull only) |
| Online hold | soft cap (reputation-gated) | Listed items awaiting ship |

**Rule:** You cannot list what you cannot store. Overflow buys are rejected or force immediate fire-sale.

### 2.4 Shrink & damage

Daily settle roll:
- Base shrink `0.2%` of inventory COGS value
- +`0.5%` if no staff on floor during open
- Sealed pallets on open floor: +theft risk vs backstock

### 2.5 Seed inventory (day 0)

- 4× current-set blasters (low margin)
- 2× previous-set ETBs (stale risk)
- Binder: ~80 commons/uncommons + 8 playable rares (staples)
- Accessories: sleeves ×200, toploaders ×50
- No graded stock

---

## 3. Buying channels

Each channel is a **BuyOpportunity** offered during prep (and rare mid-day). Player accepts/rejects/haggles.

| Channel | Cadence | Price vs market | Info quality | Tradeoff |
|---------|---------|-----------------|--------------|----------|
| **Distributor** | Weekly restock menu | MSRP − 30–40% | Perfect SKUs, sealed/accessories only | MOQ, cash lock, boring mix |
| **Local buylist walk-ins** | Random during floor | You set offer | Partial (player inspects) | Bandwidth; bad offers anger sellers |
| **Marketplace lot** (FB/CL style) | 1–3/day | 40–70% of market | Noisy photos; condition hidden | Travel time (skip 1–2 floor hours) or fee courier |
| **Auction snipes** | Event-tied | Can be steal or trap | Timer + incomplete comps | Attention + cash race |
| **Player trades** | Unlocks at Rep 50 | In-kind | Full | Opportunity cost of stock given |
| **Shady trunk** | Rare, night flag | Deep discount | High fake/condition risk | Reputation bomb if caught |

**Haggle (v1):** One counter-offer. Seller accept chance = f(offer/ask, reputation, channel). Fail → opportunity gone.

**Asymmetric info knobs (must ship):**
- `listed_comp` vs `true_market` (hidden ±15% noise)
- Condition fog on marketplace
- Set rotation timer visible only via **Research** action ($50 + Attention) or staff Specialist

---

## 4. Pricing

### 4.1 Price sources

- `true_market[sku]` drifts daily (see Market Events)
- Player sets `listed_price` per instance/lot
- **Suggested price** UI = noisy comp (`true_market × U(0.9, 1.1)`), never exact truth — full buy/price UI contract in **§4.5**

### 4.2 Sell-through model

For each browsing customer interested in SKU:

```
p_buy = base_interest
      × price_fit(listed / true_market)   # sweet spot ~0.95–1.05
      × display_bonus                     # case > binder > backstock
      × reputation_mod
      × staff_knowledge_mod
```

`price_fit`: too high → walk; too low → instant buy but margin death + trains bargain hunters.

### 4.3 Buylist pricing (buying from customers)

Player sets **buylist % of market** per category (sealed / singles NM / graded).
- High % → more sellers, thinner margins, cash drain
- Low % → angry regulars, fewer lots, reputation drip

### 4.4 Online listings (unlock Rep 35)

- Fee `8%` + ship time 1–3 days
- Items in `ONLINE_HOLD` cannot sell in-store
- Cancels cost reputation if frequent


---

## 4.5 MVP demand-signal — imperfect but fair

**Design call (locked for QA):** The player never sees `true_market` or exact `p_buy`. They always see **biased-but-correlated** signals so skilled reads beat luck, and bad luck still feels explainable.

### Fairness contract (falsifiable)

| Rule | Pass bar |
|------|----------|
| Comp midpoint tracks truth | Mean abs error ≤ **12%** of `true_market` over a 30-day sim |
| Demand band accuracy | Shown band within **±1** of true band on ≥ **80%** of SKU-days |
| No cruel inversion | Without an active fog event, never show **Cold** when true is **Hot** (or reverse) |
| Skill channel | Specialist on duty or Research action **narrows** noise (comp ±15%→±8%, band accuracy ↑) |
| Channel honesty | Distributor signals tighter than marketplace; UI labels confidence |

Bands (true demand score 0–1 → label): `Cold` <0.25, `Steady` 0.25–0.55, `Warm` 0.55–0.80, `Hot` >0.80.  
Shown band = bucket(`clamp(true_demand + N(0, σ), 0, 1)`) with σ = 0.12 base, 0.07 with Specialist/Research.

### Research & condition fog (gates)

| Signal | Default (no Research / no Specialist) | After Research ($50 + Attention) or Specialist on duty |
|--------|----------------------------------------|--------------------------------------------------------|
| Comp width `w` | Channel table in A | ×0.55 (narrower range) |
| Demand band σ | 0.12 | 0.07 |
| Rotation / ban risk | Hidden | Soft telegraph: "Rotation watch: {set}" for 24–72h |
| Condition (marketplace/shady) | "Photo only — inspect recommended"; true grade hidden | Still hidden until **Inspect**; Research does **not** reveal grade |
| Graded `cert_valid` | Never shown pre-buy | Never shown; only fails on sale / deep inspect unlock (post-MVP) |

**Condition fog rule:** Distributor = NM assumed (High confidence). Buylist = inspect optional. Marketplace/Shady = inspect strongly recommended; selling uninspected as NM risks refund + Rep hit (§2.2).

### A. Before **buy confirm** (accepting a BuyOpportunity)

Player **always** sees:

1. **Exact ask** — unit cost / lot total (what you pay is never fogged).
2. **Comp range** — `[$low, $high]` = noisy estimate of resale value (`true_market × U(1−w, 1+w)`, w by channel).
3. **Demand band** — Cold / Steady / Warm / Hot for that SKU or class (today).
4. **Confidence tag** — High (distributor) / Medium (buylist walk-in, auction) / Low (marketplace lot, shady trunk).
5. **Condition cue** — "NM assumed" | "Photo only — inspect recommended" | "Mixed lot".
6. **Cash & space check** — remaining cash after buy; slots/bins required vs free (hard blockers if over).

Player **never** sees on this screen: raw `true_market`, exact margin after fees, future event outcomes, `cert_valid`, true condition roll.

**Channel widths (w):** Distributor 0.06 · Buylist 0.10 · Auction 0.12 · Marketplace 0.15 · Shady 0.22.

**Optional line (if history exists):** "Last sold similar in-shop: $X, N days ago" — factual, no forecast.

### B. Before **price confirm** (setting / changing `listed_price`)

Player **always** sees:

1. **Noisy suggested price** — single number from §4.1 (not truth).
2. **Your price vs sug.** — delta $ and % (informational).
3. **Position chip** vs noisy comp midpoint: `Undercut` (<−8%) / `Competitive` (−8%..+8%) / `Premium` (>+8%).
4. **Demand band** — same SKU/class band as buy side (shared signal that day).
5. **Move feel** — qualitative only, derived from noisy `price_fit`:
   - `Likely sits` | `Should move` | `Walk risk`
   - Mapping uses **noisy** market, never exact `p_buy`. Show **one** of three chips — no percentages.
6. **Display context** — current location bonus plain-language: "Case boost" / "Binder" / "Backstock (pull only)" / "Online hold".

Player **never** sees: exact `p_buy`, true_market, per-archetype willingness, guaranteed sell timer.

**Confirm CTA copy rule:** button stays enabled even on `Walk risk` / `Likely sits` — the signal warns, it does not soft-lock (player agency).

### C. Instrumentation (for QA / Eng)

Emit behind `qa_instrumentation` (aligns with Eng contract):

```
demand_signal_shown {
  screen: buy_confirm | price_confirm,
  sku_id,
  shown_comp_low_cents, shown_comp_high_cents,
  true_market_cents,           # debug only, not UI
  shown_demand_band, true_demand_band,
  confidence: high|medium|low,
  listed_price_cents?,         # price_confirm only
  move_feel?,                  # price_confirm only
}
```

QA playtest probe: after 10 buy + 10 price confirms, players can rank which deals were worse **above chance** using only on-screen signals.

### D. Out of MVP

- Exact % sell-through meters
- Live "customers arriving who want this" counts
- Perfect historical charts (sparklines OK post-MVP if still noisy)

---

## 5. Customers

### 5.1 Archetypes (v1 — ship these 6)

| Archetype | Wants | Behavior | Pressure |
|-----------|-------|----------|----------|
| **Kid / parent** | Accessories, cheap sealed | Low haggling | Volume, impulse |
| **Spike** | Staples, exact list | Knows comps; rejects overprice | Forces accurate pricing |
| **Collector** | Graded, chase sealed | Will pay premium if displayed well | Capital + case space |
| **Flipper** | Mispriced anything | Scans for mistakes | Punishes pricing errors |
| **Regular** | Relationship stock | Returns if treated well | Reputation engine |
| **Whale** | Rare high-ticket | Rare spawn; needs trust + inventory | One wrong refusal hurts |

### 5.2 Queue & service

- Floor spawns N customers/hour from archetype weights (modded by events + inventory mix)
- Each needs **Service** from owner or Cashiers
- Actions: Sell listed, Negotiate (±10%), Pull from backstock (Attention), Refuse, Buy-from-them (buylist)

**Frustration:** Wait > threshold → leave (−soft reputation). Understaffed shops hemorrhage walkouts.

### 5.3 Reputation (0–100)

| Band | Effects |
|------|---------|
| 0–24 | Sparse traffic, whales never spawn, distributor MOQ worse |
| 25–49 | Baseline |
| 50–74 | Regulars + player trades unlock |
| 75–100 | Whale bias, better marketplace leads, lower fees |

**Ticks:** fair deals +, overprice/fake/slow service −, event outcomes ±

---

## 6. Staff

### 6.1 Roles

| Role | Wage/day | Does | Cannot |
|------|----------|------|--------|
| **Owner** (you) | — | Everything; Attention pool `100/day` | Be two places |
| **Cashier** | $80 | Ring sales, basic pulls | Price, buy lots, haggle well |
| **Specialist** | $140 | Accurate pricing assist, inspect, research | Run register alone efficiently |
| **Stocker** | $70 | Restock floor from backstock, layout moves | Sales |

### 6.2 Attention economy

Owner actions cost Attention (examples):
- Inspect card: 5
- Haggle / negotiate: 8
- Marketplace outing: 25 + miss floor hours
- Research set: 15
- Rearrange layout: 10

Staff reduce costs in their domain (Specialist: inspect 5→2). At 0 Attention, owner can only watch — cashiers handle routine sales only.

### 6.3 Hire rules

- Max staff = f(sq ft): small 1, medium 3, large 5 (excluding owner)
- Bad hire: `Reliability` 0–1; low → no-shows, theft bias
- Fire: immediate wage stop; −5 reputation if popular

---

## 7. Shop layout constraints

### 7.1 Grid (v1)

- Usable floor: grid of **tiles** (small shop 10×8 = 80 tiles; **1 tile = 0.9 m**, ≈ **698 sq ft** usable ≈ marketing “cozy 700”)
- Furniture footprints:

| Prop | Tiles | Function |
|------|-------|----------|
| Counter | 2×1 | Required checkout |
| Showcase case | 2×1 | High-value display |
| Binder rack | 1×1 | Singles browse |
| Shelf | 1×2 | Sealed / accessories |
| Play table | 2×2 | Event nights (unlock); blocks browse path |
| Backstock door | 1×1 | Access bins |

### 7.2 Circulation rules

- Pathfinding: customers need clear path from entrance → displays → counter
- Blocking path → −traffic and frustration
- **Sightlines:** Graded in case within 3 tiles of entrance gets `display_bonus`

### 7.3 Expansion

| Tier | Sq ft | Weekly rent | Staff cap | Unlock |
|------|-------|-------------|-----------|--------|
| Small | ~700 (698 calc) | $1,200 | 1 | Start |
| Medium | 1,200 | $2,400 | 3 | Cash ≥ $15k + Rep 55 |
| Large | 2,000 | $4,000 | 5 | Cash ≥ $40k + Rep 70 |

Expansion is a **lease decision** (tough decision #9): higher rent is fixed; traffic capacity scales sublinearly.

---

## 8. Market events

Rolled at settle (or injected mid-week). Each has duration, signals, and counterplay.

| Event | Signal | Effect | Player lever |
|-------|--------|--------|--------------|
| **Set release hype** | Calendar (known) | New sealed demand ↑; old set ↓ | Pre-order vs wait |
| **Pro tour / influencer spike** | 1-day telegraph | Specific archetype cards ↑ 30–80% | Stock depth vs FOMO buy |
| **Rotation / ban** | Surprise or soft leak | Staples crash | Research / Specialist |
| **Supply glut** | Distributor email | Sealed wholesale ↓, retail race | Margin vs volume |
| **Theft ring** | Optional rumor | Shrink ×3 for 3 days | Staff / cameras (unlock) |
| **Convention weekend** | Calendar | Traffic ×2, whale chance ↑ | Staff up, price up carefully |
| **Recession week** | Macro ticker | All demand ↓, buylist sellers ↑ | Liquidity over glory |
| **Counterfeit scare** | News flash | Graded trust ↓; inspect mandatory | Avoid shady channel |

**Implement:** `MarketEvent` resource with `id`, `weight`, `duration_days`, `modifiers{}`, `telegraph_hours`.

Daily drift without events: each SKU `true_market *= U(0.98, 1.02)` clamped by class volatility (graded > singles > sealed > accessories).

---

## 9. Win / lose conditions

### 9.1 Lose (bankruptcy) — any of

1. **Cash < 0** after settle (cannot pay rent/wages)
2. **Missed rent** 2 weeks in a row
3. **Reputation ≤ 0**
4. **Optional ironman:** cash < $500 and inventory COGS < $500

### 9.2 Win / prestige goals (pick campaign mode)

| Mode | Victory |
|------|---------|
| **Survive Year 1** | Reach day 365 with cash > 0 and Rep ≥ 40 |
| **Flagship** | Own Large shop + Rep ≥ 80 + cash ≥ $50k |
| **Liquidity king** | End any month with cash ≥ $100k (inventory optional) |
| **Sandbox** | No win; personal bests (net worth, days survived) |

**Net worth** = cash + inventory at `true_market` × liquidity haircut (sealed 0.85, singles 0.7, graded 0.6, accessories 0.9).

### 9.3 Soft fail (recovery)

First bankruptcy on Easy/Normal offers **loan shark**: +$5,000 cash, −$200/day for 40 days, Rep −10. Hard: instant game over.

---

## 10. First 10 tough decisions (tutorial arc → early midgame)

These are **scripted decision beats** QA can test; each must surface clear tradeoffs in UI.

| # | Day window | Decision | Options (examples) | What it teaches |
|---|------------|----------|--------------------|-----------------|
| 1 | Day 1 | **Price the seed ETBs** | Match noisy comp / undercut 10% / hold for hype | Margin vs sell-through |
| 2 | Day 2 | **Distributor MOQ** | Buy deep sealed (cash lock) / light mix / skip | Liquidity vs stockout |
| 3 | Day 3 | **Marketplace “steal” lot** | Drive out (miss peak hours) / courier fee / skip | Asymmetric info + bandwidth |
| 4 | Day 4 | **Spike wants last playable rare** | Sell at list / haggle / refuse to keep binder depth | Short cash vs long assortment |
| 5 | Day 5 | **Hire first cashier?** | Hire ($80/day) / keep solo / hire unreliable cheap | Owner bandwidth vs wage burn |
| 6 | Day 7 | **First rent due + soft shelf** | Fire-sale sealed / cut accessories / take payday loan | Fixed cost pressure |
| 7 | Day 8–10 | **Hype spike on one card** | Chase-buy at peak / sell into strength / ignore | FOMO vs staples |
| 8 | Day 12 | **Case slot: graded slab vs 2 chase singles** | Display slab / singles / rotate daily | Space as a resource |
| 9 | Day 18–25 | **Expand to Medium?** | Sign lease / wait for Rep / stay small | Rent risk vs capacity |
| 10 | Day 20–30 | **Shady trunk deal** | Buy cheap risky / report (Rep+) / ignore | Risk, authenticity, ethics |

**Success criteria for design:** Playtesters name the tradeoff without prompting in ≥7/10 beats.

---

## 11. Module mapping (for Engineer)

| Module | Owns |
|--------|------|
| `core` | Day clock, save, RNG seeds, event bus |
| `economy` | Cash, rent, wages, fees, net worth, loans |
| `inventory` | SKUs, instances, locations, capacity, shrink |
| `customers` | Archetypes, spawn, queue, buy/sell utilities |
| `shop` | Grid layout, furniture, expansion tiers, pathing |
| `ui` | Pricing panels, buy opportunities, decision modals |

**Staff** lives in `shop` (roster) with hooks into `customers` (service) and `economy` (wages).  
**Market events** live in `economy` with modifiers applied to `inventory.true_market` and `customers` weights.

---

## 12. v1 out of scope (explicit)

- Multiplayer / trading between players
- Full real TCG rules / deckbuilding sim
- Manufacturer licensing / real card IP (use fictional sets + stats)
- Franchise multi-store (post-1.0)
- Deep tax/accounting sim

---

## 13. Balance targets (initial tunables)

| Tunable | Normal start |
|---------|--------------|
| Days to first rent crisis if passive | 7–10 |
| Target gross margin blend | 25–35% |
| Customers / open hour (small, Rep 40) | 4–7 |
| Attention / day | 100 |
| Event chance / settle | 18% |
| Whale spawn / week at Rep 75 | ~1 |

Engineer: expose these as `BalanceConfig` resource — Designer owns values, code owns formulas.

---

## 14. Handoff

**PM:** Schedule Eng spike on inventory+economy data models; Art needs furniture prop list from §7.1; QA builds playtest script from §10.

**Next design docs:** (a)–(c) delivered — set bible, UI wireflows, difficulty curves (`difficulty-curves-v1.md`). Further: §10 beat tuning after playable slice.
