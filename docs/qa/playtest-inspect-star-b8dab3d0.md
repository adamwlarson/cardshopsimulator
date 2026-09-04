# Playtest report — Inspect★ formal/smoke @ `b8dab3d0` (PR #17)
**Scorer:** CSS QA (executor)  
**Date:** 2026-09-04 (~1:35 PM ET)  
**Build:** `adamwlarson/cardshopsimulator` tip `b8dab3d0b9bc4ac5d1bdd3b0ca52416bceb2d01b` (tree `/workspace/qa-playtest/tip17/`)  
**Mode:** **Normal** (`data/balance/normal.tres`) — Easy/Hard accuracy cross-check only  
**Godot:** 4.5.2.stable.official.6ce3de25a  
**Scope:** Formal/smoke — Inspect★ Attention tradeoff on `BuyOpportunityDetail`  
**Method:** Headless — foundation `tests/test_runner.gd` + SceneTree harness `tests/qa_inspect_star_playtest.gd` (HUD player path: OpenBuy → marketplace row → Inspect★; distributor hide; truth scan)  
**Design SoT:** `docs/design/ui-wireflows-v1.md` §1.2 Inspect★; `docs/design/systems-design-v1.md` §4.5 condition fog / §6.2 Attention (Inspect card: 5); `docs/qa/mvp-1.0-release-criteria.md` S0–S4 + truth-leak rules

## Executive verdict

| Gate (pass bar) | Result |
|-----------------|--------|
| 1. Attention debit **5** on Inspect★ (Normal) | **PASS** — Owner cost 5; HUD PREP 100→95; label `Att 95/100` |
| 2. No truth leak (`true_market` / exact `p_buy` / `cert_valid`) | **PASS** — UI sources + post-inspect cue/summary clean |
| 3. Cue-only update after inspect | **PASS** — condition cue changes; comps / demand / confidence unchanged |
| 4. Distributor correctly **hides** Inspect★ | **PASS** — `inspect_button.visible == false` on distributor detail |
| 5. Soft Eng nits alone | **Non-blocking** (S4) — do not fail tip |

| Supporting | Result |
|------------|--------|
| Foundation `test_runner` | **PASS** — `All foundation tests passed.` |
| Formal harness | **PASS** — **113 PASS / 0 FAIL**; `SOFT_COUNT=3` |
| S0–S3 (severity rubric) | **None found** for this tip |

**Overall: PASS-with-notes**

Inspect★ formal/smoke clears the pass bar on Normal at tip `b8dab3d0`. Soft Eng nits noted below do not fail the tip.

## Pass-bar checklist

| # | Check | Observed | Verdict |
|---|-------|----------|---------|
| 1 | Att debit = 5 (Normal) | `BalanceConfig.inspect_attention=5`; `ShopState.inspect_attention_cost()=5`; domain `consume_attention(5)` 100→95; HUD Inspect★ press same debit + `Att 95/100` | **PASS** |
| 2 | No truth leak in player UI | Scanned `hud.gd`, `demand_signal_presenter.gd`, `main_menu.gd`, `gameplay_hud.tscn`, `hud.tscn`, `main_menu.tscn` — **0** hits for `true_market` / `p_buy` / `cert_valid`. Post-inspect cue (`Heavy wear`) + BuySummary clean. BuyConfirmSignal has no truth properties. | **PASS** |
| 3 | Cue-only after inspect | Fog `Photo only — inspect recommended` → cue `Heavy wear` (HUD) / `Looks NM` (seeded domain); comps/band/confidence frozen. Summary refreshes Condition line only. | **PASS** |
| 4 | Distributor hides Inspect★ | Day-1 distributor row → detail; button not visible; cue `NM assumed` | **PASS** |
| 5 | Soft alone non-blocking | 3 soft nits (see below) | **N/A / noted** |

## Channel visibility (SoT cross-check)

| Channel | Inspect★ | Evidence |
|---------|----------|----------|
| Marketplace | Visible + enabled (full Att) | HUD day-1 marketplace lot |
| Shady | Visible; disabled when Att&lt;5 | Att forced to 4 → blocked, fog kept |
| Buylist | Visible (optional) | Synthetic buylist DTO on HUD |
| Distributor | **Hidden** | Pass-bar #4 |
| Auction | Hidden (`recommends_inspect=false`) | Note — aligns with §4.5 fog focus on marketplace/shady |

## Design SoT alignment

- **ui-wireflows §1.2:** Inspect★ spends Attention; updates condition cue only (not comps) — harness + wireflow text assert.
- **systems §6.2:** Inspect card: **5** Attention — Normal `inspect_attention=5`, accuracy 0.85.
- **systems §4.5 fog:** Distributor NM assumed / High; marketplace/shady inspect recommended; `cert_valid` never shown pre-buy.
- **mvp-1.0-release-criteria:** Truth-leak S1 gate clear; no S0–S3 filed for this tip.

## Soft Eng nits (non-blocking)

1. **`easy.tres` / `hard.tres` omit explicit `inspect_attention=5`** — script default covers; foundation + harness assert default 5. Prefer mirroring Normal for diff clarity. (**S4**)
2. **Specialist inspect 5→2** is stub comment/hook only on `ShopState.inspect_attention_cost()` — PR-documented; no staff path yet. (**S4 / intentional stub**)
3. *(Note, not fail)* Auction channel does not recommend Inspect★ — consistent with fog SoT focus; call out if auction lots later need optional inspect.

## Findings (severity-ranked)

### S0–S3
**None.**

### S4 / notes
Soft Eng nits above only.

## Evidence paths

| Artifact | Path |
|----------|------|
| Formal report | `/workspace/card-shop-qa/playtest-inspect-star-b8dab3d0.md` |
| QA harness script | `/workspace/card-shop-qa/qa_inspect_star_playtest.gd` (also `tip17/tests/`) |
| Harness log | `/workspace/card-shop-qa/evidence/inspect-star-b8dab3d0/playtest-inspect-star-b8dab3d0.log` |
| Harness JSON | `/workspace/card-shop-qa/evidence/inspect-star-b8dab3d0/playtest-inspect-star-b8dab3d0.json` |
| Foundation log | `/workspace/card-shop-qa/evidence/inspect-star-b8dab3d0/foundation.log` |
| Import log | `/workspace/card-shop-qa/evidence/inspect-star-b8dab3d0/import.log` |
| Tip tree | `/workspace/qa-playtest/tip17/` (tarball tip SHA `b8dab3d0…`) |

### Snapshot (HUD marketplace Inspect★)

```
att_before=100 att_after=95 label="Att 95/100"
fog_cue="Photo only — inspect recommended"
post_cue="Heavy wear"
BuySummary Condition: Heavy wear · Comp range unchanged · Demand STEADY · Confidence Low
distributor: inspect_visible=false · cue="NM assumed"
```

## Recommendation

**Clear** Eng-Approve for PR #17 Inspect★ relative to wireflows §1.2 / systems §4.5+§6.2 / release-criteria truth rules. Soft nits optional follow-ups only.
