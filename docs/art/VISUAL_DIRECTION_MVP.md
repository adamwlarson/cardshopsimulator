# Card Shop Simulator — Visual Direction MVP

Status: Adopted (PM lock 2026-09-04)

## North star

The shop is **cozy but serious, stylized-real**: welcoming enough to invite browsing, grounded enough that rent, inventory value, and closing risk carry weight. Shapes and materials are simplified for readability, but scale, circulation, fixtures, and lighting should feel like a plausible small retailer rather than a toy diorama.

## Materials and palette

The core material story is **wood, glass, and metal**:

- warm mid-tone wood for counters, shelf accents, and human warmth;
- clean, slightly imperfect glass for high-value cases;
- dark powder-coated or brushed metal for frames, register hardware, and security;
- restrained neutral floor/walls so colorful fictional products remain focal;
- teal/cyan utility accents and warm amber task lighting.

Avoid extreme grime, luxury showroom sterility, neon cyberpunk, excessive bloom, and photoreal surface noise. Wear communicates use without making the shop feel unsafe.

## Scale and composition

Use meters and Godot's `1 unit = 1 meter`. Author against a **0.9 m layout tile**. The small-shop footprint is **10×8 tiles (9×7.2 m, approximately 698 sq ft)**. Preserve human-scale counters, reachable shelves, believable aisles, and clear interaction faces.

At the gameplay camera, silhouettes and interaction states matter more than tiny packaging details. Value contrast should lead from entrance to merchandise to counter. Keep floors visually quiet for navigation overlays.

## P0a readability gate

Before expanding the prop library, a review at target camera distance must identify these without UI labels:

1. service counter;
2. locked glass display cases;
3. point-of-sale register;
4. buylist/appraisal intake tray;
5. sealed/accessory shelving;
6. backstock bins;
7. entrance and customer path.

Counter, case, register, and tray cannot collapse into one undifferentiated block. Cases need transparent display volume; the register needs a terminal/screen silhouette; the tray needs a bounded intake surface distinct from sellable stock. P0a is an Engineering/Art/QA gate, not a polish wish.

## Asset pipeline

- Model in meters with transforms applied and sensible origins/pivots.
- Face forward consistently; document exceptions for modular walls/fixtures.
- Prefer clean topology, UVs, and a small reusable material set.
- Use Principled/PBR inputs: base color, metallic, roughness, normal, and optional ambient occlusion/emission.
- Export **GLB** with embedded mesh/material references; keep editable source files outside runtime import folders when appropriate.
- Validate scale, normals, tangents, transparency sorting, collisions, and Forward Plus appearance in a neutral test scene.
- Use texture dimensions proportionate to screen size; atlas small product fillers where practical.
- Name assets by domain and purpose, not software defaults.

Glass must remain readable against the shop background without becoming opaque blue plastic. Prefer restrained roughness/reflection and strong frame silhouettes. Transparent case performance is part of the gate.

## Fictional products and AI policy

All visible card products use the fictional **Aether Arc TCG** bible and `AA-*`/`ACC-*` identifiers. No real-game trade dress, logos, card frames, set symbols, grading brands, or recognizable characters.

Generative AI output is **filler only** for internal blockout and temporary low-salience packaging. It cannot establish canon, become final key art/branding, imitate a living artist or real franchise, or ship without human art/legal review and provenance tracking. Replace conspicuous AI filler before content lock.

## Lighting and UI relationship

Use warm key/task lighting with cooler ambient fill, legible contact shadows, and controlled exposure. The player must distinguish empty from stocked fixtures and read the register/counter during bright and dim event states.

World color must leave room for HUD severity colors. Do not depend on color alone for selection, invalid placement, value, or urgency; pair it with shape/icon/text.

## MVP acceptance

- P0a props pass unlabeled silhouette/readability review.
- Shop proportions align with the 10×8 grid and navigation checks.
- Representative wood, glass, and metal materials render correctly in Forward Plus.
- One AA-SKIE sealed box, one AA-BASE single placeholder, and `ACC-SLV-60` read as separate product classes.
- No unlicensed or real-TCG placeholder survives review.
- Performance target and LOD budgets are measured after representative fixture stocking, not on an empty room.
