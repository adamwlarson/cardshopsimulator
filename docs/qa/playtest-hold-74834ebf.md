# Playtest — HOLD soft polish formal smoke (PR #32)

**Tip:** `74834ebf` (`74834ebf2e158fa52b3bc326a3534b83e4595961`)  
**Date:** 2026-09-04 (~7:03 PM ET)  
**PR:** [#32](https://github.com/adamwlarson/cardshopsimulator/pull/32) — *fix(hold): H1–H4 Att/inherit polish plus H6/H7 icon locks*  
**Checkout:** `/workspace/qa-playtest/hold-74834ebf`  
**SoT:** `docs/design/hold-soft-polish-v1.md`  
**Method:** Godot 4.5.2 headless import + foundation `tests/test_runner.gd` (`_test_hold_soft_polish`); formal `tests/qa_hold_polish_smoke.gd`  
**Harness:** 84 PASS / 0 FAIL / 4 soft  

---

## Verdict: **PASS-with-notes**

| ID | Gate | Result |
|----|------|--------|
| H1 | Att-0 Research disabled; cash alone insufficient; Att≥cost works | **PASS** — `can_research` false at Att 0; `research_set` → `insufficient_attention`; cash alone does not unlock; Research OK at cost=15 |
| H2 | Easy/Hard `staff_noshow_mult` readable/inherit | **PASS** — Easy/Hard/Normal `.tres` + ShopState all **0.4** |
| H3 | Easy/Hard `pull_attention` readable/inherit | **PASS** — Easy/Hard/Normal `.tres` + ShopState pull Att all **5** |
| H4 | StaffPanel Easy/Hard non-blank / no crash | **PASS** — HUD loads; cashier **$80.00** / specialist **$140.00**; roster cap inherit; Easy seeded wage; Hard owner-only |
| H5 | Soft teal polo (Art) | **Won’t-Fix / soft** — Art parallel; do not FAIL |
| H6 | Icon 2× read scale; no price/SKU on bobber | **PASS** — `ICON_READ_SCALE=2.0`; bobber scale `(2,2,2)`; presentation intent-only |
| H7 | Sell fallback Accent_Amber; no burgundy | **PASS** — `COLOR_SELL == ACCENT_AMBER (0.82, 0.52, 0.18)`; IMPORT_NOTES locks Accent_Amber (not burgundy) |
| §4.5 | No truth leaks | **PASS** — UI scan 0 hits; bobber/StaffPanel text clean |
| Option D | Parked | **Noted** — non-blocking |

**Foundation:** `All foundation tests passed.` (includes `_test_hold_soft_polish` covering H1–H4/H6/H7)  
**Clear for merge?** **Yes** — H5 Art Won’t-Fix + Option D parked only.

---

## Checklist (detail)

### H1 — Att-0 Research fold
- [x] Full Att: `can_research` / `can_inspect` / `can_pull` true
- [x] Att 0: Research / Inspect / Negotiate / Pull refused
- [x] Cash alone does not unlock Research
- [x] `research_set` at Att 0 → `ok=false`, reason `insufficient_attention`
- [x] Att ≥ research cost → Research still works

### H2 / H3 — Easy/Hard inherit
- [x] `staff_noshow_mult` Easy/Hard/Normal = **0.4** (BalanceConfig + ShopState)
- [x] `pull_attention` Easy/Hard/Normal = **5** (BalanceConfig + ShopState)
- [x] Easy/Hard `.tres` set explicit values matching Normal defaults

### H4 — StaffPanel Easy/Hard
- [x] `gameplay_hud` loads; Open Staff present
- [x] Cashier wage `$80.00`; specialist `$140.00` (not blank)
- [x] Roster hint uses inherited `staff_cap` (Small=1)
- [x] Specialist wage fallback `14000`; Easy seeded row shows `$`; Hard owner-only empty state
- [x] No crash on Easy/Hard panel open

### H5 — Soft teal polo
- [x] Won’t-Fix / Art parallel — soft note only; do not FAIL

### H6 / H7 — Icon locks
- [x] `CustomerNpc.ICON_READ_SCALE == 2.0`; bobber holder 2×
- [x] Bobber hangs above head (`body_height + ICON_HANG`)
- [x] No price / SKU / truth fields on bobber presentation
- [x] Sell tint = Accent_Amber `(0.82, 0.52, 0.18)`; warm amber (r>g>b); not burgundy
- [x] `prop_icon_sell_01/IMPORT_NOTES.md` locks Accent_Amber; no SKU/price on bobber

### §4.5 / parked
- [x] UI truth leak scan (`true_market` / `p_buy` / `cert_valid`) = 0 hits
- [x] Option D parked; no Art shots required

---

## Soft notes (non-blocking)

1. **H5 soft teal polo** — Art Won’t-Fix / parallel OK; outside Eng HOLD spike FAIL bar.
2. **Option D** event→PriceEditor bridge parked (HOLD OOS).
3. **No Art shots** required for this formal HOLD smoke.
4. **HUD re-instantiate** may log duplicate Signal connect ERRORs after foundation pass (known soft; same as prior C2/C3/apron smokes).

---

## Evidence

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/hold-74834ebf/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/hold-74834ebf/foundation.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/hold-74834ebf/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/hold-74834ebf/smoke.json` |
| Harness | `tests/qa_hold_polish_smoke.gd` (+ copy `/workspace/card-shop-qa/qa_hold_polish_smoke.gd`) |
| Checkout | `/workspace/qa-playtest/hold-74834ebf` @ `74834ebf2e158fa52b3bc326a3534b83e4595961` |
| Report | `/workspace/card-shop-qa/playtest-hold-74834ebf.md` |
| Report (docs/qa) | `/workspace/card-shop-qa/docs/qa/playtest-hold-74834ebf.md` |

### Harness spot (Easy/Hard)

| Diff | staff_noshow_mult | pull_attention | specialist_wage | staff_cap | StaffPanel |
|------|-------------------|----------------|-----------------|-----------|------------|
| easy | 0.4 | 5 | 14000 | 1 | cashier/specialist wages + seeded `$` |
| hard | 0.4 | 5 | 14000 | 1 | wages + owner-only empty |
| normal | 0.4 | 5 | 14000 | 1 | (baseline) |

---

## Blockers

**None.**

---

## Clear for merge?

**Yes** — formal HOLD soft polish smoke green on tip `74834ebf`. H5 Art Won’t-Fix and Option D remain parked/non-blocking.
