# Playtest report — K2 STOP Online + Research re-smoke @ `b94c1f51` / main post-J2

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~3:12 PM ET)  
**Build:** `adamwlarson/cardshopsimulator`  
**Tip SHA used:** `b94c1f51ede28fa1162be0c77a2e8aea4d452b15` (short `b94c1f51`)  
**Tip note:** `origin/main` HEAD = J2 Art merge `2bfa0efd` (PR #38) **+ docs-only** ahead (pick-k / K2 kick / pick-e gap). Includes J1 skill (`8bd03a4` / #37) and I1 online (`7c40f3b` / #36).  
**Tree:** `/workspace/qa-playtest/k2-b94c1f51/` (detached worktree @ tip; does not mutate other qa-playtest trees)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/workspace/godot452`)  
**Scope:** Formal K2 STOP — §10 beats **#1–#10** reachability on Normal **with** ≥1 online list/cancel **and** ≥1 Research (or Specialist) noise-narrow; §4.5 clean on counter + online confirms; Soft `_ensure_priceable_sku` policy callout; **no new player verbs**; Eng S2+ standby only  
**Method:** Headless — foundation `tests/test_runner.gd` + reused harnesses `tests/qa_h2_campaign_smoke.gd` (tip-adapted; QA-boot Soft), `tests/qa_i1_online_smoke.gd`, `tests/qa_j1_skill_smoke.gd`  
**Design SoT:** `docs/design/next-eng-sot-pick-k-v1.md` § K2; systems §10 / §4.4 / §4.5 / J1 skill

**Evidence:** `/workspace/card-shop-qa/evidence/k2-b94c1f51/` (`import.log`, `foundation.log`, `campaign_smoke.log` / `.json`, `qa_i1_smoke.log` / `qa_i1_online_smoke.json`, `qa_j1_smoke.log` / `qa_j1_skill_smoke.json`, `k2_summary.json`)

---

## Executive verdict

| Gate | Result |
|------|--------|
| Tip resolved (`b94c1f51` or docs-only ahead of J2 `2bfa0efd`) | **PASS** — `b94c1f51ede28fa1162be0c77a2e8aea4d452b15`; ancestor of `2bfa0efd` + J1 merge |
| J2 art assets in tree (build sanity) | **PASS** — `prop_graded_case_badge_01.glb` + `prop_online_hold_tag_01.glb` imported |
| Godot import clean | **PASS** (`IMPORT_EXIT:0`; full `--quit-after 120`) |
| Foundation `tests/test_runner.gd` | **PASS** — `All foundation tests passed.` (`EXIT:0`) |
| 1. §10 #1–#10 + ≥1 online list/cancel + ≥1 Research/Specialist narrow | **PASS** |
| 2. §4.5 clean on counter + online confirms | **PASS** — 0 hard UI hits (`true_market` / `p_buy` / `cert_valid`) |
| 3. Blockers filed; no new verbs | **PASS** — none S0–S2; harness-only Soft notes |
| 4. Soft `_ensure_priceable_sku` policy callout | **PASS** — **keep parked** |
| Campaign harness (#1–#10) | **PASS-with-notes** — **108 PASS / 0 FAIL / 13 SOFT**; all BEAT_1..10=PASS |
| I1 online harness | **PASS** — **134 PASS / 0 FAIL / 6 SOFT** |
| J1 skill harness | **PASS** — **382 PASS / 0 FAIL / 6 SOFT** |
| S0–S2 blockers | **None** |
| Eng S2+ standby needed? | **No** |

**Overall: PASS-with-notes**

Post-J2 main tip clears K2 STOP: full §10 Normal campaign reachability, online list/cancel, and Research noise-narrow all green under §4.5 fog. Notes are Soft-only (parked Soft seed + known SceneTree campaign-harness QaInstrumentation boot race — instrumentation Soft-skipped; beat reachability still PASS). No Eng systems work required.

**Clear for Eng S2+?** **NO** (nothing S2+).  
**Soft policy:** **keep parked** (do not open K1 / Won’t-Fix unless demos block).

---

## Acceptance gates (K2)

| # | Acceptance | Observed | Verdict |
|---|------------|----------|---------|
| 1 | Written #1–#10 + ≥1 online list/cancel + ≥1 Research/Specialist narrow | Campaign BEAT_1..10=PASS; I1 `online_listed`→`online_cancelled`; J1 Research σ 0.12→0.07 / factor 0.55 | **PASS** |
| 2 | §4.5 clean on counter + online confirms | Campaign UI scan 0 hits; I1 list confirm/HUD chips clean; J1 buy/price/online after Research clean | **PASS** |
| 3 | Blockers filed; no new verbs | No S0–S2; harness Soft only; no product PR | **PASS** |
| 4 | Soft seed policy in report | Helper still in `demand_signals.gd`; unused by campaign/online/Research paths for Normal reachability | **PASS** — keep parked |

---

## Per-beat table (#1–#10)

| # | Beat | Status | Evidence (one-liner) |
|---|------|--------|----------------------|
| 1 | Price seed Dustway ETB (`AA-DUST-ETB`) | **PASS** | Day1 priceable stock includes Dustway; PriceConfirmSignal clean; tip `b94c1f51` |
| 2 | Distributor MOQ | **PASS** | Day1 `beat_id=distributor_moq` qty=8; tip `b94c1f51` |
| 3 | Marketplace outing (Drive/Courier/Skip) | **PASS** | Day3 PREP reachable (+fog survive); tip `b94c1f51` |
| 4 | Spike staple Bastion/Arcbolt | **PASS** | Day3–5 FLOOR Spike wants `AA-BASE-088`; refuse completes; tip `b94c1f51` |
| 5 | Hire first cashier | **PASS** | Day5 PREP choices hire_cashier / keep_solo / hire_cheap / hire_specialist; tip `b94c1f51` |
| 6 | Rent fire-sale (Hard loan hidden) | **PASS** | Day7 fire-sale/accessories/loan Normal; Hard loan hidden; tip `b94c1f51` |
| 7 | Titan hype + Option D PriceEditor | **PASS** | Day8–10 Titan → PriceEditor HOT; tip `b94c1f51` |
| 8 | Slab vs singles / rotate | **PASS** | Day10–12 slab/singles/rotate reachable+reversible; tip `b94c1f51` |
| 9 | Expand Medium | **PASS** | Day18–25 sign_lease / wait_for_rep / stay_small; tip `b94c1f51` |
| 10 | Shady trunk Buy/Report/Ignore | **PASS** | Day20–30 Buy/Report/Ignore reachable; tip `b94c1f51` |

---

## Online list/cancel evidence (I1 re-smoke)

| Check | Observed | Verdict |
|-------|----------|---------|
| List → ONLINE_HOLD + fee path | `online_listed` fee **200** on **2500** (8%); ship 1 and 3 accepted | **PASS** |
| Cancel restore | `online_cancelled` before fill; held stock not in-store sellable (foundation + I1) | **PASS** |
| Frequent-cancel Rep hit | 3 cancels → `online_cancel_rep_hit` rep_delta **−3** / window 7 (foundation + I1) | **PASS** |
| List confirm §4.5 | summary + HUD chips nack `true_market` / `p_buy` / `cert_valid`; UI scan **0** hits | **PASS** |

Harness: **134 PASS / 0 FAIL / 6 SOFT**. Soft = parked Soft seed + inherit knobs + hardcoded “8%” copy + defensive filter tokens (S4 only).

---

## Research / Specialist noise-narrow evidence (J1 re-smoke)

| Check | Observed | Verdict |
|-------|----------|---------|
| Research $50 + Att | Att 0 blocks; Att≥15 + $50 succeeds; channel `research` | **PASS** |
| Noise narrow | σ **0.12→0.07**; `comp_narrow_factor` **0.55**; buy/price/**online list** comps narrow | **PASS** |
| Specialist same narrow | On-duty Specialist narrows without spend (J1 gate2b) | **PASS** |
| Rotation soft-leak only via skill | Research → `Rotation watch: Skiefall Ascension`; condition fog retained | **PASS** |
| §4.5 after Research | condition cue photo-only; no truth on buy/price/online confirms | **PASS** |

Harness: **382 PASS / 0 FAIL / 6 SOFT**. Sample: `research_applied` sample_comp_width **750→412**; informed `demand_signal_shown` on buy/price/list_confirm with `skill_informed:true`.

Foundation on same tip also emitted `online_listed`/`online_cancelled`/`online_filled`/`online_cancel_rep_hit` and `research_applied` (skill_channel research) under `EXIT:0`.

---

## §4.5 truth scan

| Surface | Result |
|---------|--------|
| Campaign UI scan (hud / presenter / main_menu / gameplay_hud) | **0** hard hits |
| Campaign per-beat payload / price summary nacks | **PASS** (#1, #3, #5–#10, G1 fog) |
| I1 online list confirm + HUD chips | **0** hard hits |
| J1 Research + online/counter confirms | **0** hard hits |
| Defensive filter tokens in `customer_intent_icon.gd` | Soft only (not player-facing) |

---

## J2 art build sanity (not a full art rescore)

| Asset | Present | Imported |
|-------|---------|----------|
| `assets/props/shop/fixtures/prop_graded_case_badge_01/prop_graded_case_badge_01.glb` | **Yes** | `.import` present |
| `assets/props/shop/fixtures/prop_online_hold_tag_01/prop_online_hold_tag_01.glb` | **Yes** | `.import` present |

---

## Soft seed policy recommendation

**Recommend: keep parked** (eligible later **Won’t-Fix** / K1 hygiene — do **not** open K1 from this stop).

**Rationale:**

- Day1 Normal already seeds `AA-DUST-ETB`; §10 #1 does not need Soft inject.  
- Campaign #1–#10, I1 online, and J1 Research/Specialist all PASS without Soft.  
- Helper remains only as HYPE/FOG → PriceEditor empty-SKU bridge inside `demand_signals.gd` (`_ensure_priceable_sku` @ ~849).  
- Per pick-k / K2: Soft stays parked unless blocking demos — it is not.

---

## Blockers (severity-ranked)

| Severity | ID | Summary | Disposition |
|----------|----|---------|-------------|
| — | — | **None found** (S0–S2 empty for this tip/smoke) | — |

Known Soft notes (non-blocking, not filed as defects):

1. Soft `_ensure_priceable_sku` parked (S4) — keep parked.  
2. Campaign harness SceneTree boot race: `QaInstrumentation` autoload can fail to instantiate when `qa_h2_campaign_smoke.gd` is the main `-s`/`--script` (compile cascade); beat reachability still PASS; instrumentation Soft-skipped. **Harness-only** — not a product defect. (S4)  
3. I1 Soft Eng: BalanceConfig cancel/unlock/ship inherit defaults; hardcoded “8%” HUD/ledger copy vs Easy/Hard fees (S4).  
4. J1 Soft Eng: HYPE/FOG Soft bridge still live; ResearchHint display-only (S4).

---

## Harness PASS/FAIL counts

| Harness | PASS | FAIL | SOFT | Overall |
|---------|------|------|------|---------|
| Foundation `test_runner.gd` | (suite) | 0 | — | **EXIT:0** |
| Campaign §10 (`qa_h2_campaign_smoke.gd` tip-adapted) | 108 | 0 | 13 | **PASS-with-notes** |
| Online I1 (`qa_i1_online_smoke.gd`) | 134 | 0 | 6 | **PASS** |
| Skill J1 (`qa_j1_skill_smoke.gd`) | 382 | 0 | 6 | **PASS** |

No new player verbs. Harnesses live under the playtest tree (+ mirrors under `/workspace/card-shop-qa/`) — not pushed as a product PR.

---

## Clear for Eng / next pick?

| Question | Answer |
|----------|--------|
| Clear for Eng S2+? | **NO** — no S2+ findings |
| Open K1 Soft Won’t-Fix now? | **NO** — keep Soft parked |
| K2 STOP complete? | **YES** — written Online + Research re-smoke report delivered |
| Suggested next | Design/PM may advance past K2 (e.g. K3 Large / K4 scare) when ready; Soft → Won’t-Fix optional later via K1 |

---

## Reproduction

```bash
# Tip
cd /workspace/qa-playtest/k2-b94c1f51
git rev-parse HEAD   # b94c1f51ede28fa1162be0c77a2e8aea4d452b15

# Import (full)
godot --headless --editor --quit-after 120 --path .

# Foundation
godot --headless --path . --script res://tests/test_runner.gd
# → All foundation tests passed. / EXIT:0

# Campaign §10
godot --headless --path . --script res://tests/qa_h2_campaign_smoke.gd
# → OVERALL=PASS-with-notes ; BEAT_1..10=PASS

# Online
godot --headless --path . --script res://tests/qa_i1_online_smoke.gd
# → 134 PASS / 0 FAIL

# Research/Specialist
godot --headless --path . --script res://tests/qa_j1_skill_smoke.gd
# → 382 PASS / 0 FAIL
```

## Sync

Synced to main by Card Shop PM (2026-09-06). **K2 complete** — Eng S2+ No; Soft keep parked; K1 park.
