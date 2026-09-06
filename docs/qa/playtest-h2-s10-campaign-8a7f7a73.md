# Playtest report — H2 STOP §10 Normal campaign smoke @ `8a7f7a73` / main `40d633a`

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~2:27 PM ET)  
**Build:** `adamwlarson/cardshopsimulator`  
**Tip SHA used:** `40d633acae1f27e42a98368c139d7f3e17143b26` (main HEAD = exact G1 merge `8a7f7a73becb3f50712398c79466be33ae23c1e1` **+ docs-only** commits: pick-h/g/e Status, G1 report)  
**Tree:** `/workspace/qa-playtest/h2-campaign-8a7f7a73/` (branch `h2-smoke` tracking `origin/main`)  
**Mode:** **Normal** (`data/balance/normal.tres`)  
**Godot:** 4.5.2.stable.official.6ce3de25a (`/home/box/.local/bin/godot`)  
**Scope:** Formal H2 STOP — full §10 beats **#1–#10** reachability on Normal; G1 authenticity spotcheck; §4.5 UI truth nack; Soft `_ensure_priceable_sku` policy callout  
**Method:** Headless — foundation `tests/test_runner.gd` + new harness `tests/qa_h2_campaign_smoke.gd` (BeatInjection day windows / start paths; no new verbs; no debug where natural windows exist)  
**Design SoT:** `docs/design/next-eng-sot-pick-h-v1.md` § H2; `docs/qa/mvp-1.0-release-criteria.md` §3 / day-loop + severity; `docs/design/ui-wireflows-v1.md` §5.1  

**Evidence:** `/workspace/card-shop-qa/evidence/h2-campaign-8a7f7a73/` (`import.log`, `foundation.log`, `campaign_smoke.log`, `campaign_smoke.json`)

---

## Executive verdict

| Gate | Result |
|------|--------|
| Tip resolved (8a7f7a73 or docs-only ahead) | **PASS** — used `40d633a` = `8a7f7a73` + docs-only |
| Godot import clean | **PASS** (`IMPORT_EXIT:0`) |
| Foundation `tests/test_runner.gd` | **PASS** — `All foundation tests passed.` (`EXIT:0`) |
| Campaign harness #1–#10 | **PASS** — **120 PASS / 0 FAIL**; `SOFT_COUNT=2` |
| §4.5 UI truth nack (`true_market` / `p_buy` / `cert_valid`) | **PASS** — 0 hits on hud / presenter / main_menu / gameplay_hud |
| G1 authenticity (fake slab path) | **PASS** — `cert_valid=false`, fog cue clean |
| Soft `_ensure_priceable_sku` | **Parked** — not required for §10 Normal reachability |
| S0–S2 blockers | **None** |
| Eng S2+ standby needed? | **No** |
| H3 Soft closeout needed? | **No** (keep parked; Won’t-Fix candidate for later hygiene) |

**Overall: PASS-with-notes**

Full §10 Normal campaign arc #1–#10 is reachable via BeatInjection day windows / catalog seeds without new verbs. Notes are Soft-only (parked Soft seed policy + G1 intact confirmation). No Eng systems work required from this stop.

**Clear for Eng S2+?** **No** (nothing S2+).  
**Recommend H3?** **No** — Soft not blocking demos or campaign smoke.

---

## Per-beat table (#1–#10)

| # | Beat | Status | Evidence (one-liner) |
|---|------|--------|----------------------|
| 1 | Price seed Dustway ETB (`AA-DUST-ETB`) | **PASS** | Day1 priceable stock includes Dustway; `price_signal` DTO has no truth fields; HUD binds `priceable_stock_signals` (no hardcoded SKU); tip `40d633a` |
| 2 | Distributor MOQ | **PASS** | Day1 `BuyOpportunityCatalog` has `beat_id=distributor_moq` channel DISTRIBUTOR qty=8; Dustway buy also present; tip `40d633a` |
| 3 | Marketplace outing (Drive/Courier/Skip) | **PASS** | Day3 PREP `sec10_3_marketplace_outing` starts without debug (survives active FOG); choices `drive_out`/`courier`/`skip`; modal “Off-site lot — leave the floor?”; Skip completes; tip `40d633a` |
| 4 | Spike staple Bastion/Arcbolt | **PASS** | Day3 FLOOR `sec10_4_spike_staple` → Spike wants `AA-BASE-088`; CustomerServe “Your list”; refuse completes + `beat_completed`; tip `40d633a` |
| 5 | Hire first cashier | **PASS** | Day5 PREP `sec10_5_hire_cashier`; choices `hire_cashier`/`keep_solo`/`hire_cheap`/`hire_specialist`; Keep solo completes; tip `40d633a` |
| 6 | Rent fire-sale (Hard loan hidden) | **PASS** | Day7 PREP `sec10_6_rent_firesale`; fire_sale + accessories + loan enabled on Normal; Hard `loan_enabled=false` + button hidden/disabled + payday rejected; tip `40d633a` |
| 7 | Titan hype + Option D PriceEditor | **PASS** | Day8 `sec10_7_titan_hype` → `price_focus` `AA-SKIE-047`; band HOT; PriceEditor open; Cancel completes; tip `40d633a` |
| 8 | Slab vs singles / rotate | **PASS** | Day11 `sec10_8_slab_vs_singles`; slab/singles/rotate buttons live; Empress seeded; rotate completes + reversible; tip `40d633a` |
| 9 | Expand Medium | **PASS** | Day18 PREP `sec10_9_expand_medium`; `sign_lease`/`wait_for_rep`/`stay_small`; Stay Small completes; tip `40d633a` |
| 10 | Shady trunk Buy/Report/Ignore | **PASS** | Day20 Night/PREP `sec10_10_shady_trunk` after expand resolve; Buy/Report/Ignore; Ignore completes; tip `40d633a` |

**G1 (cheap):** Fake shady slab path still intact — 100% fake rate → `cert_valid=false`, uninspected, fog cue without truth tokens.

---

## Blockers (severity-ranked)

| Severity | ID | Summary | Disposition |
|----------|----|---------|-------------|
| — | — | **None found** (S0–S4 empty for this tip/smoke) | — |

Known Soft notes (non-blocking, not filed as defects):

1. Soft `_ensure_priceable_sku` remains in `demand_signals.gd` for empty-SKU HYPE/FOG → PriceEditor demos only.  
2. G1 authenticity confirmed intact (informational SOFT line in harness).

---

## Soft seed policy recommendation

**Recommend: keep parked** (eligible later **Won’t-Fix** under H3 hygiene — do **not** open H3 from this stop).

**Rationale:**

- Day1 Normal already seeds `AA-DUST-ETB` into priceable stock; §10 #1 does **not** need Soft inject.  
- §10 #7 Titan path seeds via BeatInjection / inventory before Option D PriceEditor; Soft is only a fallback inside `resolve_event_price_sku()` when HYPE/FOG fires with no priceable SKU.  
- Campaign smoke #1–#10 all PASS without Soft. Soft papers empty-SKU demos only — not a true campaign or demo blocker for the bible arc.  
- Per pick-h: Soft stays parked unless Soft is actively blocking; it is not.

---

## Instrumentation notes

Harness recorded `beat_started` / `beat_completed` (QaInstrumentation force-enabled) for scripted beats #3–#10 where BeatDirector emits them. #1/#2 are catalog/seed reachability (no `sec10_*` beat_id on picker rows beyond `distributor_moq`).

No new player verbs introduced. Harness lives only under the playtest tree (`tests/qa_h2_campaign_smoke.gd`) — not pushed.

---

## Clear for Eng / next pick?

| Question | Answer |
|----------|--------|
| Eng S2+ standby from this report? | **No** — no S2+ findings |
| Open H3 Soft closeout now? | **No** — keep Soft parked |
| H2 STOP complete? | **Yes** — written #1–#10 reachability report delivered |
| Suggested next | Design/PM may advance past H2 (e.g. H1 online listings when ready); Soft → Won’t-Fix optional later via H3 |

---

## Reproduction

```bash
# Tip
cd /workspace/qa-playtest/h2-campaign-8a7f7a73
git rev-parse HEAD   # 40d633acae1f27e42a98368c139d7f3e17143b26

# Foundation
godot --headless --path . --script res://tests/test_runner.gd
# → All foundation tests passed.

# Campaign smoke
godot --headless --path . -s res://tests/qa_h2_campaign_smoke.gd
# → OVERALL=PASS-with-notes ; BEAT_1..10=PASS
```

## Sync

Synced to main by Card Shop PM (2026-09-06). H2 complete — no Eng S2+; Soft keep parked; H3 No.
