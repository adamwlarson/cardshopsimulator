# HUD visual constraints (MVP) — don’t fight the aisle camera

**Owner:** CSS Art Lead  
**For:** Eng UI visual pass (HUD only — not B09+)  
**SoT:** `VISUAL_DIRECTION_MVP.md` + locked shop Camera on main

## Locked shop camera (frame to protect)
```
position = Vector3(4.5, 1.65, -1.8)
rotation_degrees = Vector3(-28, 0, 0)
fov = 70.0
```
Eye-height aisle view into the shop (−Z). Mid fixtures (counter/case/shelf) occupy roughly the **lower 55–70%** of the frame; ceiling lights sit near the **top band**.

## Palette (from style guide)
| Role | Spec |
|------|------|
| Neutrals | Warm wood / cream / medium-gray floor language |
| Accent | **Muted teal** or **deep burgundy** only (≤15% of chrome) |
| Product chroma | Left to 3D / SKU art — HUD stays calm |
| Rule | **60% neutrals / 25% product pop / 15% accent** — cap saturation on panels |

## Type & chrome
- Prefer **clean sans** UI type; high contrast on dark translucent panels
- **UI owns fine print** — no competing 3D world labels for prices/names
- Icons + short labels over walls of text
- Accent used for **state/CTA** (selected, confirm, OPEN-adjacent), not every border

## Layout vs aisle frame (hard constraints)
1. **Keep center-lower third clear** — counter/case silhouette must stay readable under default cam  
2. **Chrome hugs edges:** top status strip + side/bottom panels OK; avoid full-screen opaque sheets during FLOOR  
3. **Max HUD opacity:** ~70–85% on panels so wood/glass still read through; no pure black full-bleed  
4. **Safe margins:** ≥48–64 px from viewport edges; don’t cover register silhouette or case glass front  
5. **Modal exception:** PREP/SETTLE/buy/price modals may center, but dim world with a soft veil — don’t recolor the 3D scene  
6. **No neon/cel HUD** — no heavy outlines; match soft-bevel retail tone  
7. **Don’t “fix” FOV or cam** from UI code — camera SoT is Art/Eng locked  

## Do / Don’t
| Do | Don’t |
|----|-------|
| Dark cream/charcoal panels + muted teal CTAs | Hot neon cyan/magenta chrome |
| One accent for primary action | Accent on every chip/border |
| Compact top bar (Day/Phase/Cash/Attention) | Tall HUD eating fixture band |
| Wants/list rows as readable type | SKU-id walls (Design §3.2b: bible name + condition) |

## Acceptance (Art smoke)
From default shop cam on main: fixtures still silhouette; HUD never fully occludes counter transaction edge or case look-face; accent ≤15% of visible chrome; no camera/FOV mutation from UI.
