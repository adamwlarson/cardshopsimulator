# Playtest report — J1 Research/Specialist skill deepen formal smoke @ `c9ced39d` (PR #37)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~3:05 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip **`c9ced39d00b6fed13b836b57c3f5badddf489624`** (short `c9ced39d`)  
**Tree:** `/workspace/qa-playtest/j1-c9ced39d/` (detached worktree @ tip)  
**Mode:** **Normal** (`data/balance/normal.tres`) — Easy/Hard σ soft cross-check only  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal J1 Research/Specialist skill deepen — Research $50+Att; noise narrow (×0.55, σ 0.12→0.07); rotation soft-leak gated; §4.5 clean on online+counter; Soft `_ensure_priceable_sku` parked  
**Method:** Headless — foundation `tests/test_runner.gd` (`_test_j1_research_specialist_skill_deepen`) + SceneTree harness `tests/qa_j1_skill_smoke.gd`  
**Design SoT:** pick-j Option J1; systems §4.5 / §6.2; PR #37 body; Soft Eng parkeds non-blocking; **No Art** (J2 separate)

**Evidence:** `/workspace/card-shop-qa/evidence/j1-c9ced39d/` (`import.log`, `foundation.log`, `qa_j1_smoke.log`, `qa_j1_skill_smoke.json`)

---

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Research $50 + Att; Att 0 blocks; Att ≥ cost succeeds | **PASS** |
| 2. Noise narrow measurable after Research OR Specialist on duty (comp ×0.55; σ 0.12→0.07) | **PASS** |
| 3. Rotation soft-leak only via Research buff or Specialist | **PASS** |
| 4. §4.5 clean — no condition/cert_valid/true_market/p_buy via Research; online + counter confirms clean | **PASS** — 0 hard UI hits |
| 5. Soft `_ensure_priceable_sku` unused / parked | **PASS** |
| 6. Soft Eng parked (non-blocking) | **PASS** (soft noted) |

| Supporting | Result |
|------------|--------|
| Tip SHA confirmed | **`c9ced39d00b6fed13b836b57c3f5badddf489624`** (`merge main into J1 branch (docs-only)`) |
| Godot import | **PASS** (`IMPORT_EXIT:0`) |
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` (`EXIT:0`); `_test_j1_research_specialist_skill_deepen` exercised (`research_applied` skill_channel research; informed σ 0.07 / factor 0.55) |
| Formal J1 smoke harness | **PASS** — **382 PASS / 0 FAIL**; `SOFT_COUNT=6` |
| S0–S2 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

J1 Research/Specialist skill deepen clears the formal pass bar on Normal at tip `c9ced39d`. Soft Eng parkeds only; no S0–S2.

**Clear for merge?** **YES** (PASS-with-notes; soft only).

---

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1a | Att 0 blocks Research | `can_research=false`; `research_set` → `ok=false`, `reason=insufficient_attention`; HUD `%OpenResearchButton` disabled | **PASS** |
| 1b | Att ≥ cost + $50 succeeds | cash −5000¢; Att −15; `skill_channel=research`; informs AA-SKIE only (not AA-BASE) | **PASS** |
| 2a | Research narrows comps / σ | buy 330→182; price 220→122; list 240→132; sample 750→412; σ **0.12→0.07**; factor **0.55**; ≥3 informed QA events | **PASS** |
| 2b | Specialist same narrow, no spend | hire on duty; cash/Att unchanged; shop-wide informed; buy/price/list narrow; σ 0.07; channel `specialist` | **PASS** |
| 3a | Rotation hidden by default | empty `rotation_watch_text`; Dustway pack event banner empty without channel | **PASS** |
| 3b | Research / Specialist leak only | Research → `Rotation watch: Skiefall Ascension` (telegraph 1–3d); Specialist reveals Dustway banner + watch; fire hides again | **PASS** |
| 4a | Research keeps condition fog; no truth | condition cue `Photo only — inspect recommended`; DTO fields + buy/price/online summaries nack `true_market`/`p_buy`/`cert_valid` | **PASS** |
| 4b | Online + counter HUD clean | Online chips/summary clean after Research; ResearchHint + StaffHint clean; staff hint names “without Research spend” | **PASS** |
| 4c | UI truth scan | hud / presenter / menus / gameplay_hud — **0** hard hits | **PASS** |
| 5 | Soft parked | helper stays in `demand_signals.gd`; service/presenter/hud/online_listing do not call it | **PASS** |
| 6 | Soft Eng parked | HYPE/FOG bridge still live; ResearchHint display-only; No Art — S4 only | **PASS** (soft) |

---

## Key measured evidence

| Surface | Key numbers |
|---------|-------------|
| BalanceConfig (Normal) | Research **$50** / Att **15**; σ **0.12** → research **0.07**; narrow **0.55** |
| Gate1 | Att0 `insufficient_attention`; success Att −15 / cash −5000; channel `research` |
| Gate2 Research widths | buy **330→182**; price **220→122**; list **240→132**; sample **750→412** |
| Gate2 Specialist widths | buy **330→182**; price **220→122**; list **240→132**; informed events **3** |
| Gate3 | `Rotation watch: Skiefall Ascension`; telegraph_through_day **1**; Specialist Dustway leak; fire clears |
| Gate4 summary (excerpt) | Buy condition fog; online fee 8% + ships 1–3; price Competitive / Should Move |
| Truth scan | `truth_scan_leaks: []` |
| Harness | **382 PASS / 0 FAIL / 6 SOFT** |

Foundation J1 instrumentation (from `foundation.log`):

- `research_applied` → `skill_channel: research`, Att 15 / cash 5000, σ 0.12→0.07, factor 0.55, sample 750→412, `Rotation watch: Skiefall Ascension`
- Informed `demand_signal_shown` events with `skill_informed: true`, `demand_band_sigma: 0.07`, `comp_narrow_factor: 0.55` on buy/price/list after Research and again under Specialist

Note: headless logs show transient early `GameState` compile noise while autoloads resolve (same class of noise as I1). Suite settles; foundation `EXIT:0` and focused harness **382/0**.

---

## Design SoT alignment

- **pick-j / Option J1:** Research $50+Att (disabled at Att 0); noise narrow ×0.55 / σ 0.12→0.07; Specialist same narrow without spend; rotation soft-leak only via Research/Specialist; hard walls on condition/cert/truth.
- **systems §4.5 / §6.2:** Skill channel narrows noise; Research does not reveal grade; rotation telegraph via Research/Specialist.
- **Out of scope (honored):** No Art (J2); Soft seed Won’t-Fix deferred (J3); no multi-set Research / perfect charts / Large expand / J4 re-smoke.

---

## Soft Eng nits (non-blocking)

1. **Soft `_ensure_priceable_sku`** — unused by J1 surfaces; helper remains parked in `DemandSignals`. (**S4**)
2. **Soft seed still live for HYPE/FOG bridge** — `_ensure_priceable_sku` still called from HYPE/FOG event binding inside `demand_signals.gd` (not J1-expanded; park vs J3). (**S4**)
3. **HUD Research narrow copy is pre-existing display-only** — `%ResearchHint` / tscn copy about narrowing comps; not a new truth surface. (**S4**)
4. **No Art** — J2 separate; confirmed OOS. (**S4**)
5. **Defensive filter tokens** in `customer_intent_icon.gd` (`true_market` / `cert_valid`) — filter-only; not player-facing. (**S4**)

## Findings (severity-ranked)

| Severity | ID | Summary | Disposition |
|----------|----|---------|-------------|
| — | — | **None found** (S0–S2 empty for this tip/smoke) | Soft S4 notes only |

---

## Clear for merge?

| Question | Answer |
|----------|--------|
| Clear for merge? | **YES** — PASS-with-notes; Soft Eng only |
| Eng S2+ standby from this report? | **No** |
| Art needed? | **No** (J2 separate) |

Harness lives under the playtest tree (`tests/qa_j1_skill_smoke.gd`) and is mirrored at `/workspace/card-shop-qa/qa_j1_skill_smoke.gd` — not pushed.

## Merge

Merged to main as **PR #37** @ `8bd03a4733f740239a07fc55cc95bae345588a21` (2026-09-06).
