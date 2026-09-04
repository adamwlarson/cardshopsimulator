# HOLD Soft Polish Sweep v1 — Eng checklist

**Status:** Adopted — Eng spike in flight (H1–H4 + code H6/H7); H5 Art parallel / Won’t-Fix OK  
**Author:** CSS Designer  
**Date:** 2026-09-04  
**Depends on:** pick-e HOLD option; C1–C3 / apron / MidCenter shipped  
**Rule:** **No new player verbs.** Fix or Won’t-Fix each soft. §4.5 fog never leaks. Option D stays parked.

---

## 0. Goals (falsifiable)

1. Every item below is either **PASS** (fixed + QA) or **Won’t-Fix** (named owner + reason) before the spike closes.
2. No new screens, beats, events, or staff roles.
3. Normal BalanceConfig bible defaults unchanged unless a soft explicitly requires Easy/Hard inherit.

---

## 1. Checklist

| ID | Soft | Owner | Acceptance (PASS) | Sev if still broken |
|----|------|-------|-------------------|---------------------|
| H1 | `can_research` Att-0 fold | Eng | At Att 0, Research is disabled/refused (same as other owner Att verbs); with Att ≥ cost, Research still works | S2 |
| H2 | Easy/Hard inherit `staff_noshow_mult` | Eng | Easy/Hard `.tres` either set explicit values **or** inherit Normal via documented BalanceConfig default; QA can read effective mult on each difficulty | S3 |
| H3 | Easy/Hard inherit `pull_attention` | Eng | Same as H2 for `pull_attention` (or equivalent Pull Att cost export) | S3 |
| H4 | StaffPanel Easy/Hard `.tres` omissions | Eng | StaffPanel / staff UI does not crash or show blank costs on Easy/Hard; missing overrides fall back to Normal without error | S2 |
| H5 | Soft teal polo (cashier vs C1) | Art | Cashier polo reads distinct from C1 at approach + interact (or Won’t-Fix: “intentional near-match”) | S3 |
| H6 | Intent icon 2× read scale | Eng/Art | Billboard icons readable behind-desk without clipping; scale documented; no price/SKU on bobber | S3 |
| H7 | Sell icon fallback tint vs `Accent_Amber` | Art/Eng | Sell bobber / fallback tint matches warm amber lock (customer-npc-v1); no burgundy regress | S3 |

**Already closed (do not reopen):** MidCenter AABB (#31 @ `53009c84`); apron FOV (#30).

---

## 2. Out of scope

- Option D event→PriceEditor bridge  
- New §10 beats / Large expand / dialogue  
- Rebalancing Normal economy scalars  
- Heavier décor beyond parked Art backlog  

---

## 3. QA bar

- Run on **Normal** first; spot-check Easy/Hard only for H2–H4.  
- H1: Att 0 → Research blocked; cash alone insufficient.  
- H5–H7: visual spot vs existing QA shots; no full FLOOR replay required if harness asserts.  
- Any new truth leak (§4.5) = automatic S1 / spike fail.

---

## 4. Handoff

**Eng:** H1–H4 (+ H6/H7 if code-side). Tip-freeze → Eng → QA.  
**Art:** H5 (+ H7 tint if mesh/material). Parallel OK.  
**PM:** Sync this file; launch HOLD spike; D stays parked until Adam overrides.

