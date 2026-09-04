# Next Eng SoT Pick v1 — Attention deepen vs Medium floor growth

**Status:** Ready for PM choice (after Inspect★ lands)  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Pick one** for the next eng spike. Other parks.  
**Depends on:** systems-design §6.2 / §7.3, ui-wireflows §5.1 #9, difficulty-curves Normal defaults.

---

## Context

- Inspect★ uses existing wireflows §1.2 (no new design doc).
- Optional §10 #3/#5/#9/#10 hooks are shipping; #9 **Sign lease** today can change rent/staff cap without a real bigger floor.
- Attention is mostly pool + a few spends; Research / layout rearrange are thin or missing as player verbs.

---

## Option A — Deepen Attention (Research + layout costs)

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

**Why pick A:** Tightens the owned bandwidth fantasy with systems already half-written; low art dependency.

---

## Option B — Medium expand = actual floor growth

**Player fantasy:** Signing Medium isn’t just a rent buff — the shop **gets bigger** and pathing/staff capacity matter.

| Deliverable | Spec |
|-------------|------|
| Grid upgrade | On `sign_lease` (#9): Small **10×8** → Medium grid (propose **14×10** = 140 tiles ≈ ~1,020 sq ft @ 0.9 m — or Art/Eng lock nearest tile dims to ~1,200 sq ft usable); `staff_cap` 1→3 already |
| Rent | Apply `rent_medium_weekly_cents` next SETTLE week (already on BalanceConfig Normal) |
| Placement | Existing fixtures stay; new empty tiles unlock; player may rearrange (Att cost only if Option A also shipped — else free one-time migrate) |
| Pathing | Recompute customer paths; fail expand preview if counter unreachable |
| Camera/shell | Art: extend floor/walls OR fog unused — **needs Art Lead one-liner** before eng starts |

**Acceptance (falsifiable):**

1. After Sign, walkable tile count increases; staff cap = 3; weekly rent = Medium.
2. Stay Small / Wait for Rep leave grid unchanged.
3. Customers path entrance→displays→counter on Medium without soft-lock.
4. Save/load restores Medium grid + rent tier.

**Out:** Large tier; multi-floor; auto-furniture fill.

**Modules:** `shop` (grid/tier) + `economy` rent + light `ui` lease confirm (exists) + Art shell.

**Why pick B:** Makes #9 a real spatial decision; needs Art coordination.

---

## Recommendation (non-binding)

**Prefer A first** if Art is still holding B09+ / shell work — ships owned-time pressure without new mesh.  
**Prefer B first** if Adam wants the expand fantasy to feel physical before more economy verbs.

---

## PM checklist

- [ ] Choose **A** or **B**
- [ ] If B: Art confirms Medium footprint + shell approach
- [ ] Sync this file to main before cloud agent
- [ ] Loser becomes the following spike

