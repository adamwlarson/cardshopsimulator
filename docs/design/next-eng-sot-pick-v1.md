# Next Eng SoT Pick v1 — Attention deepen vs Medium floor growth

**Status:** Adopted — Option A shipped (#19 @ 2d3569f4); Option B in flight (eng `bc-f33c888e`)  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Updated:** 2026-09-04 — track spike outcomes (no new design)  
**Depends on:** systems-design §6.2 / §7.3, ui-wireflows §5.1 #9, difficulty-curves Normal defaults.

---

## Context

- Inspect★ uses existing wireflows §1.2 (no new design doc).
- Optional §10 #3/#5/#9/#10 hooks are shipping; #9 **Sign lease** today can change rent/staff cap without a real bigger floor.
- Attention is mostly pool + a few spends; Research / layout rearrange are thin or missing as player verbs.

---

## Option A — Deepen Attention (Research + layout costs) — **SHIPPED**

**Outcome:** Merged PR #19 → main @ `2d3569f4` (Eng APPROVE-with-notes + QA PASS-with-notes). Soft S4 parked.

**Player fantasy:** Owner time is scarce; smart prep (research, rearrange) beats panic FLOOR multitasking.

| Deliverable | Spec |
|-------------|------|
| Research action | PREP (and/or quiet FLOOR): pick a set → spend **$50 + Att 15** (Normal; difficulty-curves table) → 24–72h soft telegraph for rotation + narrower comps/bands for that set (§4.5 Research gates) |
| Layout rearrange | PREP: move fixture instance on grid → **Att 10**; blocked if pathing breaks entrance→displays→counter |
| HUD | Show Att cost on Research / Rearrange buttons before confirm; refuse if Att < cost |
| Specialist | On duty: Research Att 15→~10; Inspect already 5→2 |

**Acceptance (falsifiable):**

1. Research with Att≥15 + cash reduces demand-band σ / comp width for target set (QA can read instrumentation).
2. Research does **not** reveal true condition / `cert_valid`.
3. Rearrange spends Att 10 and rejects illegal pathing; free rearrange without Att = fail.
4. At Att 0, Research/Rearrange disabled; cashiers still sell.

**Out:** New staff roles; full free-form build mode; Attention on every UI click.

**Modules:** `economy` + `shop` + thin `ui` + existing DemandSignal fog hooks.

---

## Option B — Medium expand = actual floor growth — **IN FLIGHT**

**Outcome:** Eng cloud agent `bc-f33c888e` in flight. Medium dims stay **14×10** (140 tiles ≈ ~1,020 sq ft @ 0.9 m) unless Art/Eng flags a tighter lock.

**Player fantasy:** Signing Medium isn’t just a rent buff — the shop **gets bigger** and pathing/staff capacity matter.

| Deliverable | Spec |
|-------------|------|
| Grid upgrade | On `sign_lease` (#9): Small **10×8** → Medium **14×10** (140 tiles ≈ ~1,020 sq ft @ 0.9 m); `staff_cap` 1→3 already |
| Rent | Apply `rent_medium_weekly_cents` next SETTLE week (already on BalanceConfig Normal) |
| Placement | Existing fixtures stay; new empty tiles unlock; rearrange uses Option A Att 10 (now shipped) |
| Pathing | Recompute customer paths; fail expand preview if counter unreachable |
| Camera/shell | Art: extend floor/walls OR fog unused — Art Lead one-liner before/during eng |

**Acceptance (falsifiable):**

1. After Sign, walkable tile count increases; staff cap = 3; weekly rent = Medium.
2. Stay Small / Wait for Rep leave grid unchanged.
3. Customers path entrance→displays→counter on Medium without soft-lock.
4. Save/load restores Medium grid + rent tier.

**Out:** Large tier; multi-floor; auto-furniture fill.

**Modules:** `shop` (grid/tier) + `economy` rent + light `ui` lease confirm (exists) + Art shell.

---

## Decision log

| Pick | Result |
|------|--------|
| A first | Shipped — PR #19 @ `2d3569f4` |
| B next | In flight — eng `bc-f33c888e`; Medium **14×10** locked for this spike |

---

## PM checklist

- [x] Choose **A** or **B** → A first, then B
- [x] Sync this file to main before cloud agent (A)
- [ ] If B: Art confirms Medium footprint + shell approach (14×10 working lock)
- [ ] Sync this status update to main
- [ ] B tip-freeze → Eng → QA → merge

