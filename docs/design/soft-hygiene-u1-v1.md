# Soft Hygiene U1 v1 — disposition table

**Status:** **U1 SHIPPED** — SH8 rename #50 @ eb5e1a5a; SH1–SH6 Won’t-Fix MVP; SH7 Art later; Soft no mode-picker CLOSED; QA PASS-with-notes.
**Author:** CSS Designer  
**Date:** 2026-09-06  
**Depends on:** pick-u Adopted **U1 GO**; Soft no mode-picker CLOSED (#49)  
**Rule:** No new player verbs. §4.5 untouched. Each Soft is **Won’t-Fix** / **Delete** / **Eng rename** / **Art later** — no “keep parked forever.”

---

## 0. Goals (falsifiable)

1. Every row below has a disposition + owner.
2. Eng ACK closes U1 for Eng; QA spot-check none or S3-only if a delete/rename risks demos.
3. Soft no mode-picker is already **CLOSED** (#49) — do not reopen.

---

## 1. Disposition table

| ID | Soft | Disposition | Owner | Notes / acceptance |
|----|------|-------------|-------|-------------------|
| SH1 | `_ensure_priceable_sku` / empty-SKU seed inject | **Won’t-Fix** (demo-only) **or Delete** if unused in production paths | Eng | Prefer **Delete** if PriceEditor / formal paths never need it; else Won’t-Fix with one-line demo note. |
| SH2 | Soft Fri Convention settle-weight spill (Mon/Tue) | **Won’t-Fix** MVP | Eng | Sat/Sun peak SoT; spill Soft OK MVP stands. |
| SH3 | Soft EventBanner-only Theft rumor (thin HUD) | **Won’t-Fix** MVP | Eng | EventBanner-only Soft OK MVP stands. |
| SH4 | Soft flipper-weight as Recession buylist↑ | **Won’t-Fix** MVP | Eng | Soft OK if sell-pressure shows. |
| SH5 | Soft dual cash-eval Flagship paths | **Won’t-Fix** MVP | Eng | Soft OK if award idempotent. |
| SH6 | Soft Sandbox PB bump on `start_new_game` (day-1) | **Won’t-Fix** MVP | Eng | Soft OK MVP; T1 closed Soft no mode-picker. |
| SH7 | Soft far crest thin (J2 badge) | **Art later** | Art | Dual-track polish; not Eng U1 code. |
| SH8 | Soft `apply_medium_capacity` naming | **Eng rename** **or Won’t-Fix** | Eng | Prefer rename to Large-aware name if cheap; else Won’t-Fix. |
| SH9 | Soft teal polo / other Art Softs already Won’t-Fix | **Closed** | — | Do not reopen (H5 etc.). |

---

## 2. Eng ACK checklist

- [x] SH1: **Won’t-Fix** (Hype/Fog empty-SKU bridge still calls it)
- [x] SH2–SH6: **Won’t-Fix** MVP (Eng ACK)
- [x] SH7: Art ACK “later” (no Eng code) — **Art later** locked
- [x] SH8: **Eng rename DONE** → `apply_shop_capacity_bonuses` (#50)
- [x] No new economy verbs; §4.5 clean
- [x] Foundation suite still green if code touched

---

## 3. QA

Spot-check only if SH1 Delete or SH8 rename lands — S3 smoke PriceEditor / Large expand / Flagship award. Otherwise no formal.

---

## Decision log

| When | Decision |
|------|----------|
| 2026-09-06 | Design Soft table ready for Eng ACK (U1). |
| 2026-09-06 | Eng ACK: SH1 Won’t-Fix; SH2–SH6 Won’t-Fix MVP; SH7 Art later; SH8 rename preferred (`apply_shop_capacity_bonuses`). |
| 2026-09-06 | Art ACK SH7 Soft far crest → Art later (dual-track). |
| 2026-09-06 | U1 SHIPPED — #50 SH8 rename merged path; Soft catalog closed. |
