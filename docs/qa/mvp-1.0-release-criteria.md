# Card Shop Simulator — MVP 1.0 Release Criteria

Status: Draft QA gate (aligned to PM lock 2026-09-04)

## 1. Exit rule

MVP 1.0 is eligible for release review only when all required day-loop, data-integrity, readability, compatibility, and playtest gates pass on the release candidate. No S0/S1 defect is open. S2 defects require explicit Product/Engineering/QA sign-off with a documented workaround and no save/economy integrity risk.

## 2. Severity model

- **S0 — Stop ship:** security/privacy issue, data loss/corruption across saves, destructive platform behavior, legal/IP violation, or build cannot launch for the supported audience.
- **S1 — Critical:** crash/hang or progression blocker in a primary flow; impossible day completion; irrecoverably wrong cash/inventory/ledger state; bankruptcy or rent resolves incorrectly; inaccessible mandatory action.
- **S2 — Major:** major system produces a materially wrong outcome with recovery/reload available; frequent navigation/interaction failure; market UI leaks true value; severe readability/performance problem.
- **S3 — Moderate:** localized incorrect feedback, intermittent non-critical behavior, visual defect, balance/content issue that does not invalidate the run.
- **S4 — Minor:** polish, copy, low-impact alignment, or rare cosmetic issue.

Severity is based on impact, not implementation effort.

## 3. Supported build gate

- Project imports without parser/resource errors in the minimum supported Godot 4.3 line and the release editor version.
- Forward Plus desktop build launches from a clean checkout without local caches or secrets.
- Main menu, new game, difficulty selection, save/load, return to menu, and clean exit work.
- Headless deterministic domain tests pass.
- No large unapproved binaries, real-TCG placeholders, or generated editor caches ship.

## 4. MVP day-loop exit

An instrumented fresh Normal run must complete:

`New Game → Prep → Floor → Settle → next Prep`

and continue through day 7 weekly Settle. Acceptance requires:

- Normal starts with exactly 800,000 cents ($8,000).
- HUD and forecast identify phase/day, cash, Attention, and next weekly rent.
- Prep permits at least one inventory acquisition, location assignment, and shelf price.
- Floor spawns customers, matches at least one desire, and permits a ledger-backed sale.
- Settle reconciles revenue, cost basis, fees/shrink stubs, and cash without duplication.
- Day 7 posts weekly rent exactly once for 120,000 cents ($1,200); no daily rent deduction occurs.
- Save/reload at each phase boundary preserves cash, ledger, lots/instances, locations, prices, event state, Attention, RNG seed, and difficulty config.
- Invalid/failed commands are atomic.
- Insolvency forecast appears before an uncured obligation can end the run.

Easy and Hard smoke runs verify config selection; Hard must never offer the loan-shark recovery.

## 5. System integrity gates

### Inventory

No negative quantity, duplicate instance identity, over-capacity location, or sellable unprocessed intake. Lot cost basis and condition survive movement/sale/save. Normal default capacity is 24 case slots and 40 backstock bins.

### Economy

Every cash change maps to one ledger entry or an explicitly logged initialization. Currency remains integer cents. Buying/selling is atomic. Rent posts only at weekly Settle. UI totals reconcile to ledger totals.

### Pricing

Player UI never exposes `true_market_cents`. Visible comps include source/age/condition and produce an explainable range/confidence. QA-only truth requires a conspicuous developer flag and is absent in release builds.

### Customers, staff, and events

All six archetypes can spawn under eligible conditions. Desire and budget outcomes are reproducible with a fixed seed. Attention cannot overspend; task reassignment has one outcome. Event eligibility, roll, choice, and delayed effects are logged and reproducible.

### Shop

Grid is 10×8 at 0.9 m. Mandatory paths remain traversable. Capacity corresponds to fixtures/config. Counter, case, register, intake tray, shelving, bins, and entrance pass the Art P0a unlabeled readability gate.

## 6. Early playtest beats

Test sessions should reach at least four beats below before the first rent and reach the day-7 settle:

1. distributor allocation versus rent liquidity;
2. hot sealed product versus diversified case use;
3. high-margin price versus faster turnover;
4. large buylist versus cash and appraisal Attention;
5. noisy hype reorder versus waiting;
6. checkout coverage versus high-value appraisal;
7. reliable accessories versus speculative depth;
8. risky auction lot versus predictable supply;
9. selling a rising card to cover rent versus holding;
10. liquidation/financing versus bankruptcy risk.

For each beat capture offer viewed, option selected, cash/stock/Attention before and after, customer consequence, whether the tradeoff was understood, and regret/intent. A beat fails if one choice is dominant without contextual reason or the consequence is invisible.

## 7. Performance, accessibility, and usability

Targets must be finalized against supported hardware before content lock. Until then:

- no sustained frame hitch during customer spawn, transaction, phase transition, or event resolution;
- no unbounded node/resource growth across seven days;
- full primary-flow keyboard navigation and visible focus;
- scalable readable text and no color-only critical state;
- remappable gameplay controls once movement/input is introduced;
- pause and audio controls function consistently.

## 8. Required QA instrumentation

Log build/config version, seed, day/phase, command/result, transaction IDs, cash delta, inventory identity/location delta, Attention delta, event rolls, phase transition, save migration, and run-end reason. IDs must correlate a sale across customer intent, inventory relief, and ledger entry.

Release telemetry must not include secrets or personal data. Developer truth overlays and verbose logs are disabled in release builds.

## 9. Sign-off evidence

QA attaches clean-checkout results, automated-test output, a seven-day Normal reconciliation, Easy/Hard config smoke results, P0a visual review, IP-placeholder scan, known-issue severity list, and representative performance capture. Engineering confirms schema/migration compatibility; Product confirms tough-decision comprehension results.
