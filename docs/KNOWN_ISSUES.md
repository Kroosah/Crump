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

*Geen — het project bevat nog geen code (fase 0: fundering).*

## Opgeloste issues

*Nog geen.*
