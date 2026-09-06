# Playtest report — M2 STOP Large shell + lease re-smoke @ `83885e7d` (main post #41)

**Scorer:** CSS QA (executor)  
**Date:** 2026-09-06 (~3:48 PM ET)  
**Tip SHA:** `83885e7dc1fafe468a9de1e7d89458851ce19dd7` (short `83885e7d`)  
**Tip note:** docs-only ahead of stub-swap merge `2afba0c2024491df90b43d8b2c0d872c42781784` (PR #41); `2afba0c2` **is** ancestor of `origin/main` (ahead_by 2).  
**Repo extract:** `/workspace/qa-playtest/m2-83885e7d/` (fresh clone @ `origin/main` HEAD)  
**Method:** Godot 4.5.2 — import `--editor --quit-after 180`; foundation `tests/test_runner.gd`; focused `tests/qa_large_shell_swap_smoke.gd` (adapted from #41 formal for tip/evidence paths) under xvfb; aisle viewport PNG  
**Mode:** Normal  
**Design SoT:** `docs/design/next-eng-sot-pick-m-v1.md` § M2  
**Priors:** L1 economy `49f0153a` (#39); Art Large `91e2020a` (#40); Large stub-swap `ec34ba6f` / merge `2afba0c2` (#41)  
**Softs parked:** Soft seed / Soft far crest / Soft `apply_medium_capacity` naming

---

## Verdict: **PASS-with-notes**

**Clear for Eng S2+? NO**

M2 is a formal QA STOP / re-smoke beat only (no new systems, no new verbs). Tip clears Sign→Large with live Art hero shell + L1 economy on main post stub-swap. Soft notes remain non-blocking and **keep parked**. Eng stays on **M1** (Counterfeit scare spike) — do not treat this STOP as Eng S2+ clearance. **No S0–S2 blockers.**

| Gate | Result |
|------|--------|
| 1. Written report | **PASS** (this doc) |
| 2. Sign / Wait / Stay paths | **PASS** |
| 3. Large shell visible (`ShopShellLarge` / `prop_shop_shell_large_01`); Small+Medium hidden; scaffold gone | **PASS** |
| 4. Soft callout (keep parked) | **PASS** |
| 5. No new verbs | **PASS** |
| A. Gate Cash≥$40k + Rep70 | **PASS** |
| B. Sign → rent $4k / staff 5 / 18×13 / traffic 1.25× | **PASS** |
| C. Wait/Stay keep Medium shell | **PASS** |
| D. No fog veil | **PASS** |
| E. §4.5 clean | **PASS** |
| F. Soft seed / Soft far crest / Soft `apply_medium_capacity` naming parked | **PASS** |

**Harness:** 135 PASS / 0 FAIL / 3 soft  
**Foundation:** `All foundation tests passed.` EXIT:0  
**Import:** Godot `--editor --quit-after 180` EXIT:0

---

## Soft policy (keep parked)

| Soft item | Disposition |
|-----------|-------------|
| Soft seed `_ensure_priceable_sku` | **Keep parked.** Still defined; HYPE/FOG bridge only. Large shell / L1 surfaces (`shop_floor_extent`, `shop_state`, `beat_injection`) do **not** call it. |
| Soft far crest (Art Large thin roof/wall crest at far FOV) | **Parked OOS** from Art #40 — non-blocking for M2 re-smoke. |
| Soft `apply_medium_capacity` naming on Large stacked bonuses | **Soft parked (S4).** Large Sign still calls Medium-named capacity helper; functional capacity correct; rename is hygiene-only. |

---

## Checklist (pass bar detail)

### M2 acceptance
- [x] Written report delivered (root + `docs/qa/`)
- [x] Sign / Wait / Stay paths exercised under Normal
- [x] Sign → `Architecture/ShopShellLarge` visible; family `prop_shop_shell_large_01`; SW origin; scale `(1,1,1)`
- [x] Small + Medium Art shells **hidden** when Large active
- [x] Procedural Large scaffold **gone** (`has_large_scaffold` false; no `LargeFloor` / walls; FloorExtent child count 0)
- [x] Soft callout reaffirm — keep parked
- [x] No new verbs (reuse Sign / Wait / Stay / `expand_to_large` / `can_sign_large_lease` / `choose_beat_path` only)

### L1 / #41 bars (re-smoke)
- [x] Unlock: Cash ≥ $40k **AND** Rep ≥ 70 — Sign gated below; choose nacks
- [x] Exact gate: Sign enabled → Large tier
- [x] Sign → weekly rent **$4,000** + staff cap **5** + grid **18×13** (234 tiles) + traffic **1.25×**
- [x] Wait / Stay keep Medium tier + Medium Art shell; Large hidden; scaffold absent
- [x] `has_fog_veil() == false`; no `MediumVeilX` / `MediumVeilZ`; env fog / volumetric fog nacked
- [x] §4.5: lease confirm + decision payload clean (no `true_market` / `p_buy` / `cert_valid`)
- [x] Walkable SoT: 18×13 @ 0.9 m (16.2×11.7 / ~2040 sq ft); circulation + NPC paths hold
- [x] Soft seed / Soft far crest / Soft `apply_medium_capacity` naming — **keep parked**

---

## Soft nits (non-blocking)

1. **Soft seed keep parked** — `_ensure_priceable_sku` remains for HYPE/FOG only.
2. **Soft far crest** — Art Large thin crest at far FOV; OOS for M2.
3. **`apply_medium_capacity` naming** — Large Sign reuses Medium-named helper for stacked totals; rename parked S4.

---

## Method notes

- Harnesses `qa_l1_*` / `qa_large_shell_*` are **not** on `main`; reused/adapted from prior formals into checkout `tests/`.
- Primary focused harness = adapted `qa_large_shell_swap_smoke.gd` (covers shell + Sign/Wait/Stay + L1 economy + §4.5 + Softs).
- Unmodified `qa_l1_large_expand_smoke.gd` **not executed**: still asserts scaffold-interim visibility (pre-#41) and would false-FAIL post stub-swap. Saved under evidence as `.reference_not_run`.

---

## Evidence

| Artifact | Path |
|----------|------|
| Import log | `/workspace/card-shop-qa/evidence/m2-83885e7d/import.log` |
| Foundation log | `/workspace/card-shop-qa/evidence/m2-83885e7d/foundation.log` |
| Smoke log | `/workspace/card-shop-qa/evidence/m2-83885e7d/smoke.log` |
| Smoke JSON | `/workspace/card-shop-qa/evidence/m2-83885e7d/smoke.json` |
| Summary JSON | `/workspace/card-shop-qa/evidence/m2-83885e7d/summary.json` |
| Tip SHA | `/workspace/card-shop-qa/evidence/m2-83885e7d/tip_sha.txt` |
| Viewport PNG | `/workspace/card-shop-qa/evidence/m2-83885e7d/large-shell-swap-aisle.png` |
| QA harness | `/workspace/qa-playtest/m2-83885e7d/tests/qa_large_shell_swap_smoke.gd` (+ evidence copy) |

---

## Commands

```bash
godot --editor --path /workspace/qa-playtest/m2-83885e7d --quit-after 180
godot --headless --path /workspace/qa-playtest/m2-83885e7d --script res://tests/test_runner.gd
xvfb-run -a godot --path /workspace/qa-playtest/m2-83885e7d -s res://tests/qa_large_shell_swap_smoke.gd
```

---

## Overall

**PASS-with-notes** — Clear for Eng S2+ **NO** (M2 = QA STOP only; Eng remains M1). Soft policy: **keep parked**. No S0–S2 blockers. Blockers: **none**.

## Ship note

M2 PASS on main @ `83885e7dc1fafe468a9de1e7d89458851ce19dd7` (2026-09-06). Clear Eng S2+? **NO**. Softs keep parked. M1 Counterfeit Eng still in flight.
