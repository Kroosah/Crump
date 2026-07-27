# CRUMP — Bekende issues (KNOWN_ISSUES.md)

*Elk bekend probleem dat niet direct wordt opgelost, staat hier — hoe klein
ook. Een bug die alleen in een gesprek of een hoofd bestaat, bestaat niet.
**Verplicht bijhouden** bij elke taak (zie CLAUDE.md).*

## Werkwijze

- **Elke bevinding krijgt een entry** met ID (`KI-xxx`), datum, ernst en een
  reproduceerbare omschrijving. Fixen mag pas "klaar" heten als de entry is
  afgesloten met verwijzing naar de commit.
- **Ernst**:
  - **Blocker** — verhindert werken of spelen; wordt vóór al het andere opgepakt.
  - **Ernstig** — breekt een systeem of de immersie; inplannen in de
    eerstvolgende relevante taak.
  - **Klein** — hinderlijk maar omzeilbaar; batchen bij gerelateerd werk.
- Een issue dat een bewuste beperking blijkt ("werkt zo by design") wordt
  afgesloten met die conclusie — niet stilletjes verwijderd.
- QA-bevindingen (QA_CHECKLIST) die niet direct gefixt worden, landen hier.

## Formaat

```
## KI-001 — Korte titel
**Datum**: jjjj-mm-dd · **Ernst**: Blocker/Ernstig/Klein · **Status**: open/opgelost (commit)
**Waar**: systeem/scène/bestand
**Omschrijving**: wat gaat er mis, hoe reproduceer je het, wat was verwacht.
```

---

## Open issues

*Geen.*

## Opgeloste issues

## KI-001 — Developer room toont een egaal grijs beeld
**Datum**: 2026-07-27 · **Ernst**: Blocker · **Status**: opgelost (CHANGELOG v0.0.7)
**Waar**: `game/levels/dev_room/dev_room.tscn`
**Omschrijving**: bij `F5` op de dev-pc (Windows, Vulkan Forward+, Intel UHD
Graphics, preset DEVELOPMENT_LOW) vulde het venster zich met egaal grijs,
terwijl de logs schoon waren en meldden dat de dev room geladen was.
**Oorzaak**: het project bevatte geen enkele `Camera3D`. Zonder actieve camera
rendert Godot de 3D-wereld niet; de viewport wordt dan gevuld met
`rendering/environment/defaults/default_clear_color` = `(0.3, 0.3, 0.3)`.
Het grijs was dus geen render van de grijze blockout maar de *afwezigheid*
van een render — GPU, preset en materialen hadden er niets mee te maken.
**Verwacht**: de blockout met vloer, muren en objecten in beeld.
**Opgelost door**: `TestCamera` in de dev room (D-016), zwaardere tijdelijke
verlichting, contrasterende materialen, en 17 extra smoke-controles die deze
klasse fout voortaan headless afvangen (bewezen: met de camera weggehaald
faalt de suite met exitcode 1).
