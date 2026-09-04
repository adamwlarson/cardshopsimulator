# UI Visual Pass v1 — HUD polish SoT

**Status:** Draft for Eng / Art / QA — sync to main before visual cloud agent  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Depends on:** `ui-wireflows-v1.md` (layouts/fields), `systems-design-v1.md` §4.5 (signal chips), Art `VISUAL_DIRECTION_MVP.md` (cozy-but-serious retail)  
**Scope:** Thin visual/hierarchy polish of existing HUD — **not** new screens, not optional §10 beats, not 3D fixture work.  
**Invariant:** §4.5 forbidden fields stay forbidden. Wireflow field lists unchanged.

---

## 0. Goals (falsifiable)

1. Player can name current **day phase** and **cash** in ≤1s from any Buy/Price/Serve modal.
2. Primary CTA is visually obvious vs Cancel (size/weight/accent) — no twin buttons.
3. Demand/position/move chips read at arm’s length without competing with product title.
4. HUD feels like the same shop as the 3D floor: warm neutrals, calm chrome, product/accent chroma only.

---

## 1. Visual language (align to Art)

| Token | Spec |
|-------|------|
| Panel fill | Cream / warm gray ~#F4F0E8–#E8E2D6 @ 92–96% opacity |
| Panel border | Soft wood-brown or brushed metal edge 1–2px; corner radius 8–12px |
| Dim behind modal | 3D shop dim **40%** (wireflows §0) — keep fixtures readable |
| Text primary | Near-black warm (#1C1917) |
| Text secondary | Muted brown-gray |
| Accent | Muted teal **or** deep burgundy (pick one system-wide) for primary CTA + focused row |
| Danger / Walk risk | Soft red-brown, not neon |
| Font | One UI family; title 18–20, body 14–16, meta 12–13 |
| Icon+text | Chips always icon **and** label (Cold/Steady/Warm/Hot) — color alone fails |

**Do not:** heavy black cel outlines on panels; pure white slabs; arcade neon bars; glassmorphism stacks that wash out cards.

---

## 2. Hierarchy & spacing

| Layer | Content | Visual weight |
|-------|---------|---------------|
| L0 chrome | Phase · Day · Cash · Attention | Persistent top bar; always visible during modals |
| L1 title | Screen name + product/customer | Bold; largest in modal |
| L2 signals | Comp / band / confidence / chips | Grouped strip; secondary weight |
| L3 body | Numbers, lists, patience | Regular |
| L4 actions | Primary / Secondary / Tertiary | Bottom-right cluster; 12–16px gap |

**Spacing:** 8px base grid. Modal padding 16–24. Between signal rows 8. Section break 16. Touch/gamepad hit ≥40px tall.

**Focus:** Keyboard/gamepad focus ring = accent 2px; never rely on color fill alone.

---

## 3. Phase / status readability (L0)

Persistent HUD (even when modal open):

| Element | Format | Pass |
|---------|--------|------|
| Phase | `PREP` / `FLOOR` / `SETTLE` pill | Distinct color per phase; readable at 1080p from 60cm |
| Day | `Day {n}` | Adjacent to phase |
| Cash | `$X,XXX.XX` from BalanceConfig cents | Updates live; never blank |
| Attention | `Att {cur}/{max}` or bar | Visible on FLOOR; optional on PREP |

**Fail:** Phase only in a buried menu; cash only inside one panel.

---

## 4. Panel-specific polish

### 4.1 `BuyOpportunityList` + Detail + Confirm

- List rows: channel tag (left) · bible name (not raw SKU if name exists) · ask · band chip · confidence.
- Selected row: accent left bar + fill 8% accent.
- Detail: product proxy left (fixed square); signal column right matches wireflows §1.2 order.
- Cash/space check line: secondary text; ✓/✗ icon before numbers.
- Primary **Buy** accent; **Cancel** muted; **Haggle** tertiary outline.

### 4.2 `PriceEditor` + Confirm

- Title = bible name · condition (same as §3.2b spirit).
- Chip row (Position / Demand / Move feel) horizontal, equal height, icon+label.
- Suggested price secondary; **Your price** primary input (larger).
- Walk risk / Likely sits: warn styling but **Apply** stays enabled (wireflows §0).

### 4.3 `CustomerServe`

- Header: archetype name + patience bar (bar ≥120px wide).
- **Wants:** §3.2b format only.
- Label column: **Your list** / **You offer** / **Ask** per §3.2a — consistent column width.
- Actions: **Sell at list** primary when buying-from-shop; **You offer** confirm primary on buylist.

---

## 5. Acceptance checklist (QA)

| ID | Check | Severity if fail |
|----|-------|------------------|
| V1 | L0 shows phase + cash during Buy/Price/Serve | S2 |
| V2 | Primary CTA ≠ Cancel twin (weight or accent differs) | S2 |
| V3 | All demand chips have icon+text | S2 |
| V4 | Modal dim leaves counter/case silhouettes readable | S3 |
| V5 | Wants / list titles use bible names where §3.2b applies | S2 |
| V6 | No `true_market` / exact `p_buy` / `cert_valid` introduced | S1 |
| V7 | Focus order: title → fields → primary CTA; Esc cancels | S2 |
| V8 | 1280×720 and 1920×1080: no clipped primary CTA | S2 |

Smoke: open Buy list → Detail → Confirm; PriceEditor; Spike CustomerServe — photograph each; checklist V1–V8.

---

## 6. Out of scope

- New wireflow screens or field additions  
- Optional §10 #3/#5/#9/#10  
- 3D camera (owned by Art SoT / PR #12)  
- Full theme engine / player UI skins  

---

## 7. Handoff

**Eng:** Theme tokens + control restyle on existing scenes; no domain changes.  
**Art:** Accent pick (teal vs burgundy) if not already locked — one sentence to Eng.  
**QA:** Run §5 checklist after tip freeze.  
**PM:** Sync this file to main before visual cloud agent (docs/-forbidden for agents).
